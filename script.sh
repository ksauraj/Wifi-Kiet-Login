#!/bin/bash

# Directory to store encrypted credentials
credentials_dir="$HOME/.ksau_script"
username_file="$credentials_dir/.username.gpg"
password_file="$credentials_dir/.password.gpg"

# Wi-Fi network details
wifi_ssid="KIET"

# Function to connect to Wi-Fi network
connect_to_wifi() {
    # Connect to the specified Wi-Fi network using nmcli
    nmcli device wifi connect "$wifi_ssid"
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
    curl -s -X POST -d "$form_data" "${headers[@]}" "$login_url"
}

# Function to logout from wifi
logout_from_wifi() {
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
    curl -s -X POST -d "$form_data" "${headers[@]}" "$logout_url"
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

# Main function
main() {
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

    # Connect to Wi-Fi network
    connect_to_wifi
    sleep 5

    # Login to wifi
    echo "Logging in to wifi ...."
    login_to_wifi "$username" "$password"
    echo "Login done."

    # Prompt user to log out if needed
    read -p "Do you want to log out? (y/n): " choice
    if [ "$choice" = "y" ]; then
        logout_from_wifi "$username"
        #clear_credentials
    fi
}

# Execute the main function
main

