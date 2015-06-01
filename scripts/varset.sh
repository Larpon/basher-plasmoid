#!/bin/bash
#
#  Copyright 2015  Lars Pontoppidan <leverpostej@gmail.com>
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
 

function join { local IFS="$1"; shift; echo "$*"; }

# Environment / Linux OS specific
ENV_OS=`lsb_release -si`
ENV_ARCH=`uname -m | sed 's/x86_//;s/i[3-6]86/32/'`
ENV_OS_VERSION=`lsb_release -sr`;
ENV_BITS=`file /usr/bin/uptime | awk '{print $3}'`
ENV_UPTIME=`uptime | awk '{print $3}' | rev | cut -c 2- | rev`
ENV_USER=`whoami`
ENV_HOST=`hostname`

# CPU specific
CPU_MODEL_NAME=`cat /proc/cpuinfo | grep -m 1 'model name' | sed -e 's/.*: //'`
CPU_CORES=`cat /proc/cpuinfo | grep -m 1 "cpu cores" | awk '{print $4}'`
CPU_VIRTUAL_CORES=`cat /proc/stat | grep cpu | wc -l`; let "CPU_VIRTUAL_CORES=CPU_VIRTUAL_CORES-1"
CPU_LOAD_TOTAL=`top -bn 1 | awk 'NR>7{s+=$9} END {print s/$CPU_VIRTUAL_CORES}'`

cpu_raw_previous_file="/tmp/basher_cpu_raw_previous.txt"
cpus_load=()
IFS=$'\n'


#if [ -f "$cpu_raw_previous_file" ]; then
#    readarray cpus_raw_previous < "$cpu_raw_previous_file"
#else
    cpus_raw_previous=($(cat /proc/stat | grep "cpu[0-9]"))
    sleep 0.2
#fi

cpus_raw_now=($(cat /proc/stat | grep "cpu[0-9]"))
#printf "%s\n" "${cpus_raw_now[@]}" > "$cpu_raw_previous_file"

for cpuindex in ${!cpus_raw_now[@]}; do
    cpuline_previous=${cpus_raw_previous[$cpuindex]}
    cpuline_now=${cpus_raw_now[$cpuindex]}
    #echo "$cpuindex -> ${cpus_raw_now[$cpuindex]} [2]"
    # cpus_load+=($(echo "scale=1; (100 * ($B0 - $D0 - ${A[4]}   + ${C[4]})  / ($B0 - $D0))" | bc))
    # ${foo[$cpuline]}
    
    cpu_user_previous=$(echo $cpuline_previous | awk '{print $2}')
    cpu_nice_previous=$(echo $cpuline_previous | awk '{print $3}')
    cpu_sys_previous=$(echo $cpuline_previous | awk '{print $4}')
    cpu_idle_previous=$(echo $cpuline_previous | awk '{print $5}')
    cpu_previous=$(echo "scale=1; ($cpu_user_previous + $cpu_nice_previous + $cpu_sys_previous + $cpu_idle_previous)" | bc)
    
    cpu_user_now=$(echo $cpuline_now | awk '{print $2}')
    cpu_nice_now=$(echo $cpuline_now | awk '{print $3}')
    cpu_sys_now=$(echo $cpuline_now | awk '{print $4}')
    cpu_idle_now=$(echo $cpuline_now | awk '{print $5}')
    cpu_now=$(echo "scale=1; ($cpu_user_now + $cpu_nice_now + $cpu_sys_now + $cpu_idle_now)" | bc)
    
    cpu_usage=$(echo "scale=1; (($cpu_user_now - $cpu_user_previous) + ($cpu_nice_now - $cpu_nice_previous) + ($cpu_sys_now - $cpu_sys_previous))" | bc)
    cpu_total=$(echo "scale=1; ($cpu_usage + ($cpu_idle_now - $cpu_idle_previous))" | bc)
    
    cpu_percent=0
    if [ "$cpu_total" -gt 0 ]; then
        cpu_percent=$(echo "scale=1; (100 * $cpu_usage / $cpu_total)" | bc)
    fi    
    #echo "$cpu_user $cpu_nice $cpu_sys $cpu_idle der $cpu_now vs. $cpu_previous"
    cpus_load[$cpuindex]=$cpu_percent
    
done
unset IFS

CPU_LOAD_CORES=$(join " " ${cpus_load[@]})
