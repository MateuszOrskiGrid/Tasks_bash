#!/bin/bash

# Report
REPORT_FILE="system_report_$(date +%Y%m%d_%H%M%S).txt"

# external IP
get_external_ip() {
    curl -s ifconfig.me || wget -qO- ifconfig.me
}

{
    echo "System Report"
    echo "============="
    echo
    
    # Current date and time
    echo "Date and Time: $(date '+%Y-%m-%d %H:%M:%S')"
    echo
    
    # Current user
    echo "Current User: $USER"
    echo
    
    # Internal IP and hostname
    echo "Hostname: $(hostname)"
    echo "Internal IP: $(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -n1)"
    echo
    
    # External IP
    echo "External IP: $(get_external_ip)"
    echo
    
    # Linux
    echo "System Version:"
    if [ -f /etc/os-release ]; then
        cat /etc/os-release | grep -E "^(NAME|VERSION)="
    elif [ -f /System/Library/CoreServices/SystemVersion.plist ]; then
        sw_vers
    else
        uname -rs
    fi
    echo
    
    # uptime
    echo "System Uptime:"
    uptime
    echo
    
    # Disk
    echo "Disk Space Usage (/):"
    df -h / | awk 'NR==2 {print "Total: " $2 "\nUsed: " $3 "\nFree: " $4}'
    echo
    
    # RAM
    echo "RAM Information:"
    if [ "$(uname)" = "Darwin" ]; then
        total_ram=$(sysctl -n hw.memsize | awk '{ printf "%.2f", $1/1024/1024/1024 }')
        used_ram=$(vm_stat | perl -ne '/page size of (\d+)/ and $size=$1; /Pages active: (\d+)/ and $active=$1; /Pages wired down: (\d+)/ and $wired=$1; END { printf "%.2f\n", ($active+$wired)*$size/1024/1024/1024 }')
        free_ram=$(echo "$total_ram - $used_ram" | bc)
        echo "Total: ${total_ram}G"
        echo "Used: ${used_ram}G"
        echo "Free: ${free_ram}G"
    else
        vmstat | awk 'NR==3 {printf "Free: %dM\n", $4/1024}'
    fi
    echo
    
    # CPU
    echo "CPU Information:"
    if [ "$(uname)" = "Darwin" ]; then
        echo "Number of CPU cores: $(sysctl -n hw.ncpu)"
        echo "CPU Frequency: $(sysctl -n hw.cpufrequency | awk '{printf "%.2f GHz\n", $1/1000000000}')"
    else
        echo "Number of CPU cores: $(sysctl -n hw.ncpu 2>/dev/null || echo "Unable to determine")"
        echo "CPU Information:"
        sysctl -a | grep -i "cpu.*freq" 2>/dev/null || echo "CPU frequency information unavailable"
    fi
    
} > "$REPORT_FILE"

echo "Report has been generated: $REPORT_FILE"