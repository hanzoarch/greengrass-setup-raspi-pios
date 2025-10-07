#!/bin/bash

# AWS IoT Greengrass Resources Cleanup Script
# This script removes all Greengrass-related AWS resources

set -e

# Configuration
USER_NAME="${1:-greengrass-device-user}"
POLICY_NAME="${2:-GreengrassDevicePolicy}"
ROLE_NAME="${3:-GreengrassV2TokenExchangeRole}"
REGION="${AWS_DEFAULT_REGION:-ap-northeast-1}"
BUCKET_PREFIX="${4:-greengrass-setup}"

echo "🗑️  Starting Greengrass resources cleanup..."
echo "Region: $REGION"

# Get account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# 1. Delete S3 buckets with prefix
echo "1. Cleaning up S3 buckets..."
aws s3api list-buckets --query "Buckets[?starts_with(Name, '$BUCKET_PREFIX')].Name" --output text | while read bucket; do
    if [ ! -z "$bucket" ]; then
        echo "  Deleting bucket: $bucket"
        aws s3 rm s3://$bucket --recursive --region $REGION 2>/dev/null || true
        aws s3 rb s3://$bucket --region $REGION 2>/dev/null || true
    fi
done

# 2. Delete IoT Things with Greengrass prefix
echo "2. Cleaning up IoT Things..."
aws iot list-things --region $REGION --query "things[?contains(thingName, 'RaspberryPi') || contains(thingName, 'Greengrass')].thingName" --output text | while read thing; do
    if [ ! -z "$thing" ]; then
        echo "  Processing Thing: $thing"
        
        # Get attached certificates
        aws iot list-thing-principals --thing-name $thing --region $REGION --query "principals[]" --output text | while read cert_arn; do
            if [ ! -z "$cert_arn" ]; then
                cert_id=$(echo $cert_arn | cut -d'/' -f2)
                echo "    Processing certificate: $cert_id"
                
                # Detach policies from certificate
                aws iot list-attached-policies --target $cert_arn --region $REGION --query "policies[].policyName" --output text | while read policy; do
                    if [ ! -z "$policy" ]; then
                        aws iot detach-policy --policy-name $policy --target $cert_arn --region $REGION 2>/dev/null || true
                    fi
                done
                
                # Detach certificate from thing
                aws iot detach-thing-principal --thing-name $thing --principal $cert_arn --region $REGION 2>/dev/null || true
                
                # Deactivate and delete certificate
                aws iot update-certificate --certificate-id $cert_id --new-status INACTIVE --region $REGION 2>/dev/null || true
                aws iot delete-certificate --certificate-id $cert_id --region $REGION 2>/dev/null || true
            fi
        done
        
        # Delete thing
        aws iot delete-thing --thing-name $thing --region $REGION 2>/dev/null || true
    fi
done

# 3. Delete Thing Groups
echo "3. Cleaning up Thing Groups..."
aws iot list-thing-groups --region $REGION --query "thingGroups[?contains(thingGroupName, 'Greengrass')].thingGroupName" --output text | while read group; do
    if [ ! -z "$group" ]; then
        echo "  Deleting Thing Group: $group"
        aws iot delete-thing-group --thing-group-name $group --region $REGION 2>/dev/null || true
    fi
done

# 4. Delete IoT Policies
echo "4. Cleaning up IoT Policies..."
aws iot list-policies --region $REGION --query "policies[?contains(policyName, 'Greengrass')].policyName" --output text | while read policy; do
    if [ ! -z "$policy" ]; then
        echo "  Deleting IoT Policy: $policy"
        aws iot delete-policy --policy-name $policy --region $REGION 2>/dev/null || true
    fi
done

# 5. Delete Role Aliases
echo "5. Cleaning up Role Aliases..."
aws iot list-role-aliases --region $REGION --query "roleAliases[?contains(@, 'Greengrass')]" --output text | while read alias; do
    if [ ! -z "$alias" ]; then
        echo "  Deleting Role Alias: $alias"
        aws iot delete-role-alias --role-alias $alias --region $REGION 2>/dev/null || true
    fi
done

# 6. Delete Greengrass Core Devices
echo "6. Cleaning up Greengrass Core Devices..."
aws greengrassv2 list-core-devices --region $REGION --query "coreDevices[?contains(coreDeviceThingName, 'RaspberryPi') || contains(coreDeviceThingName, 'Greengrass')].coreDeviceThingName" --output text | while read device; do
    if [ ! -z "$device" ]; then
        echo "  Deleting Core Device: $device"
        aws greengrassv2 delete-core-device --core-device-thing-name $device --region $REGION 2>/dev/null || true
    fi
done

# 7. Delete IAM User
echo "7. Cleaning up IAM User..."
if aws iam get-user --user-name $USER_NAME >/dev/null 2>&1; then
    # Detach policies
    aws iam list-attached-user-policies --user-name $USER_NAME --query "AttachedPolicies[].PolicyArn" --output text | while read policy_arn; do
        if [ ! -z "$policy_arn" ]; then
            aws iam detach-user-policy --user-name $USER_NAME --policy-arn $policy_arn 2>/dev/null || true
        fi
    done
    
    # Delete access keys
    aws iam list-access-keys --user-name $USER_NAME --query "AccessKeyMetadata[].AccessKeyId" --output text | while read key_id; do
        if [ ! -z "$key_id" ]; then
            aws iam delete-access-key --user-name $USER_NAME --access-key-id $key_id 2>/dev/null || true
        fi
    done
    
    # Delete user
    aws iam delete-user --user-name $USER_NAME 2>/dev/null || true
fi

# 8. Delete IAM Role
echo "8. Cleaning up IAM Role..."
if aws iam get-role --role-name $ROLE_NAME >/dev/null 2>&1; then
    # Detach managed policies
    aws iam list-attached-role-policies --role-name $ROLE_NAME --query "AttachedPolicies[].PolicyArn" --output text | while read policy_arn; do
        if [ ! -z "$policy_arn" ]; then
            aws iam detach-role-policy --role-name $ROLE_NAME --policy-arn $policy_arn 2>/dev/null || true
        fi
    done
    
    # Delete inline policies
    aws iam list-role-policies --role-name $ROLE_NAME --query "PolicyNames[]" --output text | while read policy_name; do
        if [ ! -z "$policy_name" ]; then
            aws iam delete-role-policy --role-name $ROLE_NAME --policy-name $policy_name 2>/dev/null || true
        fi
    done
    
    # Delete role
    aws iam delete-role --role-name $ROLE_NAME 2>/dev/null || true
fi

# 9. Delete IAM Policy
echo "9. Cleaning up IAM Policy..."
POLICY_ARN="arn:aws:iam::${ACCOUNT_ID}:policy/greengrass/${POLICY_NAME}"
aws iam delete-policy --policy-arn $POLICY_ARN 2>/dev/null || true

echo ""
echo "✅ Cleanup completed!"
echo "All Greengrass-related resources have been removed."