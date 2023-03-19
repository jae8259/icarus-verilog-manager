#!/bin/bash

if [ $# -eq 0 ]; then
  # No command-line arguments provided, run all commands except wildcard
  for cmd in modules results tests waveforms; do
    if [ "$cmd" != "*" ]; then
      "$0" "$cmd"
    fi
  done
else
  # Command-line argument provided, run specified command
  case "$1" in
    modules)
       find . -type f \( -name '*.v' -o -name '*.sv' \) \
       | grep -v '_tb' \
       | xargs -I{} mv {} ./modules 2>/dev/null
       echo "Moved modules"
       ;;
    results)
        find . -type f -name '*_result.txt' \
        -exec mv {} ./results \; 2>/dev/null
       echo "Moved results"
       ;;
    tests)
        find . -type f \( -name '*_tb.v' -o -name '*_tb.sv' \) \
        -exec mv {} ./tests \; 2>/dev/null
        echo "Moved tests"
        ;;
    waveforms)
        mv -f *.vcd ./waveforms 2>/dev/null
        echo "Moved waveforms"
        ;;
    *)
        echo "Command not found"
        exit 1
        ;;
  esac
fi
