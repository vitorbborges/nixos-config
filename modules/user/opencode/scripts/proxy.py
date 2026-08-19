# Transparent TCP proxy: exposes the opencode web UI on LISTEN_PORT and
# forwards every byte to the real server on BACKEND_PORT. Because the web UI
# holds a long-lived SSE stream (/event) while a tab is open, counting
# established connections on this port tells us whether any tab is open:
# zero connections = no tabs. After IDLE_STOP seconds at zero, the backend
# systemd unit is stopped.
#
# This replaces the old separate control page (port 4097): opening
# http://localhost:4096 starts the backend transparently; closing the last
# tab stops it.

import os
import socket
import subprocess
import sys
import threading
import time

LISTEN_HOST = os.environ.get("LISTEN_HOST", "127.0.0.1")
LISTEN_PORT = int(os.environ.get("LISTEN_PORT", "4096"))
BACKEND_HOST = os.environ.get("BACKEND_HOST", "127.0.0.1")
BACKEND_PORT = int(os.environ.get("BACKEND_PORT", "40960"))
UNIT = os.environ.get("UNIT", "opencode-web")
IDLE_STOP = float(os.environ.get("IDLE_STOP", "30"))
BACKEND_WAIT = float(os.environ.get("BACKEND_WAIT", "10"))

lock = threading.Lock()
connections = 0


def systemctl(*args):
    return subprocess.run(["@SYSTEMCTL@", "--user", *args],
                          capture_output=True, text=True)


def is_active():
    return systemctl("is-active", "--quiet", UNIT).returncode == 0


def start_backend():
    if not is_active():
        # no-block: the connect retry loop below waits for readiness
        systemctl("start", "--no-block", UNIT)


def stop_backend():
    if is_active():
        print(f"proxy: no tabs for {IDLE_STOP}s, stopping {UNIT}", file=sys.stderr)
        systemctl("stop", UNIT)


def idle_countdown():
    deadline = time.time() + IDLE_STOP
    while time.time() < deadline:
        with lock:
            if connections > 0:
                return
        time.sleep(1)
    with lock:
        if connections == 0:
            stop_backend()


def on_all_closed():
    with lock:
        if connections != 0:
            return
    threading.Thread(target=idle_countdown, daemon=True).start()


def pipe(src, dst):
    try:
        while True:
            data = src.recv(65536)
            if not data:
                break
            dst.sendall(data)
    except OSError:
        pass
    finally:
        try:
            dst.shutdown(socket.SHUT_WR)
        except OSError:
            pass


def connect_backend():
    deadline = time.time() + BACKEND_WAIT
    while time.time() < deadline:
        try:
            return socket.create_connection((BACKEND_HOST, BACKEND_PORT), timeout=2)
        except OSError:
            time.sleep(0.5)
    return None


def handle(client):
    global connections
    with lock:
        connections += 1
        if connections == 1:
            start_backend()
    try:
        backend = connect_backend()
        if backend is None:
            print("proxy: backend did not come up in time", file=sys.stderr)
            return
        try:
            up = threading.Thread(target=pipe, args=(client, backend), daemon=True)
            down = threading.Thread(target=pipe, args=(backend, client), daemon=True)
            up.start()
            down.start()
            up.join()
            down.join()
        finally:
            backend.close()
    finally:
        client.close()
        with lock:
            connections -= 1
            last_closed = (connections == 0)
        if last_closed:
            on_all_closed()


def main():
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind((LISTEN_HOST, LISTEN_PORT))
    server.listen(16)
    while True:
        conn, _ = server.accept()
        threading.Thread(target=handle, args=(conn,), daemon=True).start()


if __name__ == "__main__":
    main()
