#!/bin/bash
# --------------------------------------------------------------------
# 🖥️ System Resource Manager with Zenity GUI
# by Rishabh Nandekar (23BIT054) and Krish Shah (23BIT282D)
# --------------------------------------------------------------------

# Hiding unnecessary GTK warnings
exec 2>/dev/null

# -------------------- System Information Functions --------------------

# Get CPU usage (%)
get_cpu() {
    top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}'
}

# Get RAM usage (%)
get_ram() {
    free | awk '/Mem/{printf "%.2f", $3/$2*100}'
}

# Get Disk usage (%)
get_disk() {
    df / | awk 'NR==2 {print $5}' | sed 's/%//'
}

# Calculate overall system health
calculate_health() {
    echo "100 - (0.4*$CPU + 0.3*$RAM + 0.3*$DISK)" | bc -l
}

# -------------------- Collect and Display System Stats --------------------

CPU=$(get_cpu)
RAM=$(get_ram)
DISK=$(get_disk)
SCORE=$(calculate_health)
SCORE=$(printf "%.2f" "$SCORE")

zenity --info --title="🧠 System Resource Report" \
--text="📊 CPU Usage: $CPU%\n🧠 RAM Usage: $RAM%\n💾 Disk Usage: $DISK%\n\n🩺 Health Score: $SCORE / 100" \
--width=300

# -------------------- Ask if user wants to clean junk --------------------
if ! zenity --question --title="🧹 Junk Cleaner" --text="Do you want to scan and clean junk files?"; then
    zenity --info --text="👋 Exiting System Resource Manager.\nNo cleanup performed."
    exit 0
fi

# -------------------- Ask User to Select Cleanup Directory --------------------
CLEAN_DIR=$(zenity --file-selection --directory --title="Select Directory for Junk Cleanup")

if [ -z "$CLEAN_DIR" ]; then
    zenity --error --text="❌ No directory selected. Exiting the program."
    exit 1
else
    zenity --info --text="📁 Selected cleanup directory: $CLEAN_DIR"
fi

# -------------------- Junk Cleanup Section --------------------
if zenity --question --text="Do you want to view junk files before cleaning?"; then

    # Simulated scanning progress bar
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
        if zenity --question --text="🧹 Do you want to delete these junk files?"; then
            echo "$JUNK_LIST" | xargs rm -f
            zenity --info --text="✨ Junk files deleted successfully!"
        else
            zenity --info --text="❌ Cleanup canceled."
        fi
    fi
else
    zenity --info --text="🛑 Junk cleanup skipped."
fi
