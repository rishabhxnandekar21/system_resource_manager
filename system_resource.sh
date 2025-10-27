#!/bin/bash
# --------------------------------------------------------------------
# 🖥️ System Resource Manager with Zenity GUI
# by Rishabh Nandekar (23BIT054) and Krish Shah (23BIT282D)
# --------------------------------------------------------------------

# 🔧 Default cleanup directory (user can change it later)
CLEAN_DIR="$HOME/Downloads"

# 🚫 Hide unnecessary GTK warnings for a cleaner UI
exec 2>/dev/null

# --------------------------------------------------------------------
# 🧠 Function: get_cpu
# Purpose: Fetches CPU usage percentage using 'top' command
# --------------------------------------------------------------------
get_cpu() {
    top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}'
}

# --------------------------------------------------------------------
# 🧠 Function: get_ram
# Purpose: Calculates RAM usage percentage using 'free' command
# --------------------------------------------------------------------
get_ram() {
    free | awk '/Mem/{printf "%.2f", $3/$2*100}'
}

# --------------------------------------------------------------------
# 💾 Function: get_disk
# Purpose: Retrieves Disk usage percentage using 'df'
# --------------------------------------------------------------------
get_disk() {
    df / | awk 'NR==2 {print $5}' | sed 's/%//'
}

# --------------------------------------------------------------------
# ❤️ Function: calculate_health
# Purpose: Combines CPU, RAM, and Disk usage into one Health Score
# Formula: 100 - (0.4*CPU + 0.3*RAM + 0.3*DISK)
# --------------------------------------------------------------------
calculate_health() {
    echo "100 - (0.4*$CPU + 0.3*$RAM + 0.3*$DISK)" | bc -l
}

# --------------------------------------------------------------------
# 📊 Collecting system stats
# --------------------------------------------------------------------
CPU=$(get_cpu)
RAM=$(get_ram)
DISK=$(get_disk)
SCORE=$(calculate_health)
SCORE=$(printf "%.2f" "$SCORE")

# --------------------------------------------------------------------
# 🪟 Display main system resource report via Zenity GUI
# --------------------------------------------------------------------
zenity --info --title="🧠 System Resource Report" \
--text="📊 CPU Usage: $CPU%\n🧠 RAM Usage: $RAM%\n💾 Disk Usage: $DISK%\n\n🩺 Health Score: $SCORE / 100" \
--width=300

# --------------------------------------------------------------------
# 🗂️ Option: Allow user to change directory for junk cleanup
# --------------------------------------------------------------------
if zenity --question --text="Do you want to choose a custom folder for junk cleanup?"; then
    NEW_DIR=$(zenity --file-selection --directory --title="Select Directory for Junk Cleanup")
    if [ -n "$NEW_DIR" ]; then
        CLEAN_DIR="$NEW_DIR"
        zenity --info --text="📁 Cleanup directory changed to: $CLEAN_DIR"
    else
        zenity --info --text="⚠️ No directory selected. Using default: $CLEAN_DIR"
    fi
fi

# --------------------------------------------------------------------
# 🧹 Ask user before scanning junk
# --------------------------------------------------------------------
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

