#!/bin/bash

# Set variables
REGION="us-west-2"
INSTANCE_TYPE="t2.micro"
AMI_ID="ami-0d081196e3df05f4d"  # Amazon Linux 2 AMI in us-west-2
INSTANCE_NAME="pokiapi"
KEY_NAME="poki_game_key"

# Create a new key pair
echo "Creating new key pair: $KEY_NAME"
KEY_MATERIAL=$(aws ec2 create-key-pair --key-name $KEY_NAME --query 'KeyMaterial' --output text --region $REGION)

if [ -z "$KEY_MATERIAL" ]; then
    echo "Error: Failed to create key pair. Please check your AWS credentials and permissions."
    exit 1
fi

# Save the key pair to a file
KEY_FILE="${KEY_NAME}.pem"
echo "$KEY_MATERIAL" > $KEY_FILE
chmod 400 $KEY_FILE
echo "Key pair saved as $KEY_FILE with permissions 400"

# Find user's VPCs
echo "Available VPCs:"
aws ec2 describe-vpcs --region $REGION --query 'Vpcs[*].[VpcId,Tags[?Key==`Name`].Value|[0]]' --output table

# Prompt user to select a VPC
read -p "Enter the VPC ID you want to use: " VPC_ID

# Verify if the VPC exists
if ! aws ec2 describe-vpcs --vpc-ids $VPC_ID --region $REGION &> /dev/null; then
    echo "Error: VPC '$VPC_ID' not found. Please enter a valid VPC ID."
    exit 1
fi

echo "Using VPC: $VPC_ID"

# Create a security group
SECURITY_GROUP_NAME="pokemon-collector-sg"
SECURITY_GROUP_ID=$(aws ec2 create-security-group \
    --group-name $SECURITY_GROUP_NAME \
    --description "Security group for Pokemon Collector" \
    --vpc-id $VPC_ID \
    --region $REGION \
    --output text)

echo "Created Security Group: $SECURITY_GROUP_ID"

# Add inbound rules to the security group
aws ec2 authorize-security-group-ingress \
    --group-id $SECURITY_GROUP_ID \
    --protocol tcp \
    --port 22 \
    --cidr 0.0.0.0/0 \
    --region $REGION

# Create EC2 instance
INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --count 1 \
    --instance-type $INSTANCE_TYPE \
    --key-name $KEY_NAME \
    --security-group-ids $SECURITY_GROUP_ID \
    --region $REGION \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCE_NAME}]" \
    --query 'Instances[0].InstanceId' \
    --output text)

echo "Created EC2 instance: $INSTANCE_ID"

# Wait for the instance to be running
aws ec2 wait instance-running --instance-ids $INSTANCE_ID --region $REGION

# Get the public IP address of the instance
PUBLIC_IP=$(aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --region $REGION \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text)

echo "EC2 instance '$INSTANCE_NAME' is now running with IP: $PUBLIC_IP"
echo "You can SSH into the instance using: ssh -i $KEY_FILE ec2-user@$PUBLIC_IP"
