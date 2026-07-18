#!/usr/bin/env bash
set -euo pipefail

quickshell kill -c mainbar 2>/dev/null || true
exec quickshell -c mainbar --daemonize
