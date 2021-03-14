#!/bin/bash
ANSIBLE_DISPLAY_SKIPPED_HOSTS=no
REMOTE_USER=root
TERMINAL_DARK_THEME=no

MANAGED_NODE=$1
if [[ ${MANAGED_NODE}. = "." ]]; then
   echo "Enter the name of the managed node: "
   read MANAGED_NODE
fi
_RHEL_RELEASE=$(ssh ${REMOTE_USER}@${MANAGED_NODE} cat /etc/redhat-release | awk 'BEGIN{FS="release "}{split ($2, a, " "); print a[1]}')
_RHEL_RELEASE_MAJOR=$(echo ${_RHEL_RELEASE} | cut -d "." -f 1)

if [[ ${TERMINAL_DARK_THEME}. = "no." ]]; then
   export __FONT_COLOR=30m
else
   export __FONT_COLOR=37m
fi

echo
printf "Managed node Red Hat release: "
ssh ${REMOTE_USER}@${MANAGED_NODE} cat /etc/redhat-release
printf "Managed node HW architecture: "
ssh ${REMOTE_USER}@${MANAGED_NODE} uname -m

echo
echo "Test 1: Run role in check mode."
ansible-playbook default-settings.yml -l ${MANAGED_NODE} --check
# ansible-playbook default-settings.yml -l ${MANAGED_NODE} -e "{sap_hana_preconfigure_fail_if_reboot_required: no}" --check
RC=$?
echo "Test 1: RC=${RC}"
if [[ ${RC} -ne 0 ]]; then
   exit ${RC}
fi

echo
echo "Test 2: Run the role in assert mode. Let it fail in case of FAIL but continue with the next test."
rm -f ${_TMPFILE}
ansible-playbook default-settings.yml -l ${MANAGED_NODE} -e \
"{sap_hana_preconfigure_assert: yes}"
RC=$?
echo "Test 2: RC=${RC}"
if [[ ${RC} -ne 0 ]]; then
   echo "Failed - see result of last task."
fi

echo
echo "Continung..."
echo
echo "Test 3: Run the role in assert mode, ignoring any error."
rm -f ${_TMPFILE}
ansible-playbook default-settings.yml -l ${MANAGED_NODE} -e \
"{sap_hana_preconfigure_assert: yes, \
  sap_hana_preconfigure_assert_ignore_errors: yes,\
  sap_hana_preconfigure_update: yes}"
RC=$?
echo "Test 3: RC=${RC}"
if [[ ${RC} -ne 0 ]]; then
   exit ${RC}
fi

echo
echo "Test 4: Run the role in assert mode again, with compact output."
ansible-playbook default-settings.yml -l ${MANAGED_NODE} -e \
"{sap_hana_preconfigure_assert: yes, \
  sap_hana_preconfigure_assert_ignore_errors: yes,\
  sap_hana_preconfigure_update: yes}" |
./beautify-assert-output.sh
echo "Test 4 finished."

echo
echo "Test 5: Run role in normal mode. Do not fail if a reboot is required."
ansible-playbook default-settings.yml -l ${MANAGED_NODE} -e \
"{sap_hana_preconfigure_fail_if_reboot_required: no}"
RC=$?
echo "Test 5: RC=${RC}"
if [[ ${RC} -ne 0 ]]; then
   exit ${RC}
fi

echo
echo "Test 6: Run role in check mode again:"
ansible-playbook default-settings.yml -l ${MANAGED_NODE} --check
RC=$?
echo "Test 6: RC=${RC}"
if [[ ${RC} -ne 0 ]]; then
   exit ${RC}
fi

echo
echo "Test 7: Run the role in assert mode. Let it fail in case of FAIL but continue with the next test."
ansible-playbook default-settings.yml -l ${MANAGED_NODE} -e \
"{sap_hana_preconfigure_assert: yes}"
RC=$?
echo "Test 7: RC=${RC}"
if [[ ${RC} -ne 0 ]]; then
   echo "Failed - see result of last task."
fi

echo
echo "Continung..."
echo
echo "Test 8: Run the role in assert mode again, with compact output:"
ansible-playbook default-settings.yml -l ${MANAGED_NODE} -e \
"{sap_hana_preconfigure_assert: yes, \
  sap_hana_preconfigure_assert_ignore_errors: yes}" | 
./beautify-assert-output.sh
echo "Test 8 finished."

echo
echo "Test 9: Run role in normal mode. Allow a reboot."
ansible-playbook default-settings.yml -l ${MANAGED_NODE} -e \
"{sap_hana_preconfigure_enable_sap_hana_repos: yes, \
  sap_hana_preconfigure_set_minor_release: yes, \
  sap_hana_preconfigure_update: yes, \
  sap_hana_preconfigure_reboot_ok: yes}"
RC=$?
echo "Test 9: RC=${RC}"
if [[ ${RC} -ne 0 ]]; then
   exit ${RC}
fi

echo
echo "Test 10: Run the role in assert mode. Let it fail in case of FAIL but continue with the next test."
ansible-playbook default-settings.yml -l ${MANAGED_NODE} -e "{sap_hana_preconfigure_assert: yes}"
RC=$?
echo "Test 10: RC=${RC}"
if [[ ${RC} -ne 0 ]]; then
   exit ${RC}
fi

echo
echo "Test 11: Run the role in assert mode again, with compact output:"
ansible-playbook default-settings.yml -l ${MANAGED_NODE} -e \
"{sap_hana_preconfigure_assert: yes, \
  sap_hana_preconfigure_assert_ignore_errors: yes}" | 
./beautify-assert-output.sh
echo "Test 11 finished."

echo
echo "Test 12: Run role in normal mode. Do not use tuned. Allow a reboot."
ansible-playbook default-settings.yml -l ${MANAGED_NODE} -e \
"{sap_hana_preconfigure_enable_sap_hana_repos: yes, \
  sap_hana_preconfigure_set_minor_release: yes, \
  sap_hana_preconfigure_update: yes, \
  sap_hana_preconfigure_use_tuned: no, \
  sap_hana_preconfigure_reboot_ok: yes}"
RC=$?
echo "Test 12: RC=${RC}"
if [[ ${RC} -ne 0 ]]; then
   echo "Failed - see result of last task."
fi

echo
echo "Continung..."
echo
echo "Test 13: Run the role in assert mode again, with compact output:"
ansible-playbook default-settings.yml -l ${MANAGED_NODE} -e \
"{sap_hana_preconfigure_assert: yes, \
  sap_hana_preconfigure_assert_all_config: yes, \
  sap_hana_preconfigure_assert_ignore_errors: yes, \
  sap_hana_preconfigure_update: yes}" | 
./beautify-assert-output.sh
echo "Test 13 finished."
echo
echo "All Tests finished."
