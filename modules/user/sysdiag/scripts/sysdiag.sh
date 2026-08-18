#!/usr/bin/env bash
# sysdiag -- ASUS Vivobook K6604JI (i9-13980HX + RTX 4070 Max-Q)
# Usage: sysdiag [--full] [--baseline] [--history]

DIAG_DIR="${HOME}/.local/share/sysdiag"
BASELINE_FILE="${DIAG_DIR}/baseline.json"
HISTORY_FILE="${DIAG_DIR}/history.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

RUN_LOAD_TEST=false
SAVE_BASELINE=false
SHOW_HISTORY=false
SEND_NOTIFY=false
NOTIF_CRIT=()
NOTIF_WARN=()

# Colors -- $'...' gives actual ESC bytes so %s in printf works correctly
RED=$'\033[0;31m'
YEL=$'\033[1;33m'
GRN=$'\033[0;32m'
CYN=$'\033[0;36m'
DIM=$'\033[2m'
BLD=$'\033[1m'
RST=$'\033[0m'

# Force C locale so printf '%.0f' works regardless of system decimal separator
export LC_ALL=C

# Thresholds (degrees C) -- calibrated for K6604JI
CPU_IDLE_WARN=55;  CPU_IDLE_CRIT=68
CPU_LOAD_WARN=88;  CPU_LOAD_CRIT=97
GPU_IDLE_WARN=68;  GPU_IDLE_CRIT=78
GPU_LOAD_WARN=82;  GPU_LOAD_CRIT=90
FAN_HIGH_RPM=4500
DELTA_WARN=8;      DELTA_CRIT=13

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

