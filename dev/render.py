#!/usr/bin/env python3

import collections
import fcntl
import os
import pty
import select
import shlex
import struct
import sys
import tempfile
import termios
import time
from pathlib import Path

import pyte

CLM = Path(os.environ.get("CLM_PATH") or Path(__file__).resolve().parent.parent / "clm")
KEYS = {"UP": b"\x1bOA", "DOWN": b"\x1bOB", "PGUP": b"\x1b[5~", "PGDN": b"\x1b[6~",
        "ENTER": b"\r", "ESC": b"\x1b", "BS": b"\x7f",
        "CSIUP": b"\x1b[A", "CSIDOWN": b"\x1b[B", "CTRLC": b"\x03"}


def main():
    args = sys.argv[1:]
    colors = "--colors" in args
    fake = "--fake-claude" in args
    args = [a for a in args if a not in ("--colors", "--fake-claude")]
    if len(args) < 2:
        sys.exit("usage: render.py [--colors] [--fake-claude] COLS ROWS [KEY ...]\n"
                 "keys: UP DOWN CSIUP CSIDOWN PGUP PGDN ENTER ESC BS CTRLC SIZE=COLSxROWS SLEEP=SECONDS, or literal text")
    cols, rows, keys = int(args[0]), int(args[1]), args[2:]

    stub = tempfile.mkdtemp()
    log = Path(stub) / "launch.log"
    if fake:
        (Path(stub) / "claude").write_text(f'#!/bin/sh\necho "cwd=$(pwd) args=$*" >> "{log}"\n')
        (Path(stub) / "claude").chmod(0o755)

    pid, fd = pty.fork()
    if pid == 0:
        fcntl.ioctl(0, termios.TIOCSWINSZ, struct.pack("HHHH", rows, cols, 0, 0))
        os.environ["TERM"] = "xterm-256color"
        os.environ.pop("LINES", None)
        os.environ.pop("COLUMNS", None)
        if fake:
            os.environ["PATH"] = stub + os.pathsep + os.environ["PATH"]
        command = shlex.split(os.environ.get("CLM_CMD", "")) or [str(CLM)]
        os.execvp(command[0], command)
    fcntl.ioctl(fd, termios.TIOCSWINSZ, struct.pack("HHHH", rows, cols, 0, 0))
    screen = pyte.Screen(cols, rows)
    stream = pyte.ByteStream(screen)

    def pump(seconds):
        end = time.time() + seconds
        while time.time() < end:
            if select.select([fd], [], [], 0.05)[0]:
                try:
                    stream.feed(os.read(fd, 65536))
                except OSError:
                    return False
        return True

    alive = pump(2)
    for key in keys:
        if not alive:
            print(f"! clm exited before key {key!r}", file=sys.stderr)
            break
        if key.startswith("SLEEP="):
            alive = pump(float(key[6:]))
            continue
        if key.startswith("SIZE="):
            cols, rows = map(int, key[5:].split("x"))
            fcntl.ioctl(fd, termios.TIOCSWINSZ, struct.pack("HHHH", rows, cols, 0, 0))
            screen.resize(rows, cols)
        else:
            os.write(fd, KEYS.get(key, key.encode()))
        alive = pump(0.8)

    for y, line in enumerate(screen.display):
        print(line.rstrip())
        if colors and line.strip():
            row = screen.buffer[y]
            mix = collections.Counter((row[x].fg, row[x].bg, row[x].bold) for x in range(cols))
            print("    ", mix.most_common(5))
    if fake:
        print("--- launches:", log.read_text() if log.exists() else "(none)")
    done = os.waitpid(pid, os.WNOHANG)[0]
    print("--- clm exited" if done else "--- clm still running")
    if not done:
        os.kill(pid, 9)


if __name__ == "__main__":
    main()
