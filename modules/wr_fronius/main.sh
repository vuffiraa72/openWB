#!/bin/bash
OPENWBBASEDIR=$(cd "$(dirname $0)"/../../ && pwd)
RAMDISKDIR="${OPENWBBASEDIR}/ramdisk"
#DMOD="PV"
DMOD="MAIN"

if [ ${DMOD} == "MAIN" ]; then
	MYLOGFILE="${RAMDISKDIR}/openWB.log"
else
	MYLOGFILE="${RAMDISKDIR}/nurpv.log"
fi

# check if config file is already in env
if [[ -z "$debug" ]]; then
	echo "wr_fronius: Seems like openwb.conf is not loaded. Reading file."
	# try to load config
	. $OPENWBBASEDIR/loadconfig.sh
	# load helperFunctions
	. $OPENWBBASEDIR/helperFunctions.sh
fi

inverter_num=${1:-1}
[[ "inverter_num" -gt 1 ]] && config_prefix="wr$1" || config_prefix="wr"
[[ "inverter_num" -gt 1 ]] && pv_num_str="$1" || pv_num_str=""
declare -n "config_ip=${config_prefix}froniusip"
[[ "$inverter_num" -eq 1 ]] && declare -n "config_ip2=${config_prefix}fronius2ip" || config_ip2="none"
[[ "$inverter_num" -eq 1 ]] && declare -n "config_battery=speichermodul" || config_battery="none"
 
openwbDebugLog ${DMOD} 2 "WR IP: ${config_ip}"
openwbDebugLog ${DMOD} 2 "WR IP2: ${config_ip2}"
openwbDebugLog ${DMOD} 2 "WR Speicher: ${config_battery}"

bash "$OPENWBBASEDIR/packages/legacy_run.sh" "modules.fronius.device" "inverter" "${config_ip}" "0" "0" "0" "${config_ip2}" "${config_battery}" "${inverter_num}" 2>>$MYLOGFILE

pvwatt=$(</var/www/html/openWB/ramdisk/pv${pv_num_str}watt) 
echo $pvwatt
