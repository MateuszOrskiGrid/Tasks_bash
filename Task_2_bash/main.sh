#!/bin/bash

DEBUG=false

while [[ $# -gt 0 ]]; do
  case $1 in
    -o)
      OPERATION=$2
      shift 2
      ;;
    -n)
      NUMBERS=()
      shift
      while [[ $# -gt 0 && $1 != -* ]]; do
        NUMBERS+=("$1")
        shift
      done
      ;;
    -d)
      DEBUG=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

if [[ -z $OPERATION || ${#NUMBERS[@]} -eq 0 ]]; then
  echo "Usage: $0 -o <operation> -n <numbers> [-d]"
  exit 1
fi

RESULT=${NUMBERS[0]}
for ((i = 1; i < ${#NUMBERS[@]}; i++)); do
  case $OPERATION in
    +)
      RESULT=$((RESULT + ${NUMBERS[i]}))
      ;;
    -)
      RESULT=$((RESULT - ${NUMBERS[i]}))
      ;;
    \*)
      RESULT=$((RESULT * ${NUMBERS[i]}))
      ;;
    /)
      if [ "${NUMBERS[i]}" -eq 0 ]; then
        echo "Error: Division by zero"
        exit 1
      fi
      RESULT=$((RESULT / ${NUMBERS[i]}))
      ;;
    *)
      echo "Error: Unsupported operation '$OPERATION'"
      exit 1
      ;;
  esac
done

if $DEBUG; then
  echo "User: $(whoami)"
  echo "Script: $0"
  echo "Operation: $OPERATION"
  echo "Numbers: ${NUMBERS[*]}"
fi

echo "Result: $RESULT"