hr() {
  local title="$1" i pad=""
  for (( i = 0; i < 48 - ${#title}; i++ )); do pad="${pad}-"; done
  printf '\n%s-- %s %s%s\n' "${BLD}${CYN}" "${title}" "${pad}" "${RST}"
}

dim_line() { printf '  %s%s%s\n' "${DIM}" "$*" "${RST}"; }

badge_ok()   { printf '%s[ OK ]%s' "${GRN}" "${RST}"; }
badge_warn() { printf '%s[WARN]%s' "${YEL}" "${RST}"; }
badge_crit() { printf '%s[CRIT]%s' "${RED}" "${RST}"; }
badge_info() { printf '%s[INFO]%s' "${CYN}" "${RST}"; }

badge_for_temp() {
  local val="$1" warn="$2" crit="$3" v
  v=$(printf '%.0f' "${val}")
  if   (( v >= crit )); then badge_crit
  elif (( v >= warn )); then badge_warn
  else badge_ok; fi
}

color_for_temp() {
  local val="$1" warn="$2" crit="$3" v
  v=$(printf '%.0f' "${val}")
  if   (( v >= crit )); then printf '%s%s C%s' "${RED}" "${val}" "${RST}"
  elif (( v >= warn )); then printf '%s%s C%s' "${YEL}" "${val}" "${RST}"
  else printf '%s%s C%s' "${GRN}" "${val}" "${RST}"; fi
}

# Reads CPU package temp from hwmon sysfs; returns integer degrees C or 0.
read_cpu_pkg_temp() {
  local name_file hwmon_dir label_file label num input_file t
  for name_file in /sys/class/hwmon/hwmon*/name; do
    [[ -f "${name_file}" ]] || continue
    if [[ "$(cat "${name_file}")" == "coretemp" ]]; then
      hwmon_dir=$(dirname "${name_file}")
      for label_file in "${hwmon_dir}"/temp*_label; do
        [[ -f "${label_file}" ]] || continue
        label=$(cat "${label_file}" 2>/dev/null || true)
        if [[ "${label}" == *"Package"* ]]; then
          num="${label_file##*temp}"; num="${num%%_*}"
          input_file="${hwmon_dir}/temp${num}_input"
          t=$(cat "${input_file}" 2>/dev/null || echo "0")
          echo $(( t / 1000 ))
          return
        fi
      done
      # fallback: temp1_input is the conventional package sensor on Intel
      t=$(cat "${hwmon_dir}/temp1_input" 2>/dev/null || echo "0")
      echo $(( t / 1000 ))
      return
    fi
  done
  echo "0"
}

# Returns the highest temp sensor value for coretemp in degrees C (integer).
read_cpu_max_core_temp() {
  local name_file hwmon_dir temp_file t max_t=0
  for name_file in /sys/class/hwmon/hwmon*/name; do
    [[ -f "${name_file}" ]] || continue
    if [[ "$(cat "${name_file}")" == "coretemp" ]]; then
      hwmon_dir=$(dirname "${name_file}")
      for temp_file in "${hwmon_dir}"/temp*_input; do
        [[ -f "${temp_file}" ]] || continue
        t=$(cat "${temp_file}" 2>/dev/null || echo "0")
        t=$(( t / 1000 ))
        if (( t > max_t )); then max_t=${t}; fi
      done
    fi
  done
  echo "${max_t}"
}

push_crit() { NOTIF_CRIT+=("$*"); }
push_warn() { NOTIF_WARN+=("$*"); }

# Decodes nvidia-smi throttle reason hex; prints human string for bad bits only.
# 0x1=GpuIdle  0x4=SwPowerCap(Max-Q,normal)  0x8=HwSlowdown
# 0x20=SwThermal  0x40=HwThermal  0x80=HwPowerBrake
describe_throttle() {
  local hex="$1" dec msgs=()
  hex="${hex#0x}"; hex="${hex# }"
  [[ "${hex}" =~ ^[0-9a-fA-F]+$ ]] || return 0
  dec=$(printf '%d' "0x${hex}" 2>/dev/null) || return 0
  (( (dec & 0x08) != 0 )) && msgs+=("HW slowdown")
  (( (dec & 0x20) != 0 )) && msgs+=("SW thermal")
  (( (dec & 0x40) != 0 )) && msgs+=("HW thermal")
  (( (dec & 0x80) != 0 )) && msgs+=("HW power brake")
  if (( ${#msgs[@]} > 0 )); then
    local IFS=', '
    printf '%s' "${msgs[*]}"
  fi
}

# ---------------------------------------------------------------------------
# Flags
# ---------------------------------------------------------------------------

for arg in "$@"; do
  case "${arg}" in
    --full)     RUN_LOAD_TEST=true ;;
    --baseline) SAVE_BASELINE=true ;;
    --history)  SHOW_HISTORY=true ;;
    --notify)   SEND_NOTIFY=true ;;
    -h|--help)
      printf 'Usage: sysdiag [--full] [--baseline] [--history] [--notify]\n'
      printf '  --full      30s CPU+GPU load test\n'
      printf '  --baseline  Save current idle temps as new baseline\n'
      printf '  --history   Print last 30 historical records\n'
      printf '  --notify    Send desktop notifications for any issues found\n'
      exit 0 ;;
  esac
done

mkdir -p "${DIAG_DIR}"

# ---------------------------------------------------------------------------
# History
# ---------------------------------------------------------------------------

if ${SHOW_HISTORY}; then
  hr "HISTORY (last 30 runs)"
  if [[ -f "${HISTORY_FILE}" ]]; then
    tail -30 "${HISTORY_FILE}" | while IFS= read -r line; do
      ts=$(printf '%s' "${line}"    | jq -r '.timestamp')
      cpu=$(printf '%s' "${line}"   | jq -r '.cpu_pkg')
      gpu=$(printf '%s' "${line}"   | jq -r '.gpu_idle')
      cpu_l=$(printf '%s' "${line}" | jq -r '.cpu_load_peak')
      printf '  %s  CPU idle: %3s C  GPU idle: %3s C  CPU load peak: %s C\n' \
        "${ts}" "${cpu}" "${gpu}" "${cpu_l}"
    done
  else
    printf '  No history yet -- run sysdiag first.\n'
  fi
  exit 0
fi

# ---------------------------------------------------------------------------
# Header
# ---------------------------------------------------------------------------

printf '\n%s' "${BLD}"
printf '  +---------------------------------------------------+\n'
printf '  |  sysdiag  .  ASUS K6604JI  .  i9-13980HX+4070   |\n'
printf '  +---------------------------------------------------+%s\n' "${RST}"
dim_line "  ${TIMESTAMP}  .  $(uptime -p 2>/dev/null || uptime)"

# ---------------------------------------------------------------------------
# CPU
# ---------------------------------------------------------------------------

hr "CPU"

CPU_PKG=$(read_cpu_pkg_temp)
CPU_CORE=$(read_cpu_max_core_temp)

if (( CPU_PKG == 0 )); then
  printf '  %s  No CPU thermal sensors found\n' "$(badge_info)"
  dim_line "  Rebuild after hardware-maintenance.nix change to load coretemp module"
else
  printf '  %s  Package: %s   Max core: %s\n' \
    "$(badge_for_temp "${CPU_PKG}" ${CPU_IDLE_WARN} ${CPU_IDLE_CRIT})" \
    "$(color_for_temp "${CPU_PKG}" ${CPU_IDLE_WARN} ${CPU_IDLE_CRIT})" \
    "$(color_for_temp "${CPU_CORE}" ${CPU_IDLE_WARN} ${CPU_IDLE_CRIT})"
fi

FREQ_CUR_KHZ=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq 2>/dev/null || echo "0")
FREQ_MAX_KHZ=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq  2>/dev/null || echo "1")
if (( FREQ_CUR_KHZ > 0 && FREQ_MAX_KHZ > 1 )); then
  FREQ_CUR_GHZ=$(echo "scale=2; ${FREQ_CUR_KHZ} / 1000000" | bc)
  FREQ_MAX_GHZ=$(echo "scale=2; ${FREQ_MAX_KHZ} / 1000000" | bc)
  FREQ_PCT=$(echo "scale=0; ${FREQ_CUR_KHZ} * 100 / ${FREQ_MAX_KHZ}" | bc)
  dim_line "  Freq: ${FREQ_CUR_GHZ} GHz / ${FREQ_MAX_GHZ} GHz max (${FREQ_PCT}% of boost clock)"
