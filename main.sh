#!/bin/bash

warning=false
disk_message=""
cpu_message=""
temp_message=""
ram_message=""

# Проверка диска
disk=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')
if [ "$disk" -gt 90 ]; then
    disk_message="⚠️ Warning: Disk space is low! ($disk% used)"
    warning=true
else
    disk_message="✅ Disk - OK ($disk% used)"
fi

# Проверка CPU
cpu=$(mpstat 1 1 | awk 'END{printf "%.0f", 100 - $NF}' 2>/dev/null || echo "0")
if [ -z "$cpu" ] || [ "$cpu" -gt 20 ]; then 
    cpu_message="⚠️ Warning: CPU overloaded ($cpu% used)"
    warning=true
else
    cpu_message="✅ CPU - OK ($cpu% used)"
fi

# Проверка температуры
temp="N/A"
if [ -f "/sys/class/thermal/thermal_zone0/temp" ]; then
    temp=$(($(cat /sys/class/thermal/thermal_zone0/temp)/1000))
    if [ "$temp" -gt 70 ]; then  
        temp_message="⚠️ Warning: Temperature: $temp °C"
        warning=true
    else
        temp_message="✅ Temperature: $temp °C"
    fi
else
    temp_message="❌ Temperature data unavailable"
fi

# Проверка RAM
ram_usage=$(LANG=C free 2>/dev/null | awk '/Mem/{printf "%.0f", $3/$2*100}' || echo "0")
if [ -z "$ram_usage" ]; then
    ram_message="❌ Error: Could not determine RAM usage"
else
    if [ "$ram_usage" -gt 80 ]; then  
        ram_message="⚠️ High RAM usage: $ram_usage%"
        warning=true
    else
        ram_message="✅ Normal RAM usage: $ram_usage%"
    fi
fi

# Вывод результатов
if [ "$warning" = true ]; then
    echo "SYSTEM STATUS REPORT:"
    echo "===================="
    echo "$disk_message"
    echo "$cpu_message"
    echo "$temp_message"
    echo "$ram_message"
    echo "===================="
    echo "⚠️ Warnings detected! Please check your system."

fi