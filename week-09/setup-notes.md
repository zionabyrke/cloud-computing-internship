# Week 9 Setup Notes - Cloud Security & IAM Fundamentals

**Intern:** Renz Kirby Onia
**Date Range:** July 6–10, 2026
**Environment:** Local Arch Linux | AWS CLI v1.44.81 | ap-southeast-2 | Account: <AccountID>

---

## Task 1 - AWS IAM Basics and Admin Setup

**July 7, 2026**

```bash
aws configure
aws sts get-caller-identity
aws iam create-user --user-name intern-user
```

`get-caller-identity` confirmed the session was the IAM admin user, not root, before creating anything.

---

## Task 2 - Custom Least-Privilege EC2 Policy

**July 7, 2026**

The module suggests attaching `AmazonEC2ReadOnlyAccess` (AWS managed, broad). Instead, wrote a custom policy scoped to exactly three EC2 actions: `StartInstances`, `StopInstances`, `DescribeInstances`. See `policies/ec2-limited-policy.json`.

```bash
aws iam create-policy \
  --policy-name EC2LimitedAccess \
  --policy-document file://policies/ec2-limited-policy.json

aws iam attach-user-policy \
  --user-name intern-user \
  --policy-arn arn:aws:iam::<AccountID>:policy/EC2LimitedAccess

aws iam list-attached-user-policies --user-name intern-user
```

`list-attached-user-policies` confirmed only `EC2LimitedAccess` - nothing extra.

---

## Task 3 - IAM Role for EC2

**July 7, 2026**

Created `EC2SecureRole` with a trust policy allowing the EC2 service to assume it, then attached the same `EC2LimitedAccess` policy.

```bash
aws iam create-role \
  --role-name EC2SecureRole \
  --assume-role-policy-document file://policies/ec2-trust.json

aws iam attach-role-policy \
  --role-name EC2SecureRole \
  --policy-arn arn:aws:iam::<AccountID>:policy/EC2LimitedAccess
```

`create-role` rejected the first attempt - non-ASCII characters got pasted into `ec2-trust.json` through nano. Rewrote it using a heredoc:

```bash
cat > policies/ec2-trust.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": { "Service": "ec2.amazonaws.com" },
    "Action": "sts:AssumeRole"
  }]
}
EOF
```

---

## Task 4 - CloudTrail with CloudWatch Logs

**July 7, 2026**

The module's `create-trail` command only targets S3. To get metric filters working in Task 5, CloudWatch Logs delivery also had to be wired in, which requires a dedicated IAM role that grants CloudTrail permission to write to CloudWatch Logs.

Created the S3 bucket, applied the bucket policy allowing CloudTrail to write, created the log group, created `CloudTrail-CWL-Role` with the appropriate trust and permissions policy, then created the trail with both targets:

```bash
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
```

`get-trail-status` returned `IsLogging: true`. The ARN had to be quoted - zsh expands the unquoted `*` at the end before the CLI sees it.

---

## Task 5 - SNS Alerting and Detection Test

**July 7, 2026**

```bash
aws sns create-topic --name security-alerts
aws sns subscribe \
  --topic-arn arn:aws:sns:ap-southeast-2:<AccountID>:security-alerts \
  --protocol email \
  --notification-endpoint <email>

aws logs put-metric-filter \
  --log-group-name CloudTrail/DefaultLogGroup \
  --filter-name UnauthorizedAPICalls \
  --filter-pattern '{ ($.errorCode="*UnauthorizedOperation") || ($.errorCode="AccessDenied*") }' \
  --metric-transformations metricName=UnauthorizedAPICalls,metricNamespace=SecurityMetrics,metricValue=1

aws cloudwatch put-metric-alarm \
  --alarm-name UnauthorizedAPICallsAlarm \
  --metric-name UnauthorizedAPICalls \
  --namespace SecurityMetrics \
  --statistic Sum --period 300 --threshold 1 \
  --comparison-operator GreaterThanOrEqualToThreshold \
  --evaluation-periods 1 \
  --alarm-actions arn:aws:sns:ap-southeast-2:<AccountID>:security-alerts
```

Triggered a denied event by running `aws iam list-users` as `intern-user`, which doesn't have that permission. Then waited. Nothing arrived in CloudWatch Logs after 30+ minutes.

The reason: IAM and STS events are always recorded in `us-east-1`, regardless of where the trail is. The trail was single-region in `ap-southeast-2` so it never captured the event. Converted to multi-region:

```bash
aws cloudtrail update-trail --name security-trail --is-multi-region-trail
```

Still no CloudWatch delivery after waiting - but S3 did receive the event, which only showed up during the bucket cleanup in Task 7. Two separate delivery paths on the same trail, while one working doesn't guarantee the other.

Verified detection two ways instead:

```bash
# Confirm the denied event exists in Event History (bypasses trail delivery)
aws cloudtrail lookup-events \
  --region us-east-1 \
  --lookup-attributes AttributeKey=EventName,AttributeValue=ListUsers

# Manually trigger the alarm/SNS chain
aws cloudwatch put-metric-data \
  --namespace SecurityMetrics \
  --metric-name UnauthorizedAPICalls \
  --value 1
```

`lookup-events` returned the full denied `ListUsers` event. The manual `put-metric-data` flipped the alarm to `ALARM` and the SNS email arrived almost immediately. Both sides confirmed - just not through a single end-to-end path.

---

## Task 6 - IAM Security Hardening

**July 7, 2026**

```bash
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
```

`list-access-keys` showed the old key as `Inactive` and the new key as `Active`.

---

## Task 7 - Full Cleanup

**July 7, 2026**

```bash
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
```

