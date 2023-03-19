#!/bin/bash


# Check if dependencies are installed
if ! command -v battery >/dev/null 2>&1; then
    echo -e >&2 "\n'battery' is not installed.\n\nInstallation:\ncurl -s https://raw.githubusercontent.com/actuallymentor/battery/main/setup.sh | bash\n\nAborting...\n"
	osascript -e 'display notification "'"Aborted"'" with title "'"Battery Calibration"'" sound name "'"tink"'"'
    exit 1
fi


# Set charge variables (for testing)
# Note that a trap has been used at the end to ensure that 'battery maintain 80' is set
readonly DISCHARGE_LEVEL=78
readonly FULLCHARGE_LEVEL=82
readonly TARGET_LEVEL=80
readonly HOLD_DURATION=120
readonly SLEEP_DURATION=30

# Makes sure that battery maintain 80 has been set to prevent an unwanted charge level if an error occurs.
setMaintain() {
    
	echo "reached trap, setting and exiting."
    battery maintain 80 > /dev/null 2>&1 &
}

# Function to display a notification
send_notification() {
	osascript -e 'display notification "'"$1"'" with title "'"$2"'" sound name "'"$3"'"'
}

# Step 1 - Initialising calibration - discharge
battary maintain stop > /dev/null 2>&1 &
battery discharge $DISCHARGE_LEVEL > /dev/null 2>&1 &
send_notification "Discharging battery to $DISCHARGE_LEVEL%" "Initialising Battery Calibration" "blow"


# Step 2 - charge to fullcharge level after discharging
while true; do
    echo "checking if at $DISCHARGE_LEVEL%"
    # Check if battery level is at 15%
    if battery status | head -n 1 | grep -q "Battery at $DISCHARGE_LEVEL%"; then
    	echo "setting maintain level to $FULLCHARGE_LEVEL"
        send_notification "Reached $DISCHARGE_LEVEL% charge, proceeding to charge to $FULLCHARGE_LEVEL%" "Battery Calibration" "blow"
        battery charge $FULLCHARGE_LEVEL > /dev/null 2>&1 &
	    break
    else
        sleep $SLEEP_DURATION
        continue
    fi
done


# Step 3 - Maintain at fullcharge level before discharging to target level
while true; do
	echo "checking if at $FULLCHARGE_LEVEL%"
    # Check if battery level has reached 100%
    if battery status | head -n 1 | grep -q "Battery at 85%"; then
    	echo "reached $FULLCHARGE_LEVEL%, maintaining for $HOLD_DURATION"
        send_notification "$FULLCHARGE_LEVEL% charged, holding for 1 hour" "Battery Calibration" "blow"
        # Wait before discharging to target level
        sleep $HOLD_DURATION
        echo "Discharging to $TARGET_LEVEL%"
        send_notification "Discharging to $TARGET_LEVEL%" "Battery Calibration" "blow"
        battery discharge $TARGET_LEVEL > /dev/null 2>&1 &
        break
    else
        sleep $SLEEP_DURATION
        continue
    fi
done
        
        
# Step 4 - Set battery to maintain and exit once it has reached target level
while true; do
	echo "reached step 4. Checking if at $TARGET_LEVEL%"
    if battery status | head -n 1 | grep -q "Battery at $TARGET_LEVEL%"; then
    	echo "target level reached, breaking to trap"
    	send_notification "Maintaining at $TARGET_LEVEL%" "Battery Calibration Complete" "default"
    else
    	sleep $SLEEP_DURATION
    	continue
	fi
done
trap setMaintain EXIT
