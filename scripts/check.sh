#!/usr/bin/env bash
set -euo pipefail
swift test
swift run aer-sim >/tmp/aer-sim.csv
printf 'AER checks passed. Simulator output: /tmp/aer-sim.csv\n'
