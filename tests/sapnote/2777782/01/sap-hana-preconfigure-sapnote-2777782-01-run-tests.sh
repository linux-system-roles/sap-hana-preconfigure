#!/bin/bash
export ANSIBLE_DISPLAY_SKIPPED_HOSTS="no"

MANAGED_NODE=$1
if [[ ${MANAGED_NODE}. = "." ]]; then
   echo "Enter the name of the managed node: "
   read MANAGED_NODE
fi
_RHEL_RELEASE_MAJOR=$(ssh ${MANAGED_NODE} cat /etc/redhat-release | awk 'BEGIN{FS="release "}{split ($2, a, " "); split (a[1], b, "."); print b[1]}')

if [[ ${_RHEL_RELEASE_MAJOR} -ne 8 ]]; then
   echo "This test is only valid for RHEL 8 managed nodes. Exiting."
   echo
   exit 1
fi

echo
printf "Managed node Red Hat release: "
ssh ${MANAGED_NODE} cat /etc/redhat-release
printf "Managed node HW architecture: "
ssh ${MANAGED_NODE} uname -m
echo
_RHEL_RELEASE_MAJOR=$(ssh ${MANAGED_NODE} cat /etc/redhat-release | awk 'BEGIN{FS="release "}{split ($2, a, " "); split (a[1], b, "."); print b[1]}')

# Test 1: Run the role in check mode
echo "Test 1: Run role in check mode:"
ansible-playbook sap-hana-preconfigure-sapnote-2777782-01-test.yml -l ${MANAGED_NODE} --check
RC=$?
echo "RC=${RC}"
if [[ ${RC} -ne 0 ]]; then
   exit ${RC}
fi

# Test 2: Run the role in normal mode
echo "Prepare for test 2: Set the system to SELinux enforcing mode"
ansible-playbook sap-hana-preconfigure-sapnote-2777782-01-prepare-test-1.yml -l ${MANAGED_NODE}
echo
echo "Verify that the system is set to SELinux enforcing mode"
ssh ${MANAGED_NODE} getenforce
echo
echo "Test 2: Run role in normal mode:"
ansible-playbook sap-hana-preconfigure-sapnote-2777782-01-test.yml -l ${MANAGED_NODE}
RC=$?
echo "RC=${RC}"
if [[ ${RC} -ne 0 ]]; then
   exit ${RC}
fi

# Test 3: Run the role in assert mode
echo
echo "Test 3: Run the role in assert mode:"
ansible-playbook sap-hana-preconfigure-sapnote-2777782-01-test.yml -l ${MANAGED_NODE} -e "{'sap_hana_preconfigure_assert': yes}"
RC=$?
echo "RC=${RC}"
if [[ ${RC} -ne 0 ]]; then
   exit ${RC}
fi

