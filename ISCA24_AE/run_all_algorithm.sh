#!/bin/bash

# protocol list
args=("MOSI" "MOESI" "CHI" "MSI_nonblocking_cache" "MESI_nonblocking_cache" "MSI_blocking_cache" "MESI_blocking_cache")

# run algorithm for all the protocols
for arg in "${args[@]}"; do
  echo "Running algorithm for '$arg' protocol ..."
  python3 main.py "$arg" &> "${arg}_result.txt"

  if [ $? -eq 0 ]; then
    echo "the algorithm executed successfully for '$arg' protocol"
  else
    echo "the algorithm failed with '$arg' and exit status $?."
    exit 1
  fi
done

echo -e "\n The wait graph of the above protocols are saved to ISCA24_AE/"
python3 result_extract.py