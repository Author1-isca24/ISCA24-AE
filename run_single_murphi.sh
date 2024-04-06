#!/bin/bash

DEST_DIR="CMurphi/src"
CURRENT_DIR=$(pwd)
# SOURCE_DIR="ISCA24_AE/Table1-(2)"

if [ $# -lt 1 ]; then
    echo "Usage for Table1 - (2) or (6): $0 <part_number>"
    echo "Usage for Table1 - (4) or (5): $0 <part_number> [durations...]"
    exit 1
fi


part_number=$1
shift # Remove the first argument so $@ contains only the durations

# Define arrays to hold the durations for each part
declare -a durations=("$@")

# case $1 in
#     2) SOURCE_DIR="Table1-(2)/murphi" ;;
#     4) SOURCE_DIR="Table1-(4)/murphi" ;;
#     5) SOURCE_DIR="Table1-(5)/murphi" ;;
#     6) SOURCE_DIR="Table1-(6)/murphi" ;;
#     *)
#         echo "Invalid input: $1. Please input the part you want to modecl check in Table I: 2, 4, 5 or 6."
#         exit 1
#         ;;
# esac

# Determine SOURCE_DIR based on the part_number
case $part_number in
    2) 
        SOURCE_DIR="Table1-(2)/murphi"
        expected_files=0 # No specific duration per file
        ;;
    4) 
        SOURCE_DIR="Table1-(4)/murphi"
        expected_files=6 # 6 .o files, each with a specific duration
        ;;
    5) 
        SOURCE_DIR="Table1-(5)/murphi"
        expected_files=12 # 12 .o files, each with a specific duration
        ;;
    6) 
        SOURCE_DIR="Table1-(6)/murphi"
        expected_files=0 # No specific duration per file
        ;;
    *)
        echo "Invalid input: $part_number. Please input the part you want to model check in Table I: (2), (4), (5), or (6)."
        exit 1
        ;;
esac

# Check if the number of durations matches the expected number of .o files
if [[ $expected_files -gt 0 && ${#durations[@]} -ne $expected_files ]]; then
    echo "Error: Expected $expected_files durations for Tabile 1 -($part_number), but got ${#durations[@]}."
    exit 1
fi

# copy the murphi codes to CMurphi/src
copied_files=()
for file in "${SOURCE_DIR}"/*.m; do
    cp "${file}" "${DEST_DIR}"

    copied_files+=("$(basename -- "${file}")")
done

echo "Copy the Murphi codes from ${SOURCE_DIR} to ${DEST_DIR}..."

cd "${DEST_DIR}" || exit

echo "Compiling the murphi codes to cpp codes..."

# compile .m files, gemerate .cpp files
for file in "${copied_files[@]}"; do
    base_name=$(basename -- "${file}" .m)
    ./mu -c -b --cache "${base_name}.m" &> "${base_name}_m_compile_res.txt"
done

echo "Compiling the cpp codes to executables..."

#compile .cpp files, generate .o files
for file in "${copied_files[@]}"; do
    base_name=$(basename -- "${file}" .m) 
    if [[ -f "${base_name}.cpp" ]]; then
        g++ -O2 -o "${base_name}.o" "${base_name}.cpp" -I ../include -lm &> "${base_name}_compile_res.txt"
    fi
done

echo "Model checking begins..."
# execute .o files, the model checking begins
# for file in "${copied_files[@]}"; do
#     base_name=$(basename -- "${base_name}" .m)
#     if [[ -f "${base_name}.o" ]]; then
#         ./"${base_name}.o" -d ErrorTrace -tv -pr -p5 m 50000 &> "${SOURCE_DIR}/${base_name}_result.txt"
#     fi
# done

file_index=0
for file in "${copied_files[@]}"; do
    base_name=$(basename -- "$file" .m)
    if [[ -f "${base_name}.o" ]]; then
        # Calculate the duration for this file
        if [[ $expected_files -gt 0 ]]; then
            # Convert the duration from days to seconds
            duration_days=${durations[$file_index]}
            max_seconds=$(echo "$duration_days * 24 * 3600" / 1 | bc)
        else
            # Default duration for parts 2 and 6
            max_seconds=0 
        fi

        if [[ $max_seconds -gt 0 ]]; then
            # timeout "${max_seconds}" ./"${base_name}.o" -d ErrorTrace -tv -pr -p5 -m 50000 &> "${SOURCE_DIR}/${base_name}_result.txt"
            timeout "${max_seconds}" ./"${base_name}.o" -d ErrorTrace -maxl180 -tv -pr -p5 -m 80000 &> "${base_name}_result.txt"
            if [ $? -eq 124 ]; then
                echo "Timeout: ${base_name}.o exceeded the time limit of ${duration_days} days."
            fi
        else
            ./"${base_name}.o" -d ErrorTrace -maxl180 -tv -pr -p5 -m 80000 &> "${base_name}_result.txt"
        fi
    
        mv "${base_name}_result.txt" "${CURRENT_DIR}/${SOURCE_DIR}/${base_name}_result.txt"

        ((file_index++))
    fi
done
