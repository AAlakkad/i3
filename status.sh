#!/bin/sh

# ------------------------------------------------------
# file:     $HOME/.scripts/dzenstat.sh
# author:   Ramon Solis - http://cyb3rpunk.wordpress.com
# modified: June 2011
# vim:fenc=utf-8:nu:ai:si:et:ts=4:sw=4:ft=sh:
# ------------------------------------------------------

# -------------------------
# Dzen settings & Variables
# -------------------------
ICONPATH="/usr/share/icons/stlarch_icons"
COLOR_ICON="#EE3B3B"
CRIT_COLOR="#ff2c4a"
DZEN_FG="#A0A0A0"
DZEN_BG="#222222"
HEIGHT=12
WIDTH=1100
#RESOLUTIONW=`xrandr | grep -r "current" | awk '{print $8}'` 
#RESOLUTIONH=`xrandr | grep -r "current" | awk '{print $10}' | tr -d ','`
X=450
Y=3
BAR_FG="#EE3B3B"
BAR_BG="#808080"
BAR_H=10
BAR_W=65
#FONT="-artwiz-anorexia-medium-r-normal--11-110-75-75-p-90-iso8859-1"
FONT="-*-terminus-medium-r-*-*-12-*-*-*-*-*-iso10646-*"

SLEEP=1
VUP="amixer -c0 -q set Master 2dB+"
VDOWN="amixer -c0 -q set Master 2dB-"
#EVENT="button3=exit;button4=exec:$VUP;button5=exec:$VDOWN"
DZEN="dzen2 -x $X -y $Y -w $WIDTH -h $HEIGHT -fn $FONT -ta right -bg $DZEN_BG -fg $DZEN_FG" 

# -------------
# Infinite loop
# -------------
while :; do
sleep ${SLEEP}

# ---------
# Functions
# ---------
Vol ()
{
	#ONF=$(amixer get Master | awk '/Front\ Left:/ {print $7}' | tr -d '[]')
	VOL=$(amixer get Master | egrep -o "[0-9]+%" | tr -d '%')
	echo -n "^fg($COLOR_ICON)^i($ICONPATH/vol1.xbm)^fg()" $(echo $VOL | gdbar -fg $BAR_FG -bg $BAR_BG -h 7 -w 40 -s o -nonl)
	return
}

Mem ()
{
	MEM=$(free -m | grep '-' | awk '{print $3}')
	echo -n "^fg($COLOR_ICON)^i($ICONPATH/mem1.xbm)^fg() ${MEM} MB"
	return
}

Temp ()
{
	TEMP=$(acpi -t | awk '{print $4}' | tr -d '.0')
		if [[ ${TEMP} -gt 63 ]] ; then
			echo -n "^fg($CRIT_COLOR)^i($ICONPATH/temp.xbm)^fg($CRIT_COLOR) ${TEMP}°C" $(echo ${TEMP} | gdbar -fg $CRIT_COLOR -bg $BAR_BG -h $BAR_H -s v -sw 5 -ss 0 -sh 1 -nonl)
		else 
			echo -n "^fg($COLOR_ICON)^i($ICONPATH/temp.xbm)^fg() ${TEMP}°C" $(echo ${TEMP} | gdbar -fg $BAR_FG -bg $BAR_BG -h $BAR_H -s v -sw 5 -ss 0 -sh 1 -nonl)
		fi
	return
}

Disk ()
{
	SDA2=$(df -h / | awk '/\/$/ {print $5}' | tr -d '%')
	SDA3=$(df -h /home | awk '/home/ {print $5}' | tr -d '%')
	if [[ ${SDA2} -gt 60 ]] ; then
		echo -n "^fg($COLOR_ICON)^i($ICONPATH/file1.xbm)^fg() /:${SDA2}% $(echo $SDA2 | gdbar -fg $CRIT_COLOR -bg $BAR_BG -h 7 -w 40 -s o -ss 0 -sw 2 -nonl)"
	else
		echo -n "^fg($COLOR_ICON)^i($ICONPATH/file1.xbm)^fg() /:${SDA2}% $(echo $SDA2 | gdbar -fg $BAR_FG -bg $BAR_BG -h 7 -w 40 -s o -ss 0 -sw 2 -nonl)"
	fi
	if [[ ${SDA3} -gt 80 ]] ; then
		echo -n "  ~:${SDA3}% $(echo $SDA3 | gdbar -fg $CRIT_COLOR -bg $BAR_BG -h 7 -w 40 -s o -ss 0 -sw 2 -nonl)"
	else
		echo -n "  ~:${SDA3}% $(echo $SDA3 | gdbar -fg $BAR_FG -bg $BAR_BG -h 7 -w 40 -s o -ss 0 -sw 2 -nonl)"
	fi
	return
}

MPD ()
{
	MPDSTATUS=$(mpc | awk '/\[/ {print $1}' | tr -d "[]")
	MPDINFO=$(mpc | grep -v 'volume:' | head -n1)
	if [[ $MPDSTATUS == "playing" ]] ; then
		echo -n "^fg($COLOR_ICON)^i($ICONPATH/note1.xbm)^fg(#a0a0a0) $MPDINFO"
	elif [[ $MPDSTATUS == "paused" ]] ; then
		echo -n "^fg($COLOR_ICON)^i($ICONPATH/note1.xbm)^fg(#a0a0a0) [Paused]"
	else
		echo -n "^fg($COLOR_ICON)^i($ICONPATH/note1.xbm)^fg(#a0a0a0) [Stopped]"
	fi
	return
}

Kernel ()
{
	KERNEL=$(uname -a | awk '{print $3}')
	echo -n "Kernel: $KERNEL"
	return
}

Date ()
{
	TIME=$(date +%l:%M%P)
		echo -n "^fg($COLOR_ICON)^i($ICONPATH/clock1.xbm)^fg(#a0a0a0) ${TIME}"
	return
}

Between ()
{
    echo -n " ^fg(#A0A0A0)^r(2x2)^fg() "
	return
}

OSLogo ()
{
	echo -n " ^fg($COLOR_ICON)^i($ICONPATH/arch1.xbm)^fg() "
	return
}
# --------- End Of Functions

# -----
# Print 
# -----
Print () {
		OSLogo
		Kernel
		Between
		MPD
		Between
#		Temp
#		Between
        Mem
        Between
        Disk
        Between
        Vol
        Between
        Date
        echo
    return
}

echo "$(Print)" 
done | $DZEN &
