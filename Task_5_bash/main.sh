#!/bin/bash

# Instructions
usage() {
    printf "Usage: %s [-v] [-s <A_WORD> <B_WORD>] [-r] [-l] [-u] -i <input file> -o <output file>\n" "$0"
    printf "Options:\n"
    printf "  -v: Invert case (lowercase to uppercase and vice versa)\n"
    printf "  -s: Substitute A_WORD with B_WORD (case sensitive)\n"
    printf "  -r: Reverse text lines\n"
    printf "  -l: Convert text to lowercase\n"
    printf "  -u: Convert text to uppercase\n"
    printf "  -i: Input file\n"
    printf "  -o: Output file\n"
    exit 1
}

# Substitution of words
substitute_with_sed() {
    echo "Substituting '$aword' with '$bword' in '$input'"
    sed -E "s/(^|[^[:alnum:]])$aword([^[:alnum:]]|$)/\1$bword\2/g" "$input" > "$output.tmp"
    mv "$output.tmp" "$output"
}

# Invert
invert_case() {
    awk '{
        for (i = 1; i <= length($0); i++) {
            char = substr($0, i, 1)
            if (char ~ /[a-z]/) printf toupper(char)
            else if (char ~ /[A-Z]/) printf tolower(char)
            else printf char
        }
        printf "\n"
    }' "$input" > "$output.tmp"
    mv "$output.tmp" "$output"
}

# Reverse
reverse_lines() {
    tac "$input" > "$output.tmp"
    mv "$output.tmp" "$output"
}

# lowercase
to_lowercase() {
    tr '[:upper:]' '[:lower:]' < "$input" > "$output.tmp"
    mv "$output.tmp" "$output"
}

# uppercase
to_uppercase() {
    tr '[:lower:]' '[:upper:]' < "$input" > "$output.tmp"
    mv "$output.tmp" "$output"
}

substitute=false
invert=false
reverse=false
to_lower=false
to_upper=false
input=""
output=""
aword=""
bword=""

# Parser
while [[ $# -gt 0 ]]; do
    case "$1" in
        -s) substitute=true; aword="$2"; bword="$3"; shift 3 ;;
        -v) invert=true; shift ;;
        -r) reverse=true; shift ;;
        -l) to_lower=true; shift ;;
        -u) to_upper=true; shift ;;
        -i) input="$2"; shift 2 ;;
        -o) output="$2"; shift 2 ;;
        *) usage ;;
    esac
done

if [[ -z "$input" || -z "$output" ]]; then
    printf "Error: Input and output files must be specified.\n" >&2
    usage
fi

if [[ ! -f "$input" ]]; then
    printf "Error: Input file '%s' does not exist.\n" "$input" >&2
    exit 1
fi

# Input file
cp "$input" "$output"

if [[ "$substitute" == true ]]; then
    substitute_with_sed
fi
if [[ "$invert" == true ]]; then
    invert_case
fi
if [[ "$reverse" == true ]]; then
    reverse_lines
fi
if [[ "$to_lower" == true ]]; then
    to_lowercase
fi
if [[ "$to_upper" == true ]]; then
    to_uppercase
fi

printf "Processing complete. Output written to %s\n" "$output"
