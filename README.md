# WiFi KIET Login Script

The WiFi KIET Login Script is a Bash script designed to automate the process of logging in and out of the WiFi network at KIET College.

## Features

- **Automatic Login**: The script facilitates automatic login to the KIET College WiFi network using stored credentials.
- **Secure Credential Storage**: User credentials (username and password) are securely stored using GPG encryption.
- **Automatic Script Execution**: The script can be configured to run automatically on system boot using `systemd`.
- **Error Handling**: Comprehensive error handling ensures smooth execution and provides informative error messages in case of failures.

## Requirements

- **Bash Shell**: The script is written in Bash and requires a Bash-compatible shell to run.
- **GnuPG**: GPG is used for encrypting and decrypting user credentials. Ensure that GnuPG is installed on your system.
- **systemd**: For automatic execution on system boot, `systemd` must be available on the system.

Certainly! Here's an updated version of the installation section in the README to include the option of using `curl` to directly execute the setup script from its raw link:

---

## Installation


### Option 1: Quick Installation via `curl`

```bash
curl -fssL https://raw.githubusercontent.com/ksauraj/Wifi-Kiet-Login/main/setup.sh | sudo bash
```


### Option 2: Manual Installation

Alternatively, you can execute the setup script directly from its raw link using `curl` and `bash`. This method is convenient and saves time:

1. **Clone the Repository**: Clone the repository to your local machine:

    ```bash
    git clone https://github.com/ksauraj/Wifi-Kiet-Login.git
    ```

2. **Navigate to the Directory**: Change into the directory containing the script:

    ```bash
    cd Wifi-Kiet-Login
    ```

3. **Set Execution Permissions**: Ensure that the script is executable:

    ```bash
    chmod +x setup.sh
    ```

4. **Run the Setup Script**: Execute the setup script to initialize the script and configure automatic execution:

    ```bash
    sudo setup.sh
    ```

> **Follow On-Screen Instructions**: Follow the on-screen prompts to enter your WiFi credentials and configure automatic execution.

## Troubleshooting

- **Permission Denied**: If you encounter "Permission denied" errors, ensure that you have the necessary permissions to execute the script and write to system directories. You may need to run the script with elevated privileges using `sudo`.

  ```bash
  sudo ./setup.sh
  ```

- **Script Execution Issues**: If you experience issues with script execution or automatic execution on system boot, check the system logs for error messages. Use `journalctl` to view logs related to the `wifi-kiet-login.service`.

  ```bash
  journalctl -u wifi-kiet-login.service --boot
  ```

## Contributing

Contributions to the WiFi KIET Login Script are welcome! If you find any bugs or have suggestions for improvements, please open an issue or submit a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

You can copy and paste this README into your project's repository, or you can create a new `README.md` file and replace its contents with the above text.
