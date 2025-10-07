#!/bin/bash

# AWS IoT Greengrass IAM Resources Creation Script
# This script creates necessary IAM resources for Greengrass setup

set -e

USER_NAME="greengrass-device-user"
POLICY_NAME="GreengrassDevicePolicy"
ROLE_NAME="GreengrassV2TokenExchangeRole"
REGION="${AWS_DEFAULT_REGION:-ap-northeast-1}"

echo "Creating IAM resources for Greengrass..."

# Get account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Create IAM user
echo "Creating IAM user: $USER_NAME"
aws iam create-user --user-name $USER_NAME --path "/greengrass/" || echo "User may already exist"

# Create IAM policy from JSON file
echo "Creating IAM policy: $POLICY_NAME"
aws iam create-policy \
    --policy-name $POLICY_NAME \
    --policy-document file://policies/greengrass-user-policy.json \
    --path "/greengrass/" || echo "Policy may already exist"

# Attach policy to user
echo "Attaching policy to user..."
POLICY_ARN="arn:aws:iam::${ACCOUNT_ID}:policy/greengrass/${POLICY_NAME}"
aws iam attach-user-policy --user-name $USER_NAME --policy-arn $POLICY_ARN

# Create access key
echo "Creating access key for user..."
ACCESS_KEY_OUTPUT=$(aws iam create-access-key --user-name $USER_NAME --output json)

ACCESS_KEY_ID=$(echo $ACCESS_KEY_OUTPUT | jq -r '.AccessKey.AccessKeyId')
SECRET_ACCESS_KEY=$(echo $ACCESS_KEY_OUTPUT | jq -r '.AccessKey.SecretAccessKey')

# Create Greengrass service role
echo "Creating Greengrass service role: $ROLE_NAME"
aws iam create-role \
    --role-name $ROLE_NAME \
    --assume-role-policy-document file://policies/greengrass-service-role.json \
    --path /service-role/ || echo "Role may already exist"

# Put inline policy for the role
echo "Adding policy to service role..."
aws iam put-role-policy \
    --role-name $ROLE_NAME \
    --policy-name GreengrassV2TokenExchangePolicy \
    --policy-document file://policies/greengrass-role-policy.json

# Output credentials
echo ""
echo "✅ IAM resources created successfully!"
echo ""
echo "📋 Credentials (save these securely):"
echo "Access Key ID: $ACCESS_KEY_ID"
echo "Secret Access Key: $SECRET_ACCESS_KEY"
echo "Region: $REGION"
echo ""
echo "🔐 Created Resources:"
echo "- IAM User: $USER_NAME"
echo "- IAM Policy: $POLICY_NAME"
echo "- Service Role: $ROLE_NAME"
echo ""
echo "⚠️  IMPORTANT: Save these credentials securely and do not share them publicly."
echo "Use these credentials with Amazon Q Developer to create the deployment script."