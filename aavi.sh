
#                             Online Bash Shell.
#                 Code, Compile, Run and Debug Bash script online.
# Write your code in this editor and press "Run" button to execute it.


#!/bin/bash

# Constants
XP_FILE="/tmp/updater_xp.txt"
LOG_FILE="/tmp/software_updater.log"

# XP Levels
get_badge() {
  case $XP in
    [0-9]|[1-9][0-9]) echo "🔰 Newbie Updater";;
    1[0-9][0-9]) echo "🏅 Regular Updater";;
    2[0-9][0-9]) echo "🥈 Pro Updater";;
    3[0-9][0-9]) echo "🥇 Master Updater";;
    *) echo "🏆 Ultimate Updater";;
  esac
}

# Check if run as root
if [ "$EUID" -ne 0 ]; then
  echo "⚠  Please run the script as root (use sudo)."
  exit 1
fi

# Load XP
if [ -f "$XP_FILE" ]; then
  XP=$(cat "$XP_FILE")
else
  XP=0
fi

# Update XP
update_xp_file() {
  echo "$XP" > "$XP_FILE"
}

# Log actions
log_action() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Install/Update software with info preview
install_software() {
    software_name=$(dialog --inputbox "Enter the name of the software to install or update:" 8 50 3>&1 1>&2 2>&3 3>&-)

    if [ -z "$software_name" ]; then
        dialog --msgbox "❌ No software entered!" 6 40
        return
    fi

    info=$(apt show "$software_name" 2>/dev/null | grep -E 'Package:|Version:|Homepage:|Description:' | head -n 6)

    if [ -z "$info" ]; then
        dialog --msgbox "❌ Could not find information for '$software_name'." 6 50
        return
    fi

    dialog --yesno "📦 Software Information:\n\n$info\n\nDo you want to install or update '$software_name'?" 15 60
    response=$?

    if [ $response -eq 0 ]; then
        apt install "$software_name" -y && {
            XP=$((XP+10))
            log_action "Installed/Updated $software_name. +10 XP."
            update_xp_file
            dialog --msgbox "✅ '$software_name' installed/updated!\n✨ XP: $XP\n🎯 Badge: $(get_badge)" 10 50
        } || {
            dialog --msgbox "❌ Installation failed!" 6 40
        }
    else
        dialog --msgbox "❌ Installation of '$software_name' cancelled." 6 50
    fi
}

# Show XP and badge
show_xp() {
  badge=$(get_badge)
  recent_logs=$(tail -n 5 "$LOG_FILE")
  dialog --msgbox "🧠 XP: $XP\n🎯 Badge: $badge\n\nLast 5 Logs:\n$recent_logs" 15 60
}

# View log file
view_logs() {
  dialog --textbox "$LOG_FILE" 20 60
}

# Main menu loop
while true; do
  choice=$(dialog --clear --backtitle "SoftwareUpdater.sh" --title "📦 Software Updater" \
    --menu "Choose an action:" 15 60 7 \
    1 "Install Specific Software" \
    2 "Upgrade Packages (apt upgrade)" \
    3 "Clean Unused Packages (apt autoremove)" \
    4 "Update Package Lists (apt update)" \
    5 "Check XP & Badge" \
    6 "View Log File" \
    7 "Exit" \
    3>&1 1>&2 2>&3)
# ✅ Check if user pressed Cancel (ESC) or closed dialog
exit_status=$?
if [ $exit_status -ne 0 ] || [ -z "$choice" ]; then
  clear
  exit 0
fi
  case $choice in
    1)
      install_software
      ;;
    2)
      apt upgrade -y && XP=$((XP+10))
      log_action "Ran apt upgrade. +10 XP."
      update_xp_file
      dialog --msgbox "✨ You've earned 10 XP!\nCurrent XP: $XP\n🎯 Badge: $(get_badge)" 10 50
      ;;
    3)
      apt autoremove -y && XP=$((XP+10))
      log_action "Ran apt autoremove. +10 XP."
      update_xp_file
      dialog --msgbox "✨ You've earned 10 XP!\nCurrent XP: $XP\n🎯 Badge: $(get_badge)" 10 50
      ;;
    4)
      apt update && XP=$((XP+10))
      log_action "Ran apt update. +10 XP."
      update_xp_file
      dialog --msgbox "✨ You've earned 10 XP!\nCurrent XP: $XP\n🎯 Badge: $(get_badge)" 10 50
      ;;
    5)
      show_xp
      ;;
    6)
      view_logs
      ;;
    7)
      dialog --msgbox "👋 Bye! Stay updated!" 6 40
      clear
      exit 0
      ;;
    *)
      dialog --msgbox "❌ Invalid option." 6 40
      ;;
  esac
done
