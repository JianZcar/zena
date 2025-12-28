#!/bin/bash
set -euo pipefail

if getent passwd 1000 >/dev/null; then
    touch /var/lib/zena-setup.done
    exit 0
fi

trap '/usr/libexec/zena-setup.sh;' EXIT
trap '/usr/libexec/zena-setup.sh;' SIGINT

FULLNAME=""
USERNAME=""
PASSWORD=""
TIMEZONE=""
main_menu() {
    local choice=""
    while :; do
        gum style --border rounded \
          "Full name: $FULLNAME" \
          "Username:  $USERNAME" \
          "Timezone:  $TIMEZONE"

        choice=$(gum choose \
          "Create Account" \
          "Select Timezone" \
          "Confirm" \
          --limit 1)
        clear

        case "$choice" in
            "Create Account")
                create_account
                ;;
            "Select Timezone")
                select_timezone
                ;;
            "Confirm")
                if [[ -z "$FULLNAME" || -z "$USERNAME" || -z "$PASSWORD" || -z "$TIMEZONE" ]]; then
                    gum style --border rounded \
                      "Some fields are missing, please fill them in."
                    continue
                fi
                if gum confirm "Confirm" --default=false; then
                    setup

                fi
                ;;
            *)
                clear
                gum style --border rounded "Invalid choice." 2> /dev/null
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

            if [[ ${#PASSWORD} -lt 6 ]]; then
                clear
                gum style --border thick "Password must be at least 6 characters long" 2> /dev/null
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
    NEWPASSWORD="$PASSWORD" \
    homectl create --password-change-now=true "$USERNAME" \
      --uid=1000 \
      --storage=luks \
      --fs-type=btrfs \
      --disk-size=75% \
      --auto-resize-mode=shrink-and-grow \
      --member-of=wheel \
      --real-name="$FULLNAME"

    timedatectl set-local-rtc 0
    timedatectl set-timezone "$TIMEZONE"

    trap '' EXIT
    trap '' SIGINT
    touch /var/lib/zena-setup.done
    exit 0
}

clear
main_menu
