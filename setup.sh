#!/bin/bash

# Path to your script
script_dir="$HOME/.ksau_script"
script_path="$script_dir/script.sh"

# Function to check if credentials exist
check_credentials() {
    if [ -f "$script_dir/.username.gpg" ] && [ -f "$script_dir/.password.gpg" ]; then
        echo "Credentials already exist. Skipping script execution."
        return 0
    else
        echo "Credentials not found. Running script to store credentials."
        return 1
    fi
}

# Function to add script to run on boot
add_to_boot() {
    if command -v crontab &> /dev/null; then
        # Adding to cron using crontab
        (crontab -l ; echo "@reboot $script_path") | crontab -
        echo "Script added to run on boot using crontab."
    elif command -v systemctl &> /dev/null; then
        # Adding as a systemd service
        cat > /etc/systemd/system/wifi-kiet-login.service <<EOF
[Unit]
Description=Wifi KIET Login Script
After=network.target

[Service]
Type=simple
ExecStart=$script_path

[Install]
WantedBy=multi-user.target
EOF
        systemctl daemon-reload
        systemctl enable wifi-kiet-login.service
        echo "Script added to run on boot using systemd."
    else
        echo "Error: Neither crontab nor systemctl found. Manual configuration required."
    fi
}

# Execute the function to check if credentials exist
check_credentials
credentials_exist=$?

# If credentials don't exist, run the script to store them
if [ $credentials_exist -eq 1 ]; then
    # Make sure script directory exists
    mkdir -p "$script_dir"
    # Copy script to safe directory
    cp script.sh "$script_path"
    chmod +x "$script_path"  # Set execute permissions for the script
    # Run the script
    bash "$script_path"
fi

# Add the script to run on boot
add_to_boot
