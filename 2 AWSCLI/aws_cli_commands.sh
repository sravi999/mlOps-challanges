#!/bin/bash

verify(){

        if [[ $1 -gt 0 ]];then
                echo $2
        else
                echo $3
        fi

}

# Show the contents of the hypothetical s3 bucket Important Data/logs

aws s3 ls s3://ravi-test-ml-01 --recursive
exit_code=$?
verify $exit_code "Failed to show content for ravi-test-ml-01 bucket" " \
                 Successfully displayed the content of the ravi-test-ml-01 bucket"


# Change the name of an IAM user

change_user=$(aws iam update-user --user-name Bob --new-user-name Robert)
exit_code=$?
verify $exit_code "Failed to change the name of an IAM User" "Successfully changed the name of IAM User"


# Add the caller's IP address to a hypothetical security group sg_3452925

# Get your current public IP address
my_ip=$(curl -s http://checkip.amazonaws.com)
security_group_id="sg-3452925"
update_sg=$(aws ec2 authorize-security-group-ingress \
         --group-id $security_group_id \
         --protocol tcp --port 22 \
         --cidr $my_ip/32)
exit_code=$?
echo $update_sg
verify $exit_code "Failed to Add the caller's IP address to security group" " \
        Successful to Add the caller's IP address to security group"

# Instantiate a new policy and attach it to the hypothetical role developer_level2

create_policy=$(aws iam create-policy \
    --policy-name my-policy \
    --policy-document file://policy.json)
exit_code=$?
verify $exit_code "Failed to create a new policy" "Successfully created a new policy"
policy_arn=$(echo $create_policy|jq -r .Policy.Arn)

policy_attach=$(aws iam attach-role-policy --policy-arn $policy_arn --role-name developer_level2)
exit_code=$?
verify $exit_code "Failed to attach policy to role" "Successfully attached policy to role"