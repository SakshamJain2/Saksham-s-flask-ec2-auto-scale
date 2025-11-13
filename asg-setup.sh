#!/bin/bash

REGION="ap-south-1"
AMI_ID="ami-0e306788ff2473ccb"
INSTANCE_TYPE="t2.micro"
KEY_NAME="my-key"
SECURITY_GROUP="web-sg"
LAUNCH_TEMPLATE_NAME="FlaskAutoScaleTemplate"
ASG_NAME="FlaskAutoScalingGroup"
TARGET_GROUP_NAME="FlaskTargetGroup"
LB_NAME="FlaskAppLoadBalancer"
SUBNETS="subnet-xxxx subnet-yyyy"
VPC_ID="vpc-xxxxxxx"

aws ec2 create-launch-template   --launch-template-name $LAUNCH_TEMPLATE_NAME   --version-description "FlaskApp-v1"   --launch-template-data "{
    \"ImageId\":\"$AMI_ID\",
    \"InstanceType\":\"$INSTANCE_TYPE\",
    \"KeyName\":\"$KEY_NAME\",
    \"SecurityGroupIds\":[\"$SECURITY_GROUP\"],
    \"UserData\":\"$(base64 -w0 < user-data.sh)\"
  }"

aws elbv2 create-target-group   --name $TARGET_GROUP_NAME   --protocol HTTP   --port 80   --vpc-id $VPC_ID   --target-type instance   --health-check-path /

aws elbv2 create-load-balancer   --name $LB_NAME   --subnets $SUBNETS   --security-groups $SECURITY_GROUP   --scheme internet-facing

TG_ARN=$(aws elbv2 describe-target-groups --names $TARGET_GROUP_NAME --query "TargetGroups[0].TargetGroupArn" --output text)
LB_ARN=$(aws elbv2 describe-load-balancers --names $LB_NAME --query "LoadBalancers[0].LoadBalancerArn" --output text)

aws elbv2 create-listener   --load-balancer-arn $LB_ARN   --protocol HTTP   --port 80   --default-actions Type=forward,TargetGroupArn=$TG_ARN

aws autoscaling create-auto-scaling-group   --auto-scaling-group-name $ASG_NAME   --launch-template "LaunchTemplateName=$LAUNCH_TEMPLATE_NAME,Version=1"   --min-size 1   --max-size 3   --desired-capacity 1   --vpc-zone-identifier "$SUBNETS"   --target-group-arns $TG_ARN

echo "✅ Auto Scaling Group and Load Balancer setup complete!"
