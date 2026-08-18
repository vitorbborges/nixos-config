{ ... }:

{
  # OOM safety net — box has 958 MiB RAM and no swap. A swapfile on the
  # otherwise-idle 38 GB disk protects AdGuardHome (and Vaultwarden) from
  # being OOM-killed under memory pressure.
  swapDevices = [{ device = "/var/lib/swapfile"; size = 2048; }];

  # Swap here is network-backed block storage, slower than local disk —
  # bias the kernel to prefer RAM and only swap as a backstop, not eagerly.
  boot.kernel.sysctl."vm.swappiness" = 10;
}