fi

# ---------------------------------------------------------------------------
# GPU
# ---------------------------------------------------------------------------

hr "GPU (RTX 4070 Max-Q)"

GPU_TEMP=0
GPU_FAN="N/A"
GPU_POWER="N/A"
GPU_CLOCK="N/A"
GPU_MAX_CLK="N/A"
GPU_UTIL="N/A"
GPU_THROTTLE="0x0"

if command -v nvidia-smi &>/dev/null; then
  GPU_RAW=$(nvidia-smi \
    --query-gpu=temperature.gpu,fan.speed,power.draw,clocks.sm,clocks.max.sm,utilization.gpu,clocks_throttle_reasons.active \
    --format=csv,noheader,nounits 2>/dev/null || true)

  if [[ -n "${GPU_RAW}" ]]; then
    GPU_TEMP=$(printf '%s'     "${GPU_RAW}" | awk -F', ' '{gsub(/[^0-9]/,"",$1);   print $1}')
    GPU_FAN=$(printf '%s'      "${GPU_RAW}" | awk -F', ' '{gsub(/ /,"",$2);        print $2}')
    GPU_POWER=$(printf '%s'    "${GPU_RAW}" | awk -F', ' '{gsub(/[^0-9.]/,"",$3);  print $3}')
    GPU_CLOCK=$(printf '%s'    "${GPU_RAW}" | awk -F', ' '{gsub(/[^0-9]/,"",$4);   print $4}')
    GPU_MAX_CLK=$(printf '%s'  "${GPU_RAW}" | awk -F', ' '{gsub(/[^0-9]/,"",$5);   print $5}')
    GPU_UTIL=$(printf '%s'     "${GPU_RAW}" | awk -F', ' '{gsub(/[^0-9]/,"",$6);   print $6}')
    GPU_THROTTLE=$(printf '%s' "${GPU_RAW}" | awk -F', ' '{sub(/^ /,"",$7);        print $7}')

    [[ -z "${GPU_TEMP}" ]] && GPU_TEMP=0

    FAN_DISP="${GPU_FAN}%"
    if [[ "${GPU_FAN}" == "[N/A]" || "${GPU_FAN}" == "N/A" ]]; then
      FAN_DISP="N/A (EC-controlled)"
    fi

    printf '  %s  Temp: %s   Fan: %s   Power: %s W   Util: %s%%\n' \
      "$(badge_for_temp "${GPU_TEMP}" ${GPU_IDLE_WARN} ${GPU_IDLE_CRIT})" \
      "$(color_for_temp "${GPU_TEMP}" ${GPU_IDLE_WARN} ${GPU_IDLE_CRIT})" \
      "${FAN_DISP}" "${GPU_POWER}" "${GPU_UTIL}"
    dim_line "  Clock: ${GPU_CLOCK} MHz / ${GPU_MAX_CLK} MHz max"

    THROTTLE_DESC=$(describe_throttle "${GPU_THROTTLE}" || true)
    if [[ -n "${THROTTLE_DESC}" ]]; then
      printf '  %s  GPU throttling active: %s\n' "$(badge_warn)" "${THROTTLE_DESC}"
      push_warn "GPU throttling: ${THROTTLE_DESC}"
    fi
  fi
