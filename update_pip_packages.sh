#!/bin/bash

# PIP UPDATER SCRIPT - BY FXPRO - 2024
# This simple Python Script will update all packages on PIP, on multiple platforms as well as checks for conflicts and dependency issues.

# Function to install jq on Fedora-based systems
install_jq_fedora() {
    echo "Fedora-based OS detected."
    echo "Checking if jq is installed..."
    if ! command -v jq &> /dev/null; then
        echo "jq not found. Installing jq..."
        sudo dnf install -y jq
        if [ $? -ne 0 ]; then
            echo "Failed to install jq. Please install jq manually and rerun the script."
            exit 1
        fi
        echo "jq installed successfully."
    else
        echo "jq is installed...ok"
    fi
}

# Function to install jq on Debian-based systems
install_jq_debian() {
    echo "Debian-based OS detected."
    echo "Checking if jq is installed..."
    if ! command -v jq &> /dev/null; then
        echo "jq not found. Installing jq..."
        sudo apt-get install -y jq
        if [ $? -ne 0 ]; then
            echo "Failed to install jq. Please install jq manually and rerun the script."
            exit 1
        fi
        echo "jq installed successfully."
    else
        echo "jq is installed...ok"
    fi
}

# Function to install jq on Windows
install_jq_windows() {
    echo "Windows OS detected."
    echo "Checking if jq is installed..."
    if ! command -v jq &> /dev/null; then
        echo "jq not found. Installing jq..."
        # Download jq.exe and place it in a directory that is in the system PATH
        curl -Lo jq.exe https://github.com/stedolan/jq/releases/download/jq-1.6/jq-win64.exe
        if [ $? -ne 0 ]; then
            echo "Failed to download jq. Please install jq manually and rerun the script."
            exit 1
        fi
        mv jq.exe /usr/local/bin/jq
        echo "jq installed successfully."
    else
        echo "jq is installed...ok"
    fi
}

# Function to install jq on macOS
install_jq_macos() {
    echo "macOS detected."
    echo "Checking if jq is installed..."
    if ! command -v jq &> /dev/null; then
        echo "jq not found. Installing jq..."
        brew install jq
        if [ $? -ne 0 ]; then
            echo "Failed to install jq. Please install jq manually and rerun the script."
            exit 1
        fi
        echo "jq installed successfully."
    else
        echo "jq is installed...ok"
    fi
}

# Identify the operating system
OS="$(uname -s)"
case "$OS" in
    Linux*)
        . /etc/os-release
        case "$ID" in
            fedora|rhel|centos|nobara)
                install_jq_fedora
                ;;
            debian|ubuntu|linuxmint)
                install_jq_debian
                ;;
            *)
                case "$ID_LIKE" in
                    fedora|rhel|centos)
                        install_jq_fedora
                        ;;
                    debian)
                        install_jq_debian
                        ;;
                    *)
                        echo "Unsupported Linux distribution: $ID. Please install jq manually."
                        exit 1
                        ;;
                esac
                ;;
        esac
        ;;
    Darwin*)
        install_jq_macos
        ;;
    CYGWIN*|MINGW*|MSYS*)
        install_jq_windows
        ;;
    *)
        echo "Unsupported OS. Please run this script on Linux, macOS, or Windows."
        exit 1
        ;;
esac

echo "Starting the update process..."

# List outdated packages
outdated_json=$(pip list --outdated --format=json)
echo "Raw outdated packages JSON:"
echo "$outdated_json"

# Parse the JSON to get the names of outdated packages
outdated=$(echo "$outdated_json" | jq -r '.[].name')

echo "Outdated packages detected:"
echo "$outdated"

# Initialize arrays to keep track of updated packages, errors, and conflicts
updated_packages=()
failed_packages=()
conflicting_packages=()

# Function to check if updating a package will cause a conflict
check_conflict() {
    pkg=$1
    echo "Checking dependencies for $pkg..."
    requirements=$(pip show "$pkg" | grep Requires | awk -F': ' '{print $2}' | tr ',' '\n' | tr -d '[:space:]')
    for req in $requirements; do
        dep_pkg=$(echo $req | awk -F'[>=<]' '{print $1}')
        required_version=$(echo $req | grep -oP '[>=<].*' | tr -d '[:space:]')
        if [ -n "$required_version" ];then
            installed_version=$(pip show "$dep_pkg" | grep Version | awk '{print $2}')
            echo "$pkg requires $dep_pkg $required_version, installed version: $installed_version"
            if [ "$installed_version" != "$required_version" ];then
                echo "$pkg cannot be updated due to a conflict with $dep_pkg $required_version"
                return 0
            fi
        fi
    done
    return 1
}

# Update each package
for pkg in $outdated; do
    echo "Updating $pkg..."
    if ! check_conflict "$pkg"; then
        echo "$pkg cannot be updated due to a dependency conflict. Skipping update."
        conflicting_packages+=("$pkg")
        continue
    fi
    if pip install -U "$pkg"; then
        echo "$pkg updated successfully."
        updated_packages+=("$pkg")
    else
        echo "Failed to update $pkg. Skipping..."
        failed_packages+=("$pkg")
    fi
done

# Display the list of updated packages
if [ ${#updated_packages[@]} -eq 0 ]; then
    echo "No packages were updated."
else
    echo "The following packages were successfully updated:"
    for pkg in "${updated_packages[@]}"; do
        echo "- $pkg"
    done
fi

# Display the list of conflicting packages
if [ ${#conflicting_packages[@]} -ne 0 ]; then
    echo "The following packages were skipped due to dependency conflicts:"
    for pkg in "${conflicting_packages[@]}"; do
        echo "- $pkg"
    done
fi

# Display the list of failed packages, if any
if [ ${#failed_packages[@]} -ne 0 ]; then
    echo "The following packages could not be updated due to errors:"
    for pkg in "${failed_packages[@]}"; do
        echo "- $pkg"
    done
fi

echo "Update process completed."
