#!/bin/bash
MANAGED_NODE=$1
if [[ ${MANAGED_NODE}. = "." ]]; then
   echo "Enter the name of the managed node (RHEL 8 only): "
   read MANAGED_NODE
fi

echo
printf "Managed node Red Hat release: "
ssh ${MANAGED_NODE} cat /etc/redhat-release
printf "Managed node HW architecture: "
ssh ${MANAGED_NODE} uname -m
echo
_RHEL_RELEASE_MAJOR=$(ssh ${MANAGED_NODE} cat /etc/redhat-release | awk 'BEGIN{FS="release "}{split ($2, a, " "); split (a[1], b, "."); print b[1]}')

if [[ ${_RHEL_RELEASE_MAJOR} -ne 8 ]]; then
   echo "This test is only valid for RHEL 8 managed nodes. Exiting."
   echo
   exit 1
fi

# Test 1: Run the role
echo "Test 1: Remove package libssh2 if installed"
ansible-playbook sap-hana-preconfigure-issue-118-prepare-test-1.yml -l ${MANAGED_NODE}
echo
echo "Status before running the test:"
ssh ${MANAGED_NODE} "yum list installed libssh2"
echo
echo "Test 1: Run role:"
ansible-playbook sap-hana-preconfigure-issue-118-test.yml -l ${MANAGED_NODE}
echo
echo "Test 1: Assertion:"
ansible-playbook sap-hana-preconfigure-issue-118-assert.yml -l ${MANAGED_NODE} -e "@sap-hana-preconfigure-issue-118-assert-vars.yml"