else
  printf '  %s  nvidia-smi not found\n' "$(badge_info)"
fi

# ---------------------------------------------------------------------------
# Fans
# ---------------------------------------------------------------------------

hr "FANS"

FAN_FOUND=false
for name_file in /sys/class/hwmon/hwmon*/name; do
  [[ -f "${name_file}" ]] || continue
  hwmon_dir=$(dirname "${name_file}")
  chip=$(cat "${name_file}" 2>/dev/null || true)
  for fan_file in "${hwmon_dir}"/fan*_input; do
    [[ -f "${fan_file}" ]] || continue
    FAN_FOUND=true
    rpm=$(cat "${fan_file}" 2>/dev/null || echo "0")
    fan_num="${fan_file##*fan}"; fan_num="${fan_num%%_*}"
    label_file="${hwmon_dir}/fan${fan_num}_label"
    if [[ -f "${label_file}" ]]; then
      label=$(cat "${label_file}" 2>/dev/null || echo "Fan ${fan_num}")
    else
      label="${chip} fan${fan_num}"
    fi
    if (( rpm == 0 )); then
      printf '  %s  %s: %s0 RPM%s -- stopped!\n' "$(badge_crit)" "${label}" "${RED}" "${RST}"
      push_crit "${label}: 0 RPM — fan stopped, check cooling immediately"
    elif (( rpm > FAN_HIGH_RPM )); then
      printf '  %s  %s: %s%d RPM%s -- running fast\n' \
        "$(badge_warn)" "${label}" "${YEL}" "${rpm}" "${RST}"
      push_warn "${label}: ${rpm} RPM — running fast (>${FAN_HIGH_RPM} RPM threshold)"
    else
      printf '  %s  %s: %s%d RPM%s\n' \
        "$(badge_ok)" "${label}" "${GRN}" "${rpm}" "${RST}"
    fi
  done
done

if ! ${FAN_FOUND}; then
  printf '  %s  No fan sensors found in hwmon\n' "$(badge_info)"
  dim_line "  ASUS EC fans may not be exposed; check asus-wmi-sensors kernel module"
fi

# ---------------------------------------------------------------------------
# Battery
# ---------------------------------------------------------------------------

hr "BATTERY"

BATT_CAP=0
BATT_STATE="unknown"
BATT_FULL="N/A"
BATT_DESIGN="N/A"
BATT_CYCLES="N/A"
BATT_PERCENT=0

UPOWER_DEV=$(upower -e 2>/dev/null | grep -i "battery" | grep -v "DisplayDevice" | head -1 || true)
if [[ -n "${UPOWER_DEV}" ]]; then
  UPOWER_OUT=$(upower -i "${UPOWER_DEV}" 2>/dev/null || true)
  if [[ -n "${UPOWER_OUT}" ]]; then
    # Normalise locale decimal separator (some locales use comma)
    UPOWER_NORM=$(printf '%s' "${UPOWER_OUT}" | tr ',' '.')
    BATT_CAP=$(printf '%s'     "${UPOWER_NORM}" | grep "^    capacity:"           | grep -oP '[0-9.]+' | head -1 || echo "0")
    BATT_STATE=$(printf '%s'   "${UPOWER_NORM}" | grep "^    state:"              | awk '{print $2}'   || echo "unknown")
    BATT_FULL=$(printf '%s'    "${UPOWER_NORM}" | grep "^    energy-full:"        | grep -v "design"   | awk '{print $2, $3}' || echo "N/A")
    BATT_DESIGN=$(printf '%s'  "${UPOWER_NORM}" | grep "^    energy-full-design:" | awk '{print $2, $3}' || echo "N/A")
    BATT_CYCLES=$(printf '%s'  "${UPOWER_NORM}" | grep "charge-cycles:"          | awk '{print $2}'   || echo "N/A")
    BATT_PERCENT=$(printf '%s' "${UPOWER_NORM}" | grep "^    percentage:"         | grep -oP '[0-9.]+' | head -1 || echo "0")

    CAP_INT=$(printf '%.0f' "${BATT_CAP}")
    if   (( CAP_INT >= 80 )); then BATT_BADGE="$(badge_ok)"
    elif (( CAP_INT >= 65 )); then BATT_BADGE="$(badge_warn)"
    else BATT_BADGE="$(badge_crit)"; fi

    printf '  %s  Health: %s%%   Charge: %s%%   State: %s\n' \
      "${BATT_BADGE}" "${CAP_INT}" "${BATT_PERCENT}" "${BATT_STATE}"
    dim_line "  Capacity: ${BATT_FULL} / ${BATT_DESIGN} (design)   Cycles: ${BATT_CYCLES}"
  fi
