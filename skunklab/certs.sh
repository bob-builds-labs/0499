#!/bin/bash
# certificates come first in the chain
# patchg proxy for root ca
oc create configmap custom-ca \
     --from-file=ca-bundle.crt=ca.pem \
     -n openshift-config
oc patch proxy/cluster --type=merge --patch='{"spec":{"trustedCA":{"name":"custom-ca"}}}'

# patch api server

oc create secret tls api-secret --cert=fullchain_api.pem --key=key_api.pem -n openshift-config --insecure-skip-tls-verify=true 
oc patch apiserver cluster --type=merge -p '{"spec":{"servingCerts": {"namedCertificates": [{"names": ["api.ocs1.home.labbuildr.com"], "servingCertificate": {"name": "api-secret"}}]}}}'

# patch default ingress
oc create secret tls router-certs-full --cert=fullchain.pem --key=key.pem -n openshift-ingress
oc patch ingresscontroller.operator default -n openshift-ingress-operator --type=merge --patch='{"spec": { "defaultCertificate": { "name": "router-certs-full" }}}'


# updatre
oc create secret tls api-secret --cert=fullchain_api.pem --key=key_api.pem -n openshift-config --insecure-skip-tls-verify=true  --dry-run=client -o yaml | oc replace --insecure-skip-tls-verify=true -f -
oc create secret tls router-certs-full --cert=fullchain.pem --key=key.pem -n openshift-ingress --insecure-skip-tls-verify=true  --dry-run=client -o yaml | oc replace --insecure-skip-tls-verify=true -f -
oc create configmap custom-ca --from-file=ca-bundle.crt=ca.pem -n openshift-config --insecure-skip-tls-verify=true  --dry-run=client -o yaml | oc replace --insecure-skip-tls-verify=true -f -
