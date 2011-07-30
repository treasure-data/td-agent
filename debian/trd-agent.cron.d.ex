#
# Regular cron jobs for the trd-agent package
#
0 4	* * *	root	[ -x /usr/bin/trd-agent_maintenance ] && /usr/bin/trd-agent_maintenance