else
  printf '  %s  No battery device found\n' "$(badge_info)"
fi

# ---------------------------------------------------------------------------
# NVMe SSD
# ---------------------------------------------------------------------------

hr "NVME SSD"

NVME_FOUND=false
for dev in /dev/nvme*n1; do
  [[ -b "${dev}" ]] || continue
  NVME_FOUND=true
  dname=$(basename "${dev}")

  if SMART=$(/run/wrappers/bin/sudo -n smartctl -a "${dev}" 2>/dev/null); then
    SMART_HEALTH=$(printf '%s' "${SMART}" | grep "SMART overall" | awk '{print $NF}')
    NVME_TEMP=$(printf '%s'    "${SMART}" | grep -i "^Temperature:"    | grep -oP '[0-9]+'   | head -1 || echo "N/A")
    NVME_WEAR=$(printf '%s'    "${SMART}" | grep -i "Percentage Used:" | grep -oP '[0-9]+'   | head -1 || echo "N/A")
    NVME_HOURS=$(printf '%s'   "${SMART}" | grep -i "Power On Hours:"  | grep -oP '[0-9,]+' | head -1 | tr -d ',' || echo "N/A")
    if [[ "${SMART_HEALTH}" == "PASSED" ]]; then
      printf '  %s  %s: %s\n' "$(badge_ok)" "${dname}" "${SMART_HEALTH}"
    else
      printf '  %s  %s: %s\n' "$(badge_crit)" "${dname}" "${SMART_HEALTH}"
      push_crit "${dname} SMART: ${SMART_HEALTH} — drive may be failing, back up now"
    fi
    dim_line "  Temp: ${NVME_TEMP} C   Wear: ${NVME_WEAR}%   Power-on: ${NVME_HOURS} h"
  else
    printf '  %s  %s: needs sudo for SMART data\n' "$(badge_info)" "${dname}"
    dim_line "  NOPASSWD sudoers rule should cover this -- check modules/system/hardware-maintenance.nix if it doesn't"
    if NLOG=$(/run/wrappers/bin/sudo -n nvme smart-log "${dev}" 2>/dev/null); then
      NVME_TEMP=$(printf '%s' "${NLOG}" | grep "temperature"  | grep -oP '[0-9]+' | head -1 || echo "N/A")
      NVME_WEAR=$(printf '%s' "${NLOG}" | grep "percent_used" | grep -oP '[0-9]+' | head -1 || echo "N/A")
      dim_line "  Temp: ~${NVME_TEMP} C   Wear: ${NVME_WEAR}%"
    fi
  fi
done

if ! ${NVME_FOUND}; then
  printf '  %s  No NVMe block devices found\n' "$(badge_info)"
fi

# ---------------------------------------------------------------------------
# Load test (--full)
# ---------------------------------------------------------------------------

CPU_PEAK_LOAD=0
GPU_PEAK_LOAD=0

