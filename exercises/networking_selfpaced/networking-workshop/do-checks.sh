#!/bin/bash
#
set -e
echo "Performing compliance checks..."
ANSIBLE_STDOUT_CALLBACK=json \
  ansible-playbook run-checks.yml -k >/tmp/$$.json
echo "... done"
echo
echo "Generating reports from $$.json"
ANSIBLE_STDOUT_CALLBACK=dense \
  ansible-playbook report-results.yml -k -e input=/tmp/$$.json
echo
echo "Cleanup"
rm /tmp/$$.json
