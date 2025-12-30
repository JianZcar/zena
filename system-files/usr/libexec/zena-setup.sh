#!/bin/bash
set -euo pipefail

if getent passwd 1000 >/dev/null; then
    touch /var/lib/zena-setup.done
    exit 0
fi

if homectl list --json=short | jq -e '. | length > 0' >/dev/null; then
    touch /var/lib/zena-setup.done
    exit 0
fi

trap '/usr/libexec/zena-setup.sh;' EXIT
trap '/usr/libexec/zena-setup.sh;' SIGINT

FULLNAME=""
USERNAME=""
PASSWORD=""
HOMESIZE=""
TIMEZONE=""
main_menu() {
    local choice=""
    while :; do
        gum style --border thick \
          "Full name: $FULLNAME" \
          "Username:  $USERNAME" \
          "Home Size: $HOMESIZE" \
          "Timezone:  $TIMEZONE"

        choice=$(gum choose \
          "Create Account" \
          "Adjust Home size" \
          "Select Timezone" \
          "Confirm" \
          --limit 1)
        clear

        case "$choice" in
            "Create Account")
                create_account
                ;;
            "Adjust Home size")
                adjust_home_size
                ;;
            "Select Timezone")
                select_timezone
                ;;
            "Confirm")
                if [[ -z "$FULLNAME" || -z "$USERNAME" || -z "$PASSWORD" || -z "$HOMESIZE" || -z "$TIMEZONE" ]]; then
                    gum style --border thick \
                      "Some fields are missing, please fill them in."
                    continue
                fi
                if gum confirm "Confirm" --default=false; then
                    setup

                fi
                ;;
            *)
                clear
                gum style --border thick "Invalid choice." 2> /dev/null
                ;;
        esac
    done
}

create_account() {
    local confirm_password=""

    while :; do
        FULLNAME=$(gum input --placeholder "Enter Full name")

        if [[ -z "$FULLNAME" ]]; then
            clear
            gum style --border thick "Full name cannot be empty"
            continue
        fi

        if [[ ${#FULLNAME} -lt 2 ]]; then
            clear
            gum style --border thick "Full name must be at least 2 characters long" 2> /dev/null
            continue
        fi
        clear && break
    done


    while :; do
        USERNAME=$(gum input --placeholder "Enter username")

        if [[ -z "$USERNAME" ]]; then
            clear
            gum style --border thick "Username cannot be empty"
            continue
        fi

        if [[ ${#USERNAME} -lt 2 ]]; then
            clear
            gum style --border thick "Username must be at least 2 characters long" 2> /dev/null
            continue
        fi

        if [[ ! "$USERNAME" =~ ^[a-z][a-z0-9._-]*$ ]]; then
            clear
            gum style --border thick \
              "Username must start with a lowercase letter and contain only lowercase letters, digits, '.', '_', or '-'"
            continue
        fi
        clear && break
    done


    while :; do
        while :; do
            PASSWORD=$(gum input --password --placeholder "Enter password")

            if [[ -z "$PASSWORD" ]]; then
                clear
                gum style --border thick "Password cannot be empty" 2> /dev/null
                continue
            fi

            if [[ ${#PASSWORD} -lt 8 ]]; then
                clear
                gum style --border thick "Password must be at least 8 characters long" 2> /dev/null
                continue
            fi
            clear && break
        done

        confirm_password=$(gum input --password --placeholder "Confirm password")
        [[ "$PASSWORD" == "$confirm_password" ]] && clear && break
        clear
        gum style --border thick "Password don't match" 2> /dev/null
    done
}

adjust_home_size() {
    local avail avail_gb suggested size
    avail=$(df --output=avail /var/home | tail -n1)
    avail_gb=$(( avail / 1024 / 1024 ))
    suggested=$(( avail_gb * 75 / 100 ))

    while :; do
        gum style --border thick \
          "Available Space: ${avail_gb}G" \
          "Suggested Home Size: ${suggested}G (about 75% of available)" \
          "Home size can be changed later using:" \
          "  homectl resize <username> <size>"

        HOMESIZE=$(gum input --placeholder "Enter storage size for home (e.g., 20G)")

        if [[ -z "$HOMESIZE" ]]; then
            clear
            gum style --border thick "Home size cannot be empty" 2> /dev/null
            continue
        fi

        if [[ ! "$HOMESIZE" =~ ^[0-9]+G$ ]]; then
            clear
            gum style --border thick "Invalid format. Use integer followed by 'G', e.g., 20G." 2> /dev/null
            continue
        fi

        size=${HOMESIZE%G}
        if (( size > avail_gb )); then
            clear
            gum style --border thick "Entered size exceeds available space (${avail_gb}G)." 2> /dev/null
            continue
        fi

        clear && break
    done
}

select_timezone() {
    mapfile -t zones < <(timedatectl list-timezones)

    while :; do
        TIMEZONE=$(printf "%s\n" "${zones[@]}" | gum filter --limit 1 --placeholder "Search")
        [[ -n "$TIMEZONE" ]] && clear && break
        clear
        gum style --border thick "Timezone selection is required" 2> /dev/null
    done
}

setup() {
    timedatectl set-local-rtc 0
    timedatectl set-timezone "$TIMEZONE"

    NEWPASSWORD="$PASSWORD" \
    /usr/bin/homectl create --password-change-now=false "$USERNAME" \
      --storage=luks \
      --fs-type=btrfs \
      --disk-size="$HOMESIZE" \
      --auto-resize-mode=shrink-and-grow \
      --member-of=wheel \
      --real-name="$FULLNAME" \
      --luks-extra-mount-options=defcontext=system_u:object_r:user_home_dir_t:s0

    trap '' EXIT
    trap '' SIGINT
    touch /var/lib/zena-setup.done
    exit 0
}

sleep 10
clear
main_menu