if ${RUN_LOAD_TEST}; then
  hr "LOAD TEST (30 s)"
  printf '  %s  Stressing all %d CPU threads for 30 seconds...\n' \
    "$(badge_info)" "$(nproc)"

  stress-ng --cpu 0 --timeout 30s --quiet &>/dev/null &
  STRESS_PID=$!

  for i in 5 10 15 20 25 30; do
    sleep 5
    T_CPU=$(read_cpu_pkg_temp)
    T_GPU=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null || echo "0")
    printf '  [%2ds] CPU: %s   GPU: %s C\n' \
      "${i}" \
      "$(color_for_temp "${T_CPU}" ${CPU_LOAD_WARN} ${CPU_LOAD_CRIT})" \
      "${T_GPU}"
    if (( T_CPU > CPU_PEAK_LOAD )); then CPU_PEAK_LOAD=${T_CPU}; fi
    T_GPU_INT=$(printf '%.0f' "${T_GPU}")
    if (( T_GPU_INT > GPU_PEAK_LOAD )); then GPU_PEAK_LOAD=${T_GPU_INT}; fi
  done

  wait "${STRESS_PID}" 2>/dev/null || true

  printf '\n'
  printf '  %s  CPU peak: %s\n' \
    "$(badge_for_temp "${CPU_PEAK_LOAD}" ${CPU_LOAD_WARN} ${CPU_LOAD_CRIT})" \
    "$(color_for_temp "${CPU_PEAK_LOAD}" ${CPU_LOAD_WARN} ${CPU_LOAD_CRIT})"
  printf '  %s  GPU peak: %s\n' \
    "$(badge_for_temp "${GPU_PEAK_LOAD}" ${GPU_LOAD_WARN} ${GPU_LOAD_CRIT})" \
    "$(color_for_temp "${GPU_PEAK_LOAD}" ${GPU_LOAD_WARN} ${GPU_LOAD_CRIT})"

  # Throttle check via frequency drop post-load
  FREQ_POST=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq 2>/dev/null || echo "0")
  if (( FREQ_POST > 0 && FREQ_MAX_KHZ > 1 )); then
    PCT_POST=$(echo "scale=0; ${FREQ_POST} * 100 / ${FREQ_MAX_KHZ}" | bc)
    if   (( PCT_POST < 50 )); then
      printf '  %s  CPU throttling: frequency at %s%% of max -- severe\n' "$(badge_crit)" "${PCT_POST}"
    elif (( PCT_POST < 75 )); then
      printf '  %s  CPU frequency at %s%% of max post-load -- mild throttling\n' "$(badge_warn)" "${PCT_POST}"
    fi
  fi
fi

# ---------------------------------------------------------------------------
# Baseline
# ---------------------------------------------------------------------------

hr "BASELINE"

CURRENT_JSON=$(jq -n \
  --arg ts   "${TIMESTAMP}" \
  --arg cpu  "${CPU_PKG}" \
  --arg core "${CPU_CORE}" \
  --arg gpu  "${GPU_TEMP}" \
  --arg cpul "${CPU_PEAK_LOAD}" \
  --arg gpul "${GPU_PEAK_LOAD}" \
  '{timestamp: $ts, cpu_pkg: $cpu, cpu_core: $core, gpu_idle: $gpu,
    cpu_load_peak: $cpul, gpu_load_peak: $gpul}')

if ${SAVE_BASELINE} || [[ ! -f "${BASELINE_FILE}" ]]; then
  printf '%s\n' "${CURRENT_JSON}" > "${BASELINE_FILE}"
  if ${SAVE_BASELINE}; then
    printf '  %s  New baseline saved -- CPU: %s C  GPU: %s C\n' \
      "$(badge_ok)" "${CPU_PKG}" "${GPU_TEMP}"
  else
    printf '  %s  First run -- baseline established\n' "$(badge_info)"
    dim_line "  CPU: ${CPU_PKG} C  GPU: ${GPU_TEMP} C  (run --baseline after a fresh boot to reset)"
  fi
