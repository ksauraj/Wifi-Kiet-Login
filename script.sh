#!/bin/bash

# Directory to store encrypted credentials
credentials_dir="$HOME/.ksau_script"
username_file="$credentials_dir/.username.gpg"
password_file="$credentials_dir/.password.gpg"

# Wi-Fi network details
wifi_ssid="KIET"

# Function to connect to Wi-Fi network (for Linux and macOS)

connect_to_wifi() {
    wifi_ssid="KIET"  # Set your SSID here

    if [[ $(uname) == "Linux" ]]; then
        # Check if the network is available
        if nmcli -t -f SSID dev wifi | grep -q "^${wifi_ssid}$"; then
            # Connect using nmcli on Linux
            nmcli device wifi connect "$wifi_ssid"
        else
            echo "Error: No network with SSID '$wifi_ssid' found."
            exit 1
        fi
    elif [[ $(uname) == "Darwin" ]]; then
        # Scan for networks and check if the network is available
        if /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -s | grep -q "^${wifi_ssid}$"; then
            # Connect using networksetup on macOS
            networksetup -setairportnetwork en0 "$wifi_ssid"
        else
            echo "Error: No network with SSID '$wifi_ssid' found."
            exit 1
        fi
    else
        echo "Unsupported operating system."
        exit 1
    fi
}


# Function to generate timestamp
generate_timestamp() {
    timestamp=$(date +%s%3N)  # milliseconds since Unix epoch
    echo "$timestamp"
}

# Function to prompt user for username and password
get_credentials() {
    read -p "Enter your username: " username
    read -s -p "Enter your password: " password
    echo ""
}

# Function to encrypt and store username
encrypt_and_store_username() {
    local username="$1"

    # Create directory if it doesn't exist
    mkdir -p "$credentials_dir"

    # Encrypt username using GPG
    echo "$username" | gpg --quiet --yes --batch --passphrase="your_passphrase" -c -o "$username_file"
}

# Function to encrypt and store password
encrypt_and_store_password() {
    local password="$1"

    # Encrypt password using GPG
    echo "$password" | gpg --quiet --yes --batch --passphrase="your_passphrase" -c -o "$password_file"
}

# Function to decrypt username
decrypt_username() {
    # Decrypt username using GPG
    gpg --quiet --yes --batch --passphrase="your_passphrase" -d "$username_file"
}

# Function to decrypt password
decrypt_password() {
    # Decrypt password using GPG
    gpg --quiet --yes --batch --passphrase="your_passphrase" -d "$password_file"
}

# Function to display pop-up message based on desktop environment

display_popup() {
    if [ -z "$DISPLAY" ]; then
        # No graphical environment, display message in terminal
        echo "$1"
    else
        if command -v notify-send &> /dev/null; then
            notify-send "Wifi Manager" "$1"
        elif command -v kdialog &> /dev/null; then
            kdialog --title "Wifi Manager" --msgbox "$1"
        elif command -v xfce4-notifyd &> /dev/null; then
            xfce4-notifyd --title "Wifi Manager" --message "$1"
        else
            # If no graphical notification tools are available, fall back to terminal
            echo "$1"
        fi
    fi
}

# Function to check if KIET network is available (for Linux and macOS)s
check_network_availability() {
    if [[ $(uname) == "Linux" ]]; then
        # Check using nmcli on Linux
        if nmcli -f SSID device wifi list | grep -q "$wifi_ssid"; then
            return 0
        else
            return 1
        fi
    elif [[ $(uname) == "Darwin" ]]; then
        # Check using airport command on macOS
        if /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | grep -q " SSID: $wifi_ssid"; then
            return 0
        else
            return 1
        fi
    else
        echo "Unsupported operating system."
        exit 1
    fi
}

