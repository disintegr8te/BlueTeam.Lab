#!/bin/bash

# This script ensures specific versions of Azure CLI, Terraform, and Ansible are installed without creating redundant entries or duplicates.

echo "Starting the setup of prerequisites for BlueTeam.Lab..."

# Ensure the system is updated and has required packages
sudo apt-get update
sudo apt-get install -y software-properties-common curl git python3-pip python3-venv

# Function to install Azure CLI
install_azure_cli() {
    echo "Installing the latest Azure CLI..."
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
}

# Function to install the latest version of Terraform
install_terraform() {
    echo "Installing the latest Terraform..."
    local repo_url="https://apt.releases.hashicorp.com $(lsb_release -cs) main"
    local repo_entry="deb [arch=amd64] $repo_url"
    # Search for the repo entry in all APT sources and count occurrences
    local count=$(grep -Rhs "^$repo_entry" /etc/apt/sources.list /etc/apt/sources.list.d/ | wc -l)
    # Add the repository only if it's not already present
    if [ "$count" -eq 0 ]; then
        curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
        sudo apt-add-repository "$repo_entry"
    else
        echo "HashiCorp repository is already added."
    fi
    sudo apt-get update && sudo apt-get install -y terraform
}

# Function to install a specific version of Ansible and additional Python packages
install_ansible() {
    echo "Setting up Python environment for Ansible..."
    python3 -m venv ~/ansible-env
    source ~/ansible-env/bin/activate
    pip install --upgrade pip
    pip install ansible==2.12.*  # Install Ansible 2.12 to ensure compatibility
    ansible-galaxy collection install azure.azcollection  # Install the latest available Azure collection
    # Install additional Python packages required for Azure and Windows management
    pip install pywinrm requests msrest msrestazure azure-cli packaging
    deactivate
}

# Clean up any previous installations
echo "Cleaning up old installations..."
sudo apt-get remove --purge -y ansible terraform azure-cli
sudo apt-get autoremove -y
rm -rf ~/ansible-env

# Execute installations
install_azure_cli
install_terraform
install_ansible

echo "All prerequisites have been installed successfully."
