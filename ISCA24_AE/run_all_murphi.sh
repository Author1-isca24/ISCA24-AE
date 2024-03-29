#!/bin/bash

params=(2 4 5 6)

for param in "${params[@]}"; do

  case $param in
    2)
       ./run_single_murphi.sh 2
    ;;

    4) 
       ./run_single_murphi.sh 4 3 3 3 3 3 3
    ;;

    5)
       ./run_single_murphi.sh 5 3 3 3 3 3 3 3 3 3 3 3
    ;;
    
    6)
       ./run_single_murphi.sh 6 
    ;;
  esac

  if [ $? -eq 0 ]; then
    echo "finish model checking table I - $param"
  else
    echo "Error occurred with parameter $param"

  fi
done