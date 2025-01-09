#!/bin/bash

# usage instructions
usage() {
    echo "Usage: $0 -s <shift> -i <input file> -o <output file>"
    echo "Example: $0 -s 3 -i plain.txt -o cipher.txt"
    exit 1
}

# encryption
caesar_cipher() {
    local text="$1"
    local shift="$2"
    local result=""
    
    shift=$(( (shift % 26 + 26) % 26 ))
    
    for ((i=0; i<${#text}; i++)); do
        char="${text:i:1}"
        
        # Uppercase
        if [[ "$char" =~ [A-Z] ]]; then
            ascii=$(printf '%d' "'$char")
            ascii=$((ascii - 65))
            ascii=$(((ascii + shift) % 26))
            ascii=$((ascii + 65))
            result+=$(printf '%b' "$(printf '\\%03o' "$ascii")")
            
        # Lowercase
        elif [[ "$char" =~ [a-z] ]]; then
            ascii=$(printf '%d' "'$char")
            ascii=$((ascii - 97))
            ascii=$(((ascii + shift) % 26))
            ascii=$((ascii + 97))
            result+=$(printf '%b' "$(printf '\\%03o' "$ascii")")
            
        else
            result+="$char"
        fi
    done
    
    echo "$result"
}

# Parser
while getopts ":s:i:o:" opt; do
    case $opt in
        s) shift_value="$OPTARG";;
        i) input_file="$OPTARG";;
        o) output_file="$OPTARG";;
        \?) echo "Invalid option: -$OPTARG"; usage;;
        :) echo "Option -$OPTARG requires an argument."; usage;;
    esac
done

# Validation
if [ -z "$shift_value" ] || [ -z "$input_file" ] || [ -z "$output_file" ]; then
    echo "Error: Missing required parameters"
    usage
fi

# negative ints
if ! [[ "$shift_value" =~ ^-?[0-9]+$ ]]; then
    echo "Error: Shift value must be an integer"
    exit 1
fi

if [ ! -f "$input_file" ]; then
    echo "Error: Input file '$input_file' does not exist"
    exit 1
fi

# Clearing output if it already exists
true > "$output_file"

while IFS= read -r line || [ -n "$line" ]; do
    encrypted_line=$(caesar_cipher "$line" "$shift_value")
    echo "$encrypted_line" >> "$output_file"
done < "$input_file"

echo "Encryption complete. Output written to $output_file"