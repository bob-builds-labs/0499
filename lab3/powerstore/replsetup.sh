#!/bin/bash
wget https://github.com/dell/csm-replication/releases/download/v1.10.0/repctl-linux-amd64
mv repctl-linux-amd64 ~/.local/bin/repctl
chmod +X ~/.local/bin/repctl
chmod 755 ~/.local/bin/repctl
repctl cluster add -f ${KUBECONFIG} -n "openshift-1"
repctl create -f ~/workspace/0499/lab3/powerstore/replicationcrds.all.yaml
repctl create -f ~/workspace/0499/lab3/powerstore/controller.yaml
repctl cluster inject --use-sa
repctl create sc --from-config ~/workspace/0499/lab3/powerstore/powerstore_replication.yaml