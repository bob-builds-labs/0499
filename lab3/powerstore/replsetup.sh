#!/bin/bash
wget https://github.com/dell/csm-replication/releases/download/v1.10.0/repctl-linux-amd64
mv repctl-linux-amd64 ~/.local/bin/repctl
chmod +X ~/.local/bin/repctl
chmod 755 ~/.local/bin/repctl
repctl cluster add -f ${KUBECONFIG} -n "openshift-1"
repctl create -f https://raw.githubusercontent.com/dell/csm-replication/refs/tags/v1.10.0/deploy/replicationcrds.all.yaml
repctl create -f https://raw.githubusercontent.com/dell/csm-replication/refs/tags/v1.10.0/deploy/controller.yaml