#!/bin/bash
#
# Script to test CDN connectivity and response time between a host and the RedHat CDN
#
# Usage: ./rhn-cdn-connect.sh
#

#--- Proxy Host/Port Definition -----------------------
PRXHOST=""
PRXPORT=""
#--- Proxy User/Pass Definition --(If Necessary)-------
PRXUSER=""
PRXPASS=""
#------------------------------------------------------

#--- Auto Key Discovery -------------------------------
CERT=`ls -art -1 /etc/pki/entitlement/*.pem | grep -Ev "\-key"| tail -n1`
KEY=`ls -art -1 /etc/pki/entitlement/*.pem | grep -E "\-key" | tail -n1`
#--- Manual Key Definition ----------------------------
#CERT="/etc/pki/entitlement/[NUMBER].pem"
#KEY="/etc/pki/entitlement/[NUMBER]-key.pem"
#------------------------------------------------------

#--- Custom Verbosity Level ---------------------------
VERBOSITY="-v"
#VERBOSITY="--trace -"
#VERBOSITY="--trace-ascii -"
#------------------------------------------------------

#--- URLs to be retrieved -----------------------------
URLLIST='https://cdn.redhat.com:443/content/dist/rhel/server/6/6.1/listing
https://cdn.redhat.com:443/content/dist/rhel/server/6/6.2/listing
https://cdn.redhat.com:443/content/dist/rhel/server/6/6.3/listing
https://cdn.redhat.com:443/content/dist/rhel/server/6/6.4/listing
https://cdn.redhat.com:443/content/dist/rhel/server/6/6.5/listing
https://cdn.redhat.com:443/content/dist/rhel/server/6/6.6/listing
https://cdn.redhat.com:443/content/dist/rhel/server/6/6.7/listing
'

cdn_connect() {
	URL="$1"
	if [[ ${PRXHOST} -eq "" ]];then
		PROXY=""
	else
		if [[ ${PRXUSER} -eq "" ]];then
			PROXY="--proxy ${PRXHOST}:${PRXPORT}"
		else
			PROXY="--proxy ${PRXHOST}:${PRXPORT} --proxy-user ${PRXUSER}:${PRXPASS}"
		fi
	fi

	if [[ ${PROXY} -eq "" ]];then
		COMMAND="curl -sS ${VERBOSITY} \\ \n             --cacert /etc/rhsm/ca/redhat-uep.pem \\ \n             --cert ${CERT} \\ \n             --key ${KEY} \\ \n             ${URL}"
	else
		COMMAND="curl -sS ${VERBOSITY} \\ \n             --cacert /etc/rhsm/ca/redhat-uep.pem \\ \n             --cert ${CERT} \\ \n             --key ${KEY} \\ \n             ${PROXY} \\ \n             ${URL}"
	fi

	echo -e "    Running: ${COMMAND}"
	echo -e
	echo -e "    Iteration(${ICOUNT}) Start Time:	`date "+%Y-%m-%d - %H:%M:%S.%N"`"
	echo -e
	curl -sS ${VERBOSITY} \
		--cacert /etc/rhsm/ca/redhat-uep.pem \
		--cert ${CERT} \
		--key ${KEY} \
		${PROXY} \
		-w "\n- SSL Handshake: %{time_appconnect}\n- Host Connect: %{time_connect}\n- DNS Lookup: %{time_namelookup}\n- Redirect Time: %{time_redirect}\n- Pre-Response Time: %{time_pretransfer}\n- Total Time: %{time_total}\n" \
		${URL} 2>&1 | sed -r 's/^/    /g'
	echo -e
	echo -e "    Iteration(${ICOUNT}) Finish Time:	`date "+%Y-%m-%d - %H:%M:%S.%N"`"
}

ICOUNT=0

# Sanity checks
if [[ ! -f "/etc/rhsm/ca/redhat-uep.pem" ]];then
	echo -e "Error: Missing Red Hat Subscription Management CA Certificate [/etc/rhsm/ca/redhat-uep.pem]!"
	exit 1
elif [[ `ls -1 /etc/pki/entitlement | grep -E "*.pem" | wc -l` -lt 1 ]];then
	echo -e "Error: Missing Red Hat entitlement certificate(s) [/etc/pki/entitlement/*.pem]!"
	exit 2
else
	echo -e "---------------------------------------------------------------------------------------------------------------------------------"
	echo -e "RHN CDN Connection Test"
	echo -e "---------------------------------------------------------------------------------------------------------------------------------"
	echo -e "Global Start Time:	`date "+%Y-%m-%d - %H:%M:%S.%N"`"
	for URL in ${URLLIST};do
		ICOUNT=`expr ${ICOUNT} + 1`
		echo -e "  --- Iteration ${ICOUNT} --------------------------------------------------------"
		echo -e "  ------------------------------------------------------------------------"
		cdn_connect ${URL}
		echo -e "  ------------------------------------------------------------------------"
	done
	echo -e
	echo -e "---------------------------------------------------------------------------------------------------------------------------------"
	echo -e "Global Finish Time:	`date "+%Y-%m-%d - %H:%M:%S.%N"`"
	echo -e "---------------------------------------------------------------------------------------------------------------------------------"
fi
