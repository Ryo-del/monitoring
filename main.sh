#!/bin/bash

warning=false
disk_message=""
cpu_message=""
temp_message=""
ram_message=""


maxdisk=90      
maxcpu=50      
maxtemp=70      
maxram=80      

disk=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%' 2>/dev/null)
if [[ -z "$disk" ]]; then
    disk_message="❌ Error: Could not get disk usage"
elif [[ "$disk" -gt "$maxdisk" ]]; then
    disk_message="⚠️ Warning: Disk space is low! ($disk% used)"
    warning=true
else
    disk_message="✅ Disk - OK ($disk% used)"
fi


cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}' | cut -d. -f1)
if [[ -z "$cpu_usage" ]]; then

    cpu_usage=$(mpstat 1 1 | awk 'END{printf "%.0f", 100 - $NF}' 2>/dev/null || echo "0")
fi

if [[ -z "$cpu_usage" ]]; then
    cpu_message="❌ Error: Could not determine CPU usage"
elif [[ "$cpu_usage" -gt "$maxcpu" ]]; then
    cpu_message="⚠️ Warning: CPU overloaded ($cpu_usage% used)"
    warning=true
else
    cpu_message="✅ CPU - OK ($cpu_usage% used)"
fi


temp="N/A"
temp_file="/sys/class/thermal/thermal_zone0/temp"
if [[ -f "$temp_file" ]]; then
    temp_raw=$(cat "$temp_file" 2>/dev/null)
    if [[ -n "$temp_raw" ]]; then
        temp=$((temp_raw/1000))
        if [[ "$temp" -gt "$maxtemp" ]]; then
            temp_message="⚠️ Warning: High temperature: $temp °C"
            warning=true
        else
            temp_message="✅ Temperature: $temp °C"
        fi
    else
        temp_message="❌ Failed to read temperature data"
    fi
else
    temp_message="❌ Temperature sensor not found"
fi


ram_usage=$(free -m | awk '/Mem:/ {printf "%.0f", $3/$2*100}' 2>/dev/null)
if [[ -z "$ram_usage" ]]; then
    ram_message="❌ Error: Could not determine RAM usage"
else
    if [[ "$ram_usage" -gt "$maxram" ]]; then
        ram_message="⚠️ High RAM usage: $ram_usage%"
        warning=true
    else
        ram_message="✅ Normal RAM usage: $ram_usage%"
    fi
fi


if [[ "$warning" = true ]]; then
    echo -e "\n=== SYSTEM STATUS REPORT ==="
    echo "-------------------------"
    echo "🖴 $disk_message"
    echo "🖥️ $cpu_message"
    echo "🌡️ $temp_message"
    echo "🧠 $ram_message"
    echo "-------------------------"
    echo -e "⚠️ Warnings detected! Please check your system.\n"
else
    echo -e "\n=== SYSTEM STATUS: ALL OK ==="
    echo "-------------------------"
    echo "🖴 $disk_message"
    echo "🖥️ $cpu_message"
    echo "🌡️ $temp_message"
    echo "🧠 $ram_message"
    echo "-------------------------"
    echo -e "✅ System parameters are normal.\n"
fi
