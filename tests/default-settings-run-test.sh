#!/bin/bash
export ANSIBLE_DISPLAY_SKIPPED_HOSTS="no"

MANAGED_NODE=$1
if [[ ${MANAGED_NODE}. = "." ]]; then
   echo "Enter the name of the managed node: "
   read MANAGED_NODE
fi
_RHEL_RELEASE=$(ssh ${MANAGED_NODE} cat /etc/redhat-release | awk 'BEGIN{FS="release "}{split ($2, a, " "); print a[1]}')
_RHEL_RELEASE_MAJOR=$(echo ${_RHEL_RELEASE} | cut -d "." -f 1)

echo "Test: Run the role in check mode, assert mode, normal mode, check mode again, assert mode again"

echo
printf "Managed node Red Hat release: "
ssh ${MANAGED_NODE} cat /etc/redhat-release
printf "Managed node HW architecture: "
ssh ${MANAGED_NODE} uname -m
echo

# Test 1: Run the role in check mode
echo "Test 1: Run role in check mode:"
ansible-playbook default-settings.yml -l ${MANAGED_NODE} --check
RC=$?
echo "RC=${RC}"
if [[ ${RC} -ne 0 ]]; then
   exit ${RC}
fi

# Test 2: Run the role in assert mode:
echo
echo "Test 2: Run the role in assert mode:"
rm -f ${_TMPFILE}
ansible-playbook default-settings.yml -l ${MANAGED_NODE} -e "{'sap_hana_preconfigure_assert': yes}"
RC=$?
echo "RC=${RC}"
if [[ ${RC} -ne 0 ]]; then
   exit ${RC}
fi

# Test 3: Run the role in normal mode
echo "Test 3: Run role in normal mode:"
ansible-playbook default-settings.yml -l ${MANAGED_NODE}
RC=$?
echo "RC=${RC}"
if [[ ${RC} -ne 0 ]]; then
   exit ${RC}
fi

# Test 4: Run the role in check mode again:
echo
echo "Test 4: Run role in check mode again:"
ansible-playbook default-settings.yml -l ${MANAGED_NODE} --check
RC=$?
echo "RC=${RC}"
if [[ ${RC} -ne 0 ]]; then
   exit ${RC}
fi

# Test 5: Run the role in assert mode again:
echo
echo "Test 5a: Run the role in assert mode again:"
ansible-playbook default-settings.yml -l ${MANAGED_NODE} -e "{'sap_hana_preconfigure_assert': yes}"
RC=$?
echo "RC=${RC}"
if [[ ${RC} -ne 0 ]]; then
   exit ${RC}
fi
echo "Test 5b: Run the role in assert mode again, with compact output:"
ansible-playbook default-settings.yml -l ${MANAGED_NODE} -e "{'sap_hana_preconfigure_assert': yes}" | 
awk '{sub ("    \"msg\": ", "")}
  /TASK/{task_line=$0}
  /fatal:/{fatal_line=$0; nfatal[host]++}
  /...ignoring/{nfatal[host]--; if (nfatal[host]<0) nfatal[host]=0}
  /^[a-z]/&&/: \[/{gsub ("\\[", ""); gsub ("]", ""); gsub (":", ""); host=$2}
  /SAP note/{print "\033[30m[" host"] "$0}
  /FAIL:/{nfail[host]++; print "\033[31m[" host"] "$0}
  /WARN:/{nwarn[host]++; print "\033[33m[" host"] "$0}
  /PASS:/{npass[host]++; print "\033[32m[" host"] "$0}
  /INFO:/{print "\033[34m[" host"] "$0}
  /changed/&&/unreachable/{print "\033[30m[" host"] "$0}
  END{print ("---"); for (var in npass) {printf ("[%s] ", var); if (nfatal[var]>0) {
        printf ("\033[31mFATAL ERROR!!! Playbook might have been aborted!!!\033[30m Last TASK and fatal output:\n"); print task_line, fatal_line
     }
     else printf ("\033[31mFAIL: %d  \033[33mWARN: %d  \033[32mPASS: %d\033[30m\n", nfail[var], nwarn[var], npass[var])}}'

