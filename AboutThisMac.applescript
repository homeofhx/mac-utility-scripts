# About This Mac - Revision 6 - Author: Harry Xie

set modelID to do shell script "sysctl -n hw.model"
set modelNum to do shell script "system_profiler SPHardwareDataType | awk '/Model Number/ {print $3}'"
set sn to do shell script "ioreg -l | awk '/IOPlatformSerialNumber/ {print $4}' | tr -d '\"'"
set cpuModel to do shell script "sysctl -n machdep.cpu.brand_string"
set phyCores to do shell script "sysctl -n hw.physicalcpu"
set logCores to do shell script "sysctl -n hw.logicalcpu"
set mem to do shell script "system_profiler SPHardwareDataType | grep \" Memory:\" | awk '{print $2}'"
set eachMemSize to do shell script "system_profiler SPMemoryDataType | awk '/Size:/ {sizes = (sizes == \"\" ? \"\" : sizes \", \") $2$3} END {print sizes}'"
set memMfg to do shell script "system_profiler SPMemoryDataType | grep \"Manufacturer:\" | awk '{print $2}' | xargs | sed 's/ /, /g'"
set storage to do shell script "diskutil info disk0 | grep \"Disk Size\" | awk '{print $3$4}'"
set gpus to do shell script "system_profiler SPDisplaysDataType | grep \"Chipset Model\" | awk -F': ' '{ if (NR == 1) {chipsets = $2} else {chipsets = chipsets \", \" $2} } END {print chipsets}'"
set gpuCores to do shell script "ioreg -l | grep \"gpu-core-count\" | awk '{print $NF}'"
set pwrSrc to do shell script "pmset -g batt | awk '/Now drawing from/ {print $4, $5}' | tr -d \"'\""
set battHealthCdt to do shell script "system_profiler SPPowerDataType | grep \"Condition\" | awk -F': ' '{print $2}'"
set battCycles to do shell script "system_profiler SPPowerDataType | grep \"Cycle Count\" | awk '{print $3}'"
set battDesCap to do shell script "ioreg -l | awk -F' = ' '/(DesignCapacity)/ {gsub(\"\\\"\",\"\"); print $2}' | tail -n 1"
set battCurrCap to do shell script "ioreg -l | awk -F' = ' '/(AppleRawMaxCapacity)/ {gsub(\"\\\"\",\"\"); print $2}'"
set battHealthPct to do shell script "system_profiler SPPowerDataType | awk '/Maximum Capacity:/ {print $3}' | sed 's/%//' | sed 's/$/%/'"
set chgWatts to (do shell script "watt=$(system_profiler SPPowerDataType | grep \"Wattage (W):\" | awk '{print $3}'); if [ -z \"$watt\" ]; then echo \"NOT CHARGING\"; else echo \"$watt\"; fi")
set chgInfo to do shell script "system_profiler SPPowerDataType | awk '/AC Charger Information:/,/  ChgInf:/ { if ($1 ~ /Manufacturer:/) { mfg=$0; gsub(/^[ 	]*Manufacturer: /, \"\", mfg); } if ($1 ~ /Name:/) name=$2\" \"$3\" \"$4\" \"$5\" \"$6\" \"$7\" \"$8; } END { if (mfg && name) print mfg\", \"name; else print \"CANNOT READ OR NOT CHARGING\"; }'"
set ctType to do shell script "networksetup -listallhardwareports | grep -C 1 $(route get default | grep interface | awk '{print $2}') | awk -F: '/Hardware Port/{print $2}' | sed 's/^[[:space:]]*//'"
set wifiCh to do shell script "system_profiler SPAirPortDataType | grep \"Channel:\" | awk -F: '{print $2}' | sed 's/^[[:space:]]*//' | head -n 1"
set wifiCt to do shell script "system_profiler SPAirPortDataType | grep \"Country Code:\" | awk -F: '{print $2}' | sed 's/^[[:space:]]*//' | head -n 1"
set iclStatus to do shell script "system_profiler SPHardwareDataType | grep \"Activation Lock Status\" | awk '{print $NF}'"
set devmngStatus to do shell script "profiles status -type enrollment | grep -oE 'Yes|No' | paste -s -d '/' -"
set pfCount to do shell script "profiles list 2>/dev/null | grep -c 'profileIdentifier:'; exit 0" with administrator privileges

display dialog "This is: " & modelID & " " & modelNum & return & Â
	"Serial Number: " & sn & return & return & Â
	"--- GENERAL INFORMATION ---" & return & Â
	"Processor: " & cpuModel & ", " & phyCores & " cores, " & logCores & " threads" & return & Â
	"Memory: " & mem & "GB" & return & Â
	"Each Memory Slot's Size: " & eachMemSize & return & Â
	"Memory Manufacturer(s): " & memMfg & return & Â
	"Internal Hard Drive's Capacity: " & storage & return & Â
	"Attached GPUs: " & gpus & return & Â
	"GPU Cores (ARM Macs): " & gpuCores & return & return & Â
	"--- BATTERY & POWER ---" & return & Â
	"Power Source: " & pwrSrc & return & Â
	"Battery Health Condition: " & battHealthCdt & " " & battHealthPct & return & Â
	"Battery Charge Cycles: " & battCycles & return & Â
	"Battery Designed/Current Capacity: " & battDesCap & "/" & battCurrCap & return & Â
	"Charging Wattage: " & chgWatts & return & Â
	"Charger Info: " & chgInfo & return & return & Â
	"--- NETWORK & CONNECTION ---" & return & Â
	"Connection Type: " & ctType & return & Â
	"Connected Wi-Fi Channel: " & wifiCh & return & Â
	"Country Code: " & wifiCt & return & return & Â
	"--- LOCKS & MANAGEMENTS ---" & return & Â
	"iCloud Activation Lock: " & iclStatus & return & Â
	"DEP/MDM Enrollment: " & devmngStatus & return & Â
	"Number of Installed Profiles: " & pfCount