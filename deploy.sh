#!/bin/bash

# Update system packages
sudo yum update -y

# Install Python 3 and pip
sudo yum install python3 python3-pip -y

# Install Git
sudo yum install git -y

# Clone the repository (replace with your actual repository URL)
git clone https://github.com/davidaws2/Project_Pokemon_api
cd pokemon-collector

# Install Python dependencies
pip3 install -r requirements.txt

# Run the application
python3 pokiapi.py