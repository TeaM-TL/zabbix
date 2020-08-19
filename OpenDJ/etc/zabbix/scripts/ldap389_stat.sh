#!/bin/bash
# usage: ./ldap389_stat.sh "targetObjectName" "objectParam" {Level}

# Setting the variables of the working environment
LOG="/var/log/zabbix/zabbix-opendj-error.log"
PSWD=/etc/zabbix/scripts/.389-ds
PSWDM=/etc/zabbix/scripts/.389-dm
DATE=$(date +"%Y-%m-%d.%H:%M:%S")
LDAPSEARCH=/opt/opendj/bin/ldapsearch
unset ANSWER

# Checking for the expected utilities
[ -x "$(command -v $LDAPSEARCH)" ] || { echo "${DATE}: Necessary utilities were not found. The procedure for requesting statistics was interrupted" >> ${LOG}; exit 1; }

# We check the correctness of the entered data and display a hint in the event log, if necessary
OITARGET="${1}"
OIPARAM="${2}"
#
[ ! "${OITARGET}" ] && { echo "${DATE}: Request: \"$(basename $0) $@\". The subject is not specified. Status request interrupted." >> ${LOG}; exit 1; }
[ ! "${OIPARAM}" ] && { echo "${DATE}: Request: \"$(basename $0) $@\". The requested parameter was not specified. Status inquiry procedure aborted." >> ${LOG}; exit 1; }

# We use different approaches depending on the target object
if [[ "${OITARGET}" == "local" ]] ; then
  # Querying global server statistics
    case $OIPARAM in
        "currentconnections" ) ANSWER=$($LDAPSEARCH --port 4444 --useSsl --trustAll --bindDN "cn=Directory Manager" -j ${PSWDM} --baseDN "cn=monitor" --searchScope base "(objectClass=*)" currentConnections | grep -i currentconnections | awk '{print $2}') ;;
        "entriesno" ) ANSWER=$($LDAPSEARCH  --port 4444 --useSsl --trustAll --bindDN "cn=Directory Manager" -j ${PSWDM} --baseDN "cn=userRoot Backend,cn=monitor" --searchScope base "(objectClass=ds-backend-monitor-entry)" ds-backend-entry-count | grep -i ds-backend-entry-count | awk '{print $2}') ;;
        "missingchanges" ) RESULT=$($LDAPSEARCH  --port 4444 --useSsl --trustAll --bindDN "cn=Directory Manager" -j ${PSWDM} --baseDN "cn=Replication,cn=monitor" --searchScope sub "(objectClass=*)" missing-changes | grep -i missing-changes | awk '{print $2}'); ANSWER=0; for I in $RESULT; do if [ ! $I -eq 0 ]; then ANSWER=$(($ANSWER+$ANSWER)); fi; done;;
        "approximatedelay" ) RESULT=$($LDAPSEARCH  --port 4444 --useSsl --trustAll --bindDN "cn=Directory Manager" -j ${PSWDM} --baseDN "cn=Replication,cn=monitor" --searchScope sub "(objectClass=*)" approximate-delay | grep -i approximate-delay | awk '{print $2}'); ANSWER=0; for I in $RESULT; do if [ ! $I -eq 0 ]; then ANSWER=$(($ANSWER+$ANSWER)); fi; done ;;
        "alive" ) RESULT=$($LDAPSEARCH  --port 4444 --bindDN "cn=zabbix monitor,ou=services,dc=agm,dc=local" -j $PSWD --useSsl --trustAll --baseDN "dc=agm,dc=local" --searchScope base "(objectClass=*)" 1.1 | awk '{print $2}'); ANSWER=0; if [ $RESULT == "dc=agm,dc=local" ]; then ANSWER=1; fi ;;
        *) echo "0"
    esac
fi

# We return the value of the requested parameter (we do not answer anything if the parameter is not supported)
# (it is important to give the value without enclosing it in quotes, otherwise the zero value will not reach "Zabbix")
[ ! -z "${ANSWER}" ] && echo ${ANSWER}

exit ${?}

