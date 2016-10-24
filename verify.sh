#!/usr/bin/env bash
aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=running" | \
  jq -j '.Reservations[].Instances[] | .InstanceId, "  ", .Placement.AvailabilityZone, "  ", .PrivateIpAddress, "  ", .PublicIpAddress, "\n"'
