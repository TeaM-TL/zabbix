# Monitoring OpenDJ a LDAP server

## Origin
ported from: http://www.umgum.com/zabbix-ldap-389

## What is monitored
- number of current connections
- number of entries in database
- is alive: is Running (1=OK)
- port LDAP is Listening (1=OK)
- port LDAPS is Listening (1=OK)
- Replication approximate-delay (0=OK)
- Replication missing-changes (0=OK)

## Triggers
- High - Number of entries in database is too less (<10)
- High - OpenDJ is DOWN
- High - Port LDAP is DOWN
- High - Port LDAPS is DOWN
- High - Replication approximate delay
- High - Replication missing changes

## To Do
- mode details to monitor
- monitor on 4444 port
- monitor as unprivileged user
- monitor dosk space
- better code
- and other
