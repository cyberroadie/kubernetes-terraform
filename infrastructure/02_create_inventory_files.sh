#!/usr/bin/env bash
terraform output -json controller_ips | jq -r '.value[]' > ../provision/hosts_controllers 
terraform output -json worker_ips | jq -r '.value[]' > ../provision/hosts_workers 
