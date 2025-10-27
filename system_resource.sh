#!/bin/bash
# --------------------------------------------------------------------
# 🖥️ System Resource Manager with Zenity GUI
# by Rishabh Nandekar (23BIT054) and Krish Shah (23BIT282D)
# --------------------------------------------------------------------

#setting up the directory
CLEAN_DIR="$HOME/Downloads"

#Hiding unnecessary GTK warnings
exec 2>/dev/null

#getting cpu information from the system
get_cpu() {
    top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}'
}

#getting ram information from the system
get_ram() {
    free | awk '/Mem/{printf "%.2f", $3/$2*100}'
}

#getting disk information from the system
get_disk() {
    df / | awk 'NR==2 {print $5}' | sed 's/%//'
}

calculate_health() {
    echo "100 - (0.4*$CPU + 0.3*$RAM + 0.3*$DISK)" | bc -l
}

#Collecting system stats
CPU=$(get_cpu)
RAM=$(get_ram)
DISK=$(get_disk)
SCORE=$(calculate_health)
SCORE=$(printf "%.2f" "$SCORE")

#Display the main system stats on GUI
zenity --info --title="🧠 System Resource Report" \
--text="📊 CPU Usage: $CPU%\n🧠 RAM Usage: $RAM%\n💾 Disk Usage: $DISK%\n\n🩺 Health Score: $SCORE / 100" \
--width=300

# allowing user to change the directory
if zenity --question --text="Do you want to choose a custom folder for junk cleanup?"; then
    NEW_DIR=$(zenity --file-selection --directory --title="Select Directory for Junk Cleanup")
    if [ -n "$NEW_DIR" ]; then
        CLEAN_DIR="$NEW_DIR"
        zenity --info --text="📁 Cleanup directory changed to: $CLEAN_DIR"
    else
        zenity --info --text="⚠️ No directory selected. Using default: $CLEAN_DIR"
    fi
fi

#Asking before cleaning the junk
if zenity --question --text="Do you want to view junk files before cleaning?"; then

    # Progress bar simulation for scanning
    (
        TOTAL=5
        for i in $(seq 1 $TOTAL); do
            echo $((i * 20))
            echo "# Scanning system for junk files... Step $i of $TOTAL"
            sleep 0.5
        done
    ) | zenity --progress \
        --title="🔍 Scanning for Junk Files" \
        --text="Initializing..." \
        --percentage=0 \
        --auto-close \
        --width=400

    # Find junk files (log, tmp, cache, bak) older than 7 days
    JUNK_LIST=$(find "$CLEAN_DIR" \( -name "*.log" -o -name "*.tmp" -o -name "*.bak" -o -name "*.cache" \) -type f -mtime +7)

    if [ -z "$JUNK_LIST" ]; then
        zenity --info --text="✅ No junk files found in $CLEAN_DIR"
    else
        zenity --text-info --title="🗑️ Junk Files Found" --width=600 --height=400 --filename=<(echo "$JUNK_LIST")

        # Confirm deletion
        if zenity --question --text="Delete these junk files?"; then
            echo "$JUNK_LIST" | xargs rm -f
            zenity --info --text="🧹 Junk files deleted successfully!"
        else
            zenity --info --text="❌ Cleanup canceled."
        fi
    fi
else
    zenity --info --text="Junk cleanup skipped."
fi

