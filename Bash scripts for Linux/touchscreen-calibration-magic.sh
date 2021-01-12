#!/bin/sh
#
# Touchscreen Calibration Magic by QWeb Ltd
#
# This script was created for an Asus UX563F laptop running Gentoo GNU/Linux and KDE Plasma 5, but modifying for other devices should be straightforward.
#
# The laptop comes with a touchscreen, a second screen under the touchpad, and a digital pen. Folding the screen back switches to tablet mode and disconnects the second screen.
#
# I found that every time the second screen connects or disconnects, the touchscreen and touch pen calibration skews.
#
# This script resolves calibration issues by monitoring for screen reconnections and for the pen, which doesn't even appear as an input device until you try to use it.
#
# Requires kscreen and libnotify.
#
# Make sure this script is executable with chmod +x , then add to KDE's startup scripts via "System Settings > Workspace > Startup and Shutdown  > Autostart".

# Populate primary screen and secondary screen device names as per output of: kscreen-doctor -o
primaryScreenDevice="eDP-1"
secondScreenDevice="HDMI-1"

# Populate touchscreen and pen devices as per output of: xinput list
touchscreenDevice="ELAN9008:00 04F3:2A46"
penDevice="ELAN9008:00 04F3:2A46 Pen (0)"




# These all default to off to force calibration on initial script launch
touchscreenID="0"
secondScreenExists=false
penExists=false

notify-send "Touchscreen Calibration Magic by QWeb Ltd was started."

# Starts an infinite loop
while :; do

	# Get an up to date ID for the touchscreen device, because there's also a slave keyboard with the same name annoyingly, so we can't reference by name alone...
	# (the spaces at the end of this grep are important to distinguish between the main input device, and the pen which has the same prefix)
	sedResult=`echo \`xinput list | grep "slave  pointer" | grep "$touchscreenDevice  "\` | sed -e 's/^.* id=\([0-9]\+\) .*$/\1/g'`

	if [ "$sedResult" != "" ] && [ "$sedResult" != "$touchscreenID" ]; then
		touchscreenID=$sedResult

		# Give screens chance to settle
		sleep 1

		xinput map-to-output $touchscreenID $primaryScreenDevice
		notify-send "Touchscreen found and calibrated."
	fi

	# Watch for pen connecting / disconnecting
	grepResult=`xinput list | grep "$penDevice"`

	if [ $penExists == true ]; then
		if [ "$grepResult" == "" ]; then
			# Pen was just disconnected
			penExists=false
			notify-send "Pen was disconnected."
		fi
	else
		if [ "$grepResult" != "" ]; then
			# Pen was just connected
			xinput map-to-output "$penDevice" $primaryScreenDevice
			penExists=true
			notify-send "Pen found and calibrated."
		fi
	fi

	# Watch for second screen connecting / disconnecting
	grepResult=`kscreen-doctor -o | grep "$secondScreenDevice" | grep "disconnected"`

	if [ $secondScreenExists == true ]; then
		if [ "$grepResult" != "" ]; then
			# Secondary screen just disconnected
			secondScreenExists=false
			notify-send "Secondary screen was disconnected."

			# Give screens chance to settle
			sleep 1

			# If the touchscreen exists, we need to recalibrate
			if [ "$touchscreenID" != "0" ]; then
				xinput map-to-output $touchscreenID $primaryScreenDevice
				notify-send "Touchscreen was recalibrated."
			fi

			# If the pen exists, we need to recalibrate
			if [ $penExists == true ]; then
				xinput map-to-output "$penDevice" $primaryScreenDevice
				notify-send "Pen was recalibrated."
			fi
		fi
	else
		if [ "$grepResult" == "" ]; then
			# Secondary screen just connected
			secondScreenExists=true
			notify-send "Secondary screen was connected."

			# Give screens chance to settle
			sleep 1

			# If the touchscreen exists, we need to recalibrate
			if [ "$touchscreenID" != "0" ]; then
				xinput map-to-output $touchscreenID $primaryScreenDevice
				notify-send "Touchscreen was recalibrated."
			fi

			# If the pen exists, we need to recalibrate
			if [ $penExists == true ]; then
				xinput map-to-output "$penDevice" $primaryScreenDevice
				notify-send "Pen was recalibrated."
			fi
		fi
	fi

	# Prevent CPU overload
	sleep 1
done
