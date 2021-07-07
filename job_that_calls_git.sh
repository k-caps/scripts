#!/bin/bash
# This script should be the "inline script" step of a rundeck Job.
# This job should reference the Git job as follows:
# Workflow: 
# Node Step 1: Run "git" job with options:
#   -repo_url https:git.com/postgres_ansible.git -path postgres_ansible -branch master -ansible_roles 'True' -clean 'True' -run 'True'
# Job Step 2: Run ansible using the current script:

cd ~/rundeck/git_base/prod/postgres_ansible
export PYTHONWARNINGS="ignore:Unverified HTTPS request"
ansible-playbook -b -i inventories/hosts_list playbooks/main.yml \
--vault-password-file ~/rundeck/vaultpw.sh \ #(prints a rundeck keystore secret)
--extra-vars "\
ansible_var1=@option.1@ \
ansible_var2=@option2@
"
#etc... this way your ansible can run in the cli if Rundeck goes down. Just keep using your variables and remap them for rundeck to use Job Options.


