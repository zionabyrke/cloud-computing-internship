#!/usr/bin/env bash
# Week 9 - Cloud Security & IAM Fundamentals
# Cloud Computing Internship | Lamina Studios, LLC.
# Intern: Renz Kirby Onia
#
# AWS CLI commands run on local Arch Linux against a classmate's AWS account.
# Region: ap-southeast-2

# Task 1: Admin setup
aws configure
aws sts get-caller-identity
aws iam create-user --user-name intern-user

# Task 2: Custom least-privilege EC2 policy
aws iam create-policy \
  --policy-name EC2LimitedAccess \
  --policy-document file://policies/ec2-limited-policy.json

aws iam attach-user-policy \
  --user-name intern-user \
  --policy-arn arn:aws:iam::<AccountID>:policy/EC2LimitedAccess

aws iam list-attached-user-policies --user-name intern-user

# Task 3: IAM role for EC2
aws iam create-role \
  --role-name EC2SecureRole \
  --assume-role-policy-document file://policies/ec2-trust.json

aws iam attach-role-policy \
  --role-name EC2SecureRole \
  --policy-arn arn:aws:iam::<AccountID>:policy/EC2LimitedAccess

aws iam list-attached-role-policies --role-name EC2SecureRole

# Task 4: CloudTrail with CloudWatch Logs
aws s3api create-bucket \
  --bucket security-trail-logs-5207 \
  --region ap-southeast-2 \
  --create-bucket-configuration LocationConstraint=ap-southeast-2

aws logs create-log-group --log-group-name CloudTrail/DefaultLogGroup

aws cloudtrail create-trail \
  --name security-trail \
  --s3-bucket-name security-trail-logs-5207 \
  --cloud-watch-logs-log-group-arn "arn:aws:logs:ap-southeast-2:<AccountID>:log-group:CloudTrail/DefaultLogGroup:*" \
  --cloud-watch-logs-role-arn arn:aws:iam::<AccountID>:role/CloudTrail-CWL-Role

aws cloudtrail start-logging --name security-trail
aws cloudtrail get-trail-status --name security-trail

# Task 5: SNS alerting and detection test
aws sns create-topic --name security-alerts

aws sns subscribe \
  --topic-arn arn:aws:sns:ap-southeast-2:<AccountID>:security-alerts \
  --protocol email \
  --notification-endpoint <your-email>

aws logs put-metric-filter \
  --log-group-name CloudTrail/DefaultLogGroup \
  --filter-name UnauthorizedAPICalls \
  --filter-pattern '{ ($.errorCode="*UnauthorizedOperation") || ($.errorCode="AccessDenied*") }' \
  --metric-transformations metricName=UnauthorizedAPICalls,metricNamespace=SecurityMetrics,metricValue=1

aws cloudwatch put-metric-alarm \
  --alarm-name UnauthorizedAPICallsAlarm \
  --metric-name UnauthorizedAPICalls \
  --namespace SecurityMetrics \
  --statistic Sum \
  --period 300 \
  --threshold 1 \
  --comparison-operator GreaterThanOrEqualToThreshold \
  --evaluation-periods 1 \
  --alarm-actions arn:aws:sns:ap-southeast-2:<AccountID>:security-alerts

# trigger denied event as intern-user
aws iam list-users --profile intern-user

# trail was single-region — convert to multi-region
aws cloudtrail update-trail --name security-trail --is-multi-region-trail

# verify event directly via Event History (bypasses delivery pipeline)
aws cloudtrail lookup-events \
  --region us-east-1 \
  --lookup-attributes AttributeKey=EventName,AttributeValue=ListUsers

# manually verify alarm/SNS chain
aws cloudwatch put-metric-data \
  --namespace SecurityMetrics \
  --metric-name UnauthorizedAPICalls \
  --value 1

# Task 6: IAM security hardening
aws accessanalyzer create-analyzer --analyzer-name week9-analyzer --type ACCOUNT

aws iam update-account-password-policy \
  --minimum-password-length 12 \
  --require-symbols \
  --require-numbers \
  --require-uppercase-characters \
  --require-lowercase-characters

aws iam create-access-key --user-name intern-user

aws iam update-access-key \
  --user-name intern-user \
  --access-key-id <OLD_KEY_ID> \
  --status Inactive

aws iam list-access-keys --user-name intern-user

# Task 7: Full cleanup
aws cloudwatch delete-alarms --alarm-names UnauthorizedAPICallsAlarm
aws logs delete-metric-filter --log-group-name CloudTrail/DefaultLogGroup --filter-name UnauthorizedAPICalls
aws sns delete-topic --topic-arn arn:aws:sns:ap-southeast-2:<AccountID>:security-alerts
aws cloudtrail stop-logging --name security-trail
aws cloudtrail delete-trail --name security-trail
aws logs delete-log-group --log-group-name CloudTrail/DefaultLogGroup
aws s3 rm s3://security-trail-logs-5207 --recursive
aws s3api delete-bucket --bucket security-trail-logs-5207
aws iam delete-role-policy --role-name CloudTrail-CWL-Role --policy-name CWLPermissions
aws iam delete-role --role-name CloudTrail-CWL-Role
aws iam detach-user-policy --user-name intern-user --policy-arn arn:aws:iam::<AccountID>:policy/EC2LimitedAccess
aws iam detach-role-policy --role-name EC2SecureRole --policy-arn arn:aws:iam::<AccountID>:policy/EC2LimitedAccess
aws iam delete-role --role-name EC2SecureRole
aws iam delete-policy --policy-arn arn:aws:iam::<AccountID>:policy/EC2LimitedAccess
aws iam delete-access-key --user-name intern-user --access-key-id <KEY_ID>
aws iam delete-user --user-name intern-user
