#
# Regular cron jobs for the td-agent package
#
0 4	* * *	root	[ -x /usr/bin/td-agent_maintenance ] && /usr/bin/td-agent_maintenance