else
  BASE_CPU=$(jq -r '.cpu_pkg'   "${BASELINE_FILE}")
  BASE_GPU=$(jq -r '.gpu_idle'  "${BASELINE_FILE}")
  BASE_TS=$(jq  -r '.timestamp' "${BASELINE_FILE}")
  dim_line "  Baseline from: ${BASE_TS}"

  if [[ "${BASE_CPU}" != "null" ]] && (( BASE_CPU > 0 && CPU_PKG > 0 )); then
    DELTA_CPU=$(echo "scale=1; ${CPU_PKG} - ${BASE_CPU}" | bc)
    DELTA_INT=$(printf '%.0f' "${DELTA_CPU}")
    if   (( DELTA_INT >= DELTA_CRIT )); then
      printf '  %s  CPU idle: %s+%s C%s above baseline (%s -> %s C)\n' \
        "$(badge_crit)" "${RED}" "${DELTA_CPU}" "${RST}" "${BASE_CPU}" "${CPU_PKG}"
    elif (( DELTA_INT >= DELTA_WARN )); then
      printf '  %s  CPU idle: %s+%s C%s above baseline (%s -> %s C)\n' \
        "$(badge_warn)" "${YEL}" "${DELTA_CPU}" "${RST}" "${BASE_CPU}" "${CPU_PKG}"
    else
      printf '  %s  CPU idle: %+.1f C vs baseline (%s -> %s C)\n' \
        "$(badge_ok)" "${DELTA_CPU}" "${BASE_CPU}" "${CPU_PKG}"
    fi
  fi

  if [[ "${BASE_GPU}" != "null" ]] && (( BASE_GPU > 0 && GPU_TEMP > 0 )); then
    DELTA_GPU=$(echo "scale=1; ${GPU_TEMP} - ${BASE_GPU}" | bc)
    DELTA_GPU_INT=$(printf '%.0f' "${DELTA_GPU}")
    if   (( DELTA_GPU_INT >= DELTA_CRIT )); then
      printf '  %s  GPU idle: %s+%s C%s above baseline (%s -> %s C)\n' \
        "$(badge_crit)" "${RED}" "${DELTA_GPU}" "${RST}" "${BASE_GPU}" "${GPU_TEMP}"
    elif (( DELTA_GPU_INT >= DELTA_WARN )); then
      printf '  %s  GPU idle: %s+%s C%s above baseline (%s -> %s C)\n' \
        "$(badge_warn)" "${YEL}" "${DELTA_GPU}" "${RST}" "${BASE_GPU}" "${GPU_TEMP}"
    else
      printf '  %s  GPU idle: %+.1f C vs baseline (%s -> %s C)\n' \
        "$(badge_ok)" "${DELTA_GPU}" "${BASE_GPU}" "${GPU_TEMP}"
    fi
  fi
fi

printf '%s\n' "${CURRENT_JSON}" >> "${HISTORY_FILE}"

# ---------------------------------------------------------------------------
# Recommendations
# ---------------------------------------------------------------------------

hr "RECOMMENDATIONS"

RECS=()

if (( CPU_PKG >= CPU_IDLE_CRIT )); then
  RECS+=("${RED}CLEAN NOW     ${RST} CPU idle ${CPU_PKG} C >= ${CPU_IDLE_CRIT} C -- dust blocking airflow")
  push_crit "CPU idle ${CPU_PKG}°C >= ${CPU_IDLE_CRIT}°C — clean dust now"
elif (( CPU_PKG >= CPU_IDLE_WARN )); then
  RECS+=("${YEL}CLEAN SOON    ${RST} CPU idle ${CPU_PKG} C >= ${CPU_IDLE_WARN} C -- schedule next cleaning")
  push_warn "CPU idle ${CPU_PKG}°C >= ${CPU_IDLE_WARN}°C — schedule cleaning"
fi

GPU_T_INT=$(printf '%.0f' "${GPU_TEMP}")
if (( GPU_T_INT >= GPU_IDLE_CRIT )); then
  RECS+=("${RED}CLEAN NOW     ${RST} GPU idle ${GPU_TEMP} C >= ${GPU_IDLE_CRIT} C -- dust blocking exhaust")
  push_crit "GPU idle ${GPU_TEMP}°C >= ${GPU_IDLE_CRIT}°C — clean dust now"
elif (( GPU_T_INT >= GPU_IDLE_WARN )); then
  push_warn "GPU idle ${GPU_TEMP}°C >= ${GPU_IDLE_WARN}°C — monitor exhaust temps"
fi