# Function to login to wifi
login_to_wifi() {
    local username="$1"
    local password="$2"

    # URL for the login endpoint
    login_url="http://172.16.16.16:8090/login.xml"

    # Generate timestamp
    timestamp=$(generate_timestamp)

    # Form data
    form_data="mode=191&username=$username&password=$password&a=$timestamp&producttype=0"

    # HTTP headers
    headers=(
        "-H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36'"
        "-H 'Accept: */*'"
        "-H 'Accept-Language: en-GB,en'"
        "-H 'Accept-Encoding: gzip, deflate'"
        "-H 'Connection: keep-alive'"
        "-H 'Content-Type: application/x-www-form-urlencoded'"
        "-H 'Origin: http://172.16.16.16:8090'"
        "-H 'Referer: http://172.16.16.16:8090/httpclient.html'"
        "-H 'Sec-GPC: 1'"
    )

    # Sending POST request
    response=$(curl -s -X POST -d "$form_data" "${headers[@]}" "$login_url")
    echo "${response}"
    if grep -q "<status><!\[CDATA[LIVE\]\]></status>" <<< "$response"; then
        display_popup "Successfully logged in as $username"
    else
        display_popup "Login failed. Please check your credentials and try again."
        exit 1
    fi
}

# Function to logout from wifi
logout_from_wifi() {
    rm response.txt
    local username="$1"

    # URL for the logout endpoint
    logout_url="http://172.16.16.16:8090/logout.xml"

    # Generate timestamp
    timestamp=$(generate_timestamp)

    # Form data
    form_data="mode=193&username=$username&a=$timestamp&producttype=0"

    # HTTP headers
    headers=(
        "-H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36'"
        "-H 'Accept: */*'"
        "-H 'Accept-Language: en-GB,en'"
        "-H 'Accept-Encoding: gzip, deflate'"
        "-H 'Connection: keep-alive'"
        "-H 'Content-Type: application/x-www-form-urlencoded'"
        "-H 'Origin: http://172.16.16.16:8090'"
        "-H 'Referer: http://172.16.16.16:8090/httpclient.html'"
        "-H 'Sec-GPC: 1'"
    )

    # Sending POST request
    response=$(curl -s -X POST -d "$form_data" "${headers[@]}" "$logout_url")
    echo "${response}"
    if grep -q "<logoutmessage><!\[CDATA\[You have successfully logged off\]\]></logoutmessage>" <<< "$response"; then
        display_popup "Successfully logged out"
    else
        display_popup "Logout failed. Please try again."
        exit 1
    fi
}

# Function to display a message
display_message() {
    echo "Welcome to the Wifi Manager Script!"
}

# Function to clear stored credentials
clear_credentials() {
    rm -f "$username_file" "$password_file"
    echo "Credentials cleared."
}

# Function to handle login process
# Function to handle login process
handle_login() {
    local username="$1"
    local password="$2"

    # Check network availability before attempting to connect
    if ! check_network_availability; then
        display_popup "Wi-Fi network '$wifi_ssid' not found. Please make sure you are in range."
        exit 1
    fi

    connect_to_wifi
    sleep 5
    login_to_wifi "$username" "$password"
    echo "Login done."
}


# Function to handle logout process
handle_logout() {
    local username="$1"

    logout_from_wifi "$username"
    clear_credentials
}

# Function to handle the interactive mode
interactive_mode() {
    display_message

    # Check if credentials exist
    if [[ ! -f "$username_file" || ! -f "$password_file" ]]; then
        get_credentials
        encrypt_and_store_username "$username"
        encrypt_and_store_password "$password"
    fi

    # Decrypt credentials
    username=$(decrypt_username)
    password=$(decrypt_password)

    # Handle login or logout based on user input
    while true; do
    read -t 5 -p "Do you want to login (l), logout (x), or exit (e)? [default: login] " choice
        if [[ -z $choice ]]; then
            handle_login "$username" "$password"
        else
            case $choice in
                [lL]* ) handle_login "$username" "$password";;
                [xX]* ) handle_logout "$username";;
                [eE]* ) exit;;
                * ) echo "Please enter 'l' to login, 'x' to logout, or 'e' to exit.";;
            esac
        fi
    done
}

# Function to handle command line arguments
handle_arguments() {
    local option="$1"
    local username="$2"
    local password="$3"

    case "$option" in
        --login) handle_login "$username" "$password";;
        --logout) handle_logout "$username";;
        *) echo "Invalid option. Usage: bash script.sh --login <username> <password>"; exit 1;;
    esac
}

# Main function
main() {
    # Debugging 
    whoami 
    echo "$HOME"
    # If command-line arguments are provided, handle them
    if [[ $# -gt 0 ]]; then
        handle_arguments "$@"
    else
        interactive_mode
    fi
}

main "$@"
