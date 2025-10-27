#!/bin/bash
# 🖥️ System Resource Manager with Zenity GUI
# by Rishabh Nandekar (23BIT054) and Krish Shah (23BIT282D)

# Hiding unnecessary GTK warnings
exec 2>/dev/null

#getting CPU , RAM AND DISK storage stats

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

# Log File Setup
LOG_FILE="$HOME/system_manager.log"
echo -e "\n------------------------------" >> "$LOG_FILE"
echo "🕒 Run Timestamp: $(date)" >> "$LOG_FILE"

# Collecting and Display System Stats

CPU=$(get_cpu)
RAM=$(get_ram)
DISK=$(get_disk)
SCORE=$(calculate_health)
SCORE=$(printf "%.2f" "$SCORE")

# Colour code for Health Score
if (( $(echo "$SCORE >= 75" | bc -l) )); then
    STATUS="🟢 Excellent"
elif (( $(echo "$SCORE >= 50" | bc -l) )); then
    STATUS="🟡 Moderate"
else
    STATUS="🔴 Poor"
fi

zenity --info --title="🧠 System Resource Report" \
--text="📊 CPU Usage: $CPU%\n🧠 RAM Usage: $RAM%\n💾 Disk Usage: $DISK%\n\n🩺 Health Score: $SCORE / 100 ($STATUS)" \
--width=300

# Log the initial stats
{
    echo "📊 CPU Usage: $CPU%"
    echo "🧠 RAM Usage: $RAM%"
    echo "💾 Disk Usage: $DISK%"
    echo "🩺 Health Score: $SCORE / 100 ($STATUS)"
} >> "$LOG_FILE"

#asking user itself to clean the junk or not
if ! zenity --question --title="🧹 Junk Cleaner" --text="Do you want to scan and clean junk files?"; then
    zenity --info --text="Exiting System Resource Manager.\nNo cleanup performed."
    echo "❌ Cleanup declined by user." >> "$LOG_FILE"
    exit 0
fi

#Asking User to Select Cleanup Directory manually
CLEAN_DIR=$(zenity --file-selection --directory --title="Select Directory for Junk Cleanup")

if [ -z "$CLEAN_DIR" ]; then
    zenity --error --text="❌ No directory selected. Exiting the program."
    echo "❌ No directory selected for cleanup. Exiting." >> "$LOG_FILE"
    exit 1
else
    zenity --info --text="📁 Selected cleanup directory: $CLEAN_DIR"
    echo "📁 Selected Directory: $CLEAN_DIR" >> "$LOG_FILE"
fi

#Junk Cleanup Section
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
    JUNK_LIST=$(find "$CLEAN_DIR" \( -name "*.log" -o -name "*.tmp" -o -name "*.bak" -o -name "*.cache" \) -type f -mtime +1)

    if [ -z "$JUNK_LIST" ]; then
        zenity --info --text="No junk files found in $CLEAN_DIR"
        echo "✅ No junk files found in $CLEAN_DIR" >> "$LOG_FILE"
    else
        zenity --text-info --title="Junk Files Found" --width=600 --height=400 --filename=<(echo "$JUNK_LIST")
        echo "🗑️ Junk files found in $CLEAN_DIR:" >> "$LOG_FILE"
        echo "$JUNK_LIST" >> "$LOG_FILE"

        # Confirm deletion
        if zenity --question --text="Do you want to delete these junk files?"; then
            echo "$JUNK_LIST" | xargs rm -f
            zenity --info --text="Junk files deleted successfully!"
            echo "✅ Junk files deleted successfully." >> "$LOG_FILE"
        else
            zenity --info --text="Cleanup canceled."
            echo "⚠️ Cleanup canceled by user." >> "$LOG_FILE"
        fi
    fi
else
    zenity --info --text="Junk cleanup skipped."
    echo "⚠️ User skipped junk cleanup." >> "$LOG_FILE"
fi

# SHOW SYSTEM STATS AFTER JUNK CLEANUP AND ADD COLOUR CODED HEALTH SCORE
CPU=$(get_cpu)
RAM=$(get_ram)
DISK=$(get_disk)
SCORE=$(calculate_health)
SCORE=$(printf "%.2f" "$SCORE")

if (( $(echo "$SCORE >= 75" | bc -l) )); then
    STATUS="🟢 Excellent"
elif (( $(echo "$SCORE >= 50" | bc -l) )); then
    STATUS="🟡 Moderate"
else
    STATUS="🔴 Poor"
fi

zenity --info --title="🧠 Updated System Resource Report" \
--text="📊 CPU Usage: $CPU%\n🧠 RAM Usage: $RAM%\n💾 Disk Usage: $DISK%\n\n🩺 Health Score: $SCORE / 100 ($STATUS)" \
--width=300

# Log the updated stats
{
    echo "------ After Cleanup ------"
    echo "📊 CPU Usage: $CPU%"
    echo "🧠 RAM Usage: $RAM%"
    echo "💾 Disk Usage: $DISK%"
    echo "🩺 Health Score: $SCORE / 100 ($STATUS)"
    echo "------------------------------"
} >> "$LOG_FILE"

zenity --info --text="📄 Log file has been saved at:\n$LOG_FILE"