if ${RUN_LOAD_TEST}; then
  if (( CPU_PEAK_LOAD >= CPU_LOAD_CRIT )); then
    RECS+=("${RED}REPASTE CPU   ${RST} Load peak ${CPU_PEAK_LOAD} C >= ${CPU_LOAD_CRIT} C -- thermal paste likely dried")
    push_crit "CPU load peak ${CPU_PEAK_LOAD}°C >= ${CPU_LOAD_CRIT}°C — repaste CPU"
  elif (( CPU_PEAK_LOAD >= CPU_LOAD_WARN )); then
    RECS+=("${YEL}MONITOR CPU   ${RST} Load peak ${CPU_PEAK_LOAD} C -- clean first, repaste if no improvement")
    push_warn "CPU load peak ${CPU_PEAK_LOAD}°C >= ${CPU_LOAD_WARN}°C — clean, then repaste if no improvement"
  fi
  if (( GPU_PEAK_LOAD >= GPU_LOAD_CRIT )); then
    RECS+=("${RED}REPASTE GPU   ${RST} Load peak ${GPU_PEAK_LOAD} C >= ${GPU_LOAD_CRIT} C -- inspect GPU thermal pad")
    push_crit "GPU load peak ${GPU_PEAK_LOAD}°C >= ${GPU_LOAD_CRIT}°C — inspect GPU thermal pad"
  fi
fi

if [[ -f "${BASELINE_FILE}" ]] && ! ${SAVE_BASELINE}; then
  BASE_CPU_R=$(jq -r '.cpu_pkg' "${BASELINE_FILE}")
  if [[ "${BASE_CPU_R}" != "null" ]] && (( BASE_CPU_R > 0 && CPU_PKG > 0 )); then
    DELTA_R=$(echo "scale=1; ${CPU_PKG} - ${BASE_CPU_R}" | bc)
    DELTA_R_INT=$(printf '%.0f' "${DELTA_R}")
    if (( DELTA_R_INT >= DELTA_CRIT )); then
      RECS+=("${RED}CLEAN/REPASTE ${RST} CPU +${DELTA_R} C above baseline -- inspect cooling")
      push_crit "CPU +${DELTA_R}°C above baseline — inspect cooling"
    elif (( DELTA_R_INT >= DELTA_WARN )); then
      RECS+=("${YEL}TRENDING UP   ${RST} CPU +${DELTA_R} C above baseline -- monitor; clean if continues")
      push_warn "CPU +${DELTA_R}°C above baseline — monitor, clean if trend continues"
    fi
  fi
fi

BATT_CAP_INT=$(printf '%.0f' "${BATT_CAP}")
if   (( BATT_CAP_INT > 0 && BATT_CAP_INT < 65 )); then
  RECS+=("${YEL}BATTERY       ${RST} Capacity at ${BATT_CAP_INT}% -- replacement recommended")
  push_crit "Battery capacity ${BATT_CAP_INT}% — replacement recommended"
elif (( BATT_CAP_INT > 0 && BATT_CAP_INT < 80 )); then
  RECS+=("${YEL}BATTERY       ${RST} Capacity at ${BATT_CAP_INT}% -- degraded but usable, monitor")
  push_warn "Battery capacity ${BATT_CAP_INT}% — degraded, monitor"
fi

if (( ${#RECS[@]} == 0 )); then
  printf '  %s  All systems nominal.\n' "$(badge_ok)"
else
  for rec in "${RECS[@]}"; do
    printf '  > %s\n' "${rec}"
  done
fi

printf '\n'
dim_line "  Tips: sysdiag --full (load test) . sysdiag --baseline (reset) . sysdiag --history"
printf '\n'

# ---------------------------------------------------------------------------
# Notifications (--notify)
# ---------------------------------------------------------------------------

if ${SEND_NOTIFY}; then
  if (( ${#NOTIF_CRIT[@]} > 0 )); then
    NOTIF_BODY=$(printf '• %s\n' "${NOTIF_CRIT[@]}")
    notify-send -u critical -t 0 -i dialog-error "sysdiag — Critical Issues" "${NOTIF_BODY}"
  fi
  if (( ${#NOTIF_WARN[@]} > 0 )); then
    NOTIF_BODY=$(printf '• %s\n' "${NOTIF_WARN[@]}")
    notify-send -u normal -t 15000 -i dialog-warning "sysdiag — Warnings" "${NOTIF_BODY}"
  fi
fi
