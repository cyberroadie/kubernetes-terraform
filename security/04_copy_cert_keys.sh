#!/usr/bin/env bash
KUBERNETES_HOSTS=(controller0 controller1 controller2 worker0 worker1 worker2)

for host in ${KUBERNETES_HOSTS[*]}; do
  echo ${host}
  PUBLIC_IP_ADDRESS=$(aws ec2 describe-instances \
    --filters "Name=instance-state-name,Values=running,Name=tag:Name,Values=${host}" | \
    jq -r '.Reservations[].Instances[].PublicIpAddress')

  echo $PUBLIC_IP_ADDRESS

  scp -q ca.pem kubernetes-key.pem kubernetes.pem \
    ubuntu@${PUBLIC_IP_ADDRESS}:~/
done