HOSTS_MNT="--mount type=bind,source="${PWD}"/hosts,target=/etc/ansible/hosts"
YAML_PB_MNT="--mount type=bind,source="${PWD}/runbooks/workload",target=/yaml"
CFG_MNT="--mount type=bind,source="${PWD}"/ansible.cfg,target=/etc/ansible/ansible.cfg"
VARS_MNT="--mount type=bind,source="${PWD}"/vars.yml,target=/vars.yml"

docker run $HOSTS_MNT $YAML_PB_MNT  $CFG_MNT -ti rdomloge/ansible ansible-playbook -v yaml/workload-runbook.yaml