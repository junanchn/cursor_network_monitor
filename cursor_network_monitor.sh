#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"
python3 -x "$DIR/cursor_network_monitor.bat" "$@"
