#!/bin/bash


# ^c$var^ = fg color
# ^b$var^ = bg color

interval=0

# load colors
. ~/.config/arco-chadwm/scripts/bar_themes/catppuccin

cpu() {
  cpu_val=$(sensors | grep "edge" | awk '{print $2}' | sed 's/+//')

  printf "^c$blue^  ^b$black^ CPU"
  printf "^c$red^ ^b$black^ $cpu_val"
}

pkg_updates() {
  updates=$(checkupdates | wc -l)   # arch

  if [ -z "$updates" ]; then
    printf "  ^c$green^    Fully Updated"
  else
    printf "  ^c$green^    $updates"" updates"
  fi
}


battery() {
  get_capacity="$(cat /sys/class/power_supply/BAT0/capacity)"
  charging_status="$(cat /sys/class/power_supply/BAT0/status)"
  
  if [ "$charging_status" == "Charging" ] || [ "$charging_status" == "Not charging" ]; then
    icon=" "  # Charging icon
  else
    icon=" "  # Battery icon
  fi
  
  printf "^c$blue^ $icon $get_capacity"
}

brightness() {
  max_brightness=$(cat /sys/class/backlight/*/max_brightness)
  current_brightness=$(cat /sys/class/backlight/*/brightness)
  brightness_percentage=$((current_brightness * 100 / max_brightness))
 
  printf "^c$red^   "
  printf "^c$red^%.0f\n" $brightness_percentage
}

mem() {
  printf "^c$blue^^b$black^  "
  printf "^c$blue^ $(free -h | awk '/^Mem/ { print $3 }' | sed s/i//g)"
}


wlan() {
    local wifi_status
    local wifi_name
    local ethernet_status
    
    wifi_status=$(cat /sys/class/net/wl*/operstate 2>/dev/null)
    wifi_name=$(iwgetid -r 2>/dev/null)
    ethernet_status=$(cat /sys/class/net/en*/operstate 2>/dev/null)
    
    if [[ "$wifi_status" == "up" ]]; then
        printf "^c$black^ ^b$blue^ 󰤨 ^d^%s" " ^c$blue^ $wifi_name"
    elif [[ "$ethernet_status" == "up" ]]; then
        printf "^c$black^ ^b$blue^  ^d^%s" " ^c$blue^Ethernet"
    else
        printf "^c$black^ ^b$blue^ 󰕑 ^d^%s" " ^c$blue^Disconnected"
    fi
}


clock() {
	printf "^c$black^ ^b$darkblue^  "
	printf "^c$black^^b$blue^ $(date '+%d/%m/%y %I:%M %p')  "
}

while true; do

  [ $interval = 0 ] || [ $(($interval % 3600)) = 0 ] && updates=$(pkg_updates)
  interval=$((interval + 1))

  sleep 2 && xsetroot -name "$updates $(battery) $(brightness) $(cpu) $(mem) $(wlan) $(clock)"
done
