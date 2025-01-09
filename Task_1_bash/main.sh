#!/bin/bash

# Function to calculate Fibonacci numbers
fib() {
    local n="$1"

    if [ "$n" -eq 0 ]; then
        echo 0
    elif [ "$n" -eq 1 ]; then
        echo 1
    else
        local prev1=0
        local prev2=1
        local current=0

        for (( i=2; i<=n; i++ ))
        do
            current=$((prev1 + prev2))
            prev1=$prev2
            prev2=$current
        done

        echo $current
    fi
}

# Write number to calculate as an argument of main function   ./main.sh "argument"
n="$1"
result=$(fib "$n")
echo "Result: $result"