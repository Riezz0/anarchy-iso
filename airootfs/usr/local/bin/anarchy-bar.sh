#!/usr/bin/env bash
set -euo pipefail

quickshell kill -c Anarchy-Bar 2>/dev/null || true
exec quickshell -c Anarchy-Bar --daemonize
