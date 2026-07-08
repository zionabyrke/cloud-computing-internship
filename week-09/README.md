# Week 9 - Cloud Security & IAM Fundamentals

**Date Range:** July 6 – July 10, 2026
**Status:** ✅ Done
**Key Deliverable:** IAM structure, CloudTrail trail, CloudWatch alarm, SNS alert

---

## Overview

Week 9 covered AWS IAM and CloudTrail. No personal AWS account was available - credits ran out after an EC2 was left running in a previous course - so a classmate's account was used with a borrower IAM admin user. Everything was done through the AWS CLI on Arch Linux.

The module's Trail setup only covers S3 delivery. To get metric filters working, CloudWatch Logs delivery had to be added, which required a separate IAM role (`CloudTrail-CWL-Role`) with a custom trust and permissions policy. That wasn't in the module.

---

## Tasks

| # | Task | Date | Status |
|---|------|------|--------|
| 1 | AWS IAM Basics and Admin Setup | July 7 | ✅ |
| 2 | Custom Least-Privilege EC2 Policy | July 7 | ✅ |
| 3 | IAM Role for EC2 | July 7 | ✅ |
| 4 | CloudTrail with CloudWatch Logs | July 7 | ✅ |
| 5 | SNS Alerting and Detection Test | July 7 | ✅ |
| 6 | IAM Security Hardening | July 7 | ✅ |
| 7 | Full Cleanup | July 7 | ✅ |

---

## Environment

| | |
|-|-|
| Machine | Local Arch Linux |
| AWS CLI | v1.44.81 |
| Account | Classmate's IAM admin user |
| Region | ap-southeast-2 (trail), us-east-1 (IAM events) |

---

## Files

| File | Description |
|------|-------------|
| `README.md` | This file |
| `commands.sh` | All AWS CLI commands by task |
| `setup-notes.md` | Task documentation |
| `policies/ec2-limited-policy.json` | Least-privilege EC2 policy |
| `policies/ec2-trust.json` | EC2SecureRole trust policy |

---

## Issues & Resolutions

| Issue | Resolution |
|-------|------------|
| `create-role` rejected trust policy for non-ASCII characters from nano paste | Rewrote the file using a heredoc |
| IAM `AccessDenied` event never reached the single-region trail in ap-southeast-2 | IAM/STS events are fixed to us-east-1, converted trail to multi-region |
| CloudWatch Logs never received the cross-region event even after 30+ minutes | Confirmed detection via `lookup-events` (bypasses delivery pipeline) and verified the alarm/SNS chain with a manual `put-metric-data` |
| Zsh threw an error for unquoted `*` in CloudWatch Logs ARN | Quoted the full ARN string |

---

## References

- [CloudTrail Concepts - Global Service Events](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-concepts.html)
- [Understanding Multi-Region Trails](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-multi-region-trails.html)
- [IAM Access Analyzer](https://docs.aws.amazon.com/IAM/latest/UserGuide/what-is-access-analyzer.html)
