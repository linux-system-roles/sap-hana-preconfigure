#!/bin/bash
MANAGED_NODE=$1
if [[ ${MANAGED_NODE}. = "." ]]; then
   echo "Enter the name of the managed node: "
   read MANAGED_NODE
fi

echo
printf "Managed node Red Hat release: "
ssh ${MANAGED_NODE} cat /etc/redhat-release
printf "Managed node HW architecture: "
ssh ${MANAGED_NODE} uname -m
echo
_RHEL_RELEASE_MAJOR=$(ssh ${MANAGED_NODE} cat /etc/redhat-release | awk 'BEGIN{FS="release "}{split ($2, a, " "); split (a[1], b, "."); print b[1]}')

# Test 1: Run the role in check mode
echo "Test 1: Remove file /etc/init.d/boot.local"
ansible-playbook sap-hana-preconfigure-issue-128-prepare-test-1.yml -l ${MANAGED_NODE}
RC=$?
echo "RC=${RC}"
if [[ ${RC} -ne 0 ]]; then
   exit ${RC}
fi
echo
echo "Status before running the test:"
ssh ${MANAGED_NODE} "ls -l /etc/init.d/boot.local"
echo
echo "Test 1: Run role in check mode:"
ansible-playbook sap-hana-preconfigure-issue-128-test.yml -l ${MANAGED_NODE} --check
RC=$?
echo "RC=${RC}"
if [[ ${RC} -ne 0 ]]; then
   exit ${RC}
fi

# Test 2: Run the role in normal mode
echo
echo "Test 2: Run role in normal mode:"
ansible-playbook sap-hana-preconfigure-issue-128-test.yml -l ${MANAGED_NODE}
RC=$?
echo "RC=${RC}"
if [[ ${RC} -ne 0 ]]; then
   exit ${RC}
fi
echo
echo "Test 2: Assertion:"
ansible-playbook sap-hana-preconfigure-issue-128-assert.yml -l ${MANAGED_NODE}
RC=$?
echo "RC=${RC}"
if [[ ${RC} -ne 0 ]]; then
   exit ${RC}
fi

# Test 3: Run the role in check mode again
echo "Status before running the test:"
ssh ${MANAGED_NODE} "ls -l /etc/init.d/boot.local"
echo
echo "Test 3: Run role in check mode:"
ansible-playbook sap-hana-preconfigure-issue-128-test.yml -l ${MANAGED_NODE} --check

