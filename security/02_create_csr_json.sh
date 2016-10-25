#!/usr/bin/env bash
KUBERNETES_PUBLIC_ADDRESS=$(aws elb describe-load-balancers \
  --load-balancer-name kubernetes | \
  jq -r '.LoadBalancerDescriptions[].DNSName')

  cat > kubernetes-csr.json <<EOF 
{
  "CN": "kubernetes",
  "hosts": [
    "worker0",
    "worker1",
    "worker2",
    "ip-10-240-0-20",
    "ip-10-240-0-21",
    "ip-10-240-0-22",
    "10.32.0.1",
    "10.240.0.10",
    "10.240.0.11",
    "10.240.0.12",
    "10.240.0.20",
    "10.240.0.21",
    "10.240.0.22",
    "${KUBERNETES_PUBLIC_ADDRESS}",
    "127.0.0.1"
  ],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "Kubernetes",
      "OU": "Cluster",
      "ST": "Oregon"
    }
  ]
}