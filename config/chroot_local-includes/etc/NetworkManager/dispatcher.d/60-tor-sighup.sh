#! /bin/sh

# Run only when the interface is not "lo":
if [[ $1 = "lo" ]]; then
   exit 0
fi

# Run whenever an interface gets "up", not otherwise:
if [[ $2 != "up" ]]; then
   exit 0
fi

PIDFILE=/var/run/tor/tor.pid

if [ -r "${PIDFILE}" ]; then
    # A SIGHUP should be enough but there's a bug in Tor. Details:
    # * https://bugs.torproject.org/flyspray/index.php?do=details&id=1247
    # * https://amnesia.boum.org/bugs/tor_vs_networkmanager/
    /etc/init.d/tor restart
    # Restart Vidalia because it does not automatically reconnect to the new
    # Tor instance. Use kill+start as X-GNOME-AutoRestart does not exist in
    # Lenny's Gnome.
    if killall vidalia ; then
       sleep 2 # give lckdo a chance to release the lockfile
       export DISPLAY=':0.0'
       exec /bin/su -c /usr/local/bin/vidalia-wrapper amnesia &
    fi
else
    /etc/init.d/tor start
fi