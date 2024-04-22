#!/bin/bash

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

# Function to store credentials in a hidden file
store_credentials() {
    local username="$1"
    local password="$2"

    echo "$username:$password" > .credentials
    chmod 600 .credentials  # Set appropriate permissions
}

# Function to read credentials from the hidden file
read_credentials() {
    if [ -f .credentials ]; then
        read -r username password < .credentials
        echo "Credentials found. Username: $username"
    else
        echo "No stored credentials found."
    fi
}

# Function to clear stored credentials
clear_credentials() {
    rm -f .credentials
    echo "Credentials cleared."
}

# Main function
main() {
    display_message

    # Check if credentials exist
    read_credentials

    # If credentials not found, prompt for credentials and login
    if [ -z "$username" ]; then
        get_credentials
        login_to_wifi "$username" "$password"
        store_credentials "$username" "$password"
    fi

    # Prompt user to log out if needed
    read -p "Do you want to log out? (y/n): " choice
    if [ "$choice" = "y" ]; then
        logout_from_wifi "$username"
        clear_credentials
    fi
}

# Execute the main function
main

