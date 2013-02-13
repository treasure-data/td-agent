#!/bin/sh
### BEGIN INIT INFO
# Provides:          td-agent
# Required-Start:    $network $local_fs
# Required-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: data collector for Treasure Data
# Description:       Treasure Data Support <support@treasure-data.com>
### END INIT INFO

# Author: Kazuki Ohta <k@treasure-data.com>

# PATH should only include /usr/* if it runs after the mountnfs.sh script
PATH=/sbin:/usr/sbin:/bin:/usr/bin
USER=td-agent                   # Running user
GROUP=td-agent                  # Running group
DESC=td-agent                   # Introduce a short description here
NAME=td-agent                   # Introduce the short server's name here
PIDFILE=/var/run/$NAME/$NAME.pid
DAEMON=/usr/lib/fluent/ruby/bin/ruby # Introduce the server's location here
# Arguments to run the daemon with
DAEMON_ARGS="/usr/sbin/td-agent --daemon $PIDFILE --log /var/log/td-agent/td-agent.log"
SCRIPTNAME=/etc/init.d/$NAME
START_STOP_DAEMON_ARGS=""

# Exit if the package is not installed
[ -x $DAEMON ] || exit 0

# Read configuration variable file if it is present
[ -r /etc/default/$NAME ] && . /etc/default/$NAME

# Load the VERBOSE setting and other rcS variables
# . /lib/init/vars.sh

# Define LSB log_* functions.
# Depend on lsb-base (>= 3.0-6) to ensure that this file is present.
. /lib/lsb/init-functions

# Check the user
if [ -n "${USER}" ]; then
	if ! getent passwd | grep -q "^${USER}:"; then
		echo "$0: user for running td-agent doesn't exist: ${USER}" >&2
		exit 1
	fi
	if [ ! -d $(dirname ${PIDFILE}) ]; then
		mkdir -p $(dirname ${PIDFILE})
	fi
	chown -R ${USER} $(dirname ${PIDFILE})
	START_STOP_DAEMON_ARGS="${START_STOP_DAEMON_ARGS} -c ${USER}"
fi
if [ -n "${GROUP}" ]; then
	if ! getent group | grep -q "^${GROUP}:"; then
		echo "$0: group for running td-agent doesn't exist: ${GROUP}" >&2
		exit 1
	fi
	START_STOP_DAEMON_ARGS="${START_STOP_DAEMON_ARGS} --group ${GROUP}"
fi

# 2012/04/17 Kazuki Ohta <k@treasure-data.com>
# Use jemalloc to avoid memory fragmentation
if [ -f "/usr/lib/fluent/jemalloc/lib/libjemalloc.so" ]; then
	export LD_PRELOAD=/usr/lib/fluent/jemalloc/lib/libjemalloc.so
fi

#
# Function that starts the daemon/service
#
do_start()
{
	# 2012/07/23 Kazuki Ohta <k@treasure-data.com>
	# Set Max number of file descriptors for the safety sake
	ulimit -n 8192

	# Return
	#   0 if daemon has been started
	#   1 if daemon was already running
	#   2 if daemon could not be started
	start-stop-daemon --start --quiet --pidfile $PIDFILE --exec $DAEMON \
	${START_STOP_DAEMON_ARGS} --test > /dev/null \
		|| return 1
	start-stop-daemon --start --quiet --pidfile $PIDFILE --exec $DAEMON \
	${START_STOP_DAEMON_ARGS} -- $DAEMON_ARGS \
		|| return 2
	# Add code here, if necessary, that waits for the process to be ready
	# to handle requests from services started subsequently which depend
	# on this one.  As a last resort, sleep for some time.
}

#
# Function that stops the daemon/service
#
do_stop()
{
	# Return
	#   0 if daemon has been stopped
	#   1 if daemon was already stopped
	#   2 if daemon could not be stopped
	#   other if a failure occurred
	start-stop-daemon --stop --quiet --retry=TERM/30/KILL/5 --pidfile $PIDFILE --name ruby
	RETVAL="$?"
	[ "$RETVAL" = 2 ] && return 2
	# Wait for children to finish too if this is a daemon that forks
	# and if the daemon is only ever run from this initscript.
	# If the above conditions are not satisfied then add some other code
	# that waits for the process to drop all resources that could be
	# needed by services started subsequently.  A last resort is to
	# sleep for some time.
	start-stop-daemon --stop --quiet --oknodo --retry=0/30/KILL/5 --exec $DAEMON
	[ "$?" = 2 ] && return 2
	# Many daemons don't delete their pidfiles when they exit.
	rm -f $PIDFILE
	return "$RETVAL"
}

#
# Function that sends a SIGHUP to the daemon/service
#
do_reload() {
	#
	# If the daemon can reload its configuration without
	# restarting (for example, when it is sent a SIGHUP),
	# then implement that here.
	#
	start-stop-daemon --stop --signal 1 --quiet --pidfile $PIDFILE --name ruby
	return 0
}

case "$1" in
  start)
    [ "$VERBOSE" != no ] && log_daemon_msg "Starting $DESC " "$NAME"
    do_start
    case "$?" in
		0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
		2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
	esac
  ;;
  stop)
	[ "$VERBOSE" != no ] && log_daemon_msg "Stopping $DESC" "$NAME"
	do_stop
	case "$?" in
		0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
		2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
	esac
	;;
  status)
       status_of_proc "$DAEMON" "$NAME" && exit 0 || exit $?
       ;;
  #reload|force-reload)
	#
	# If do_reload() is not implemented then leave this commented out
	# and leave 'force-reload' as an alias for 'restart'.
	#
	#log_daemon_msg "Reloading $DESC" "$NAME"
	#do_reload
	#log_end_msg $?
	#;;
  restart|force-reload)
	#
	# If the "reload" option is implemented then remove the
	# 'force-reload' alias
	#
	log_daemon_msg "Restarting $DESC" "$NAME"
	do_stop
	case "$?" in
	  0|1)
		do_start
		case "$?" in
			0) log_end_msg 0 ;;
			1) log_end_msg 1 ;; # Old process is still running
			*) log_end_msg 1 ;; # Failed to start
		esac
		;;
	  *)
	  	# Failed to stop
		log_end_msg 1
		;;
	esac
	;;
  *)
	#echo "Usage: $SCRIPTNAME {start|stop|restart|reload|force-reload}" >&2
	echo "Usage: $SCRIPTNAME {start|stop|status|restart|force-reload}" >&2
	exit 3
	;;
esac

:
