HOSTS_MNT="--mount type=bind,source="${PWD}"/hosts,target=/etc/ansible/hosts"
YAML_PB_MNT="--mount type=bind,source="${PWD}/runbooks",target=/yaml"
CFG_MNT="--mount type=bind,source="${PWD}"/ansible.cfg,target=/etc/ansible/ansible.cfg"
VARS_MNT="--mount type=bind,source="${PWD}"/vars.yml,target=/vars.yml"

#docker run $HOSTS_MNT $YAML_PB_MNT  $CFG_MNT $VARS_MNT -ti rdomloge/ansible ansible-playbook -v yaml/login.yaml
#docker run $HOSTS_MNT $YAML_PB_MNT  $CFG_MNT $VARS_MNT -ti rdomloge/ansible ansible-playbook -v yaml/virtualbox-login.yaml
#docker run $HOSTS_MNT $YAML_PB_MNT  $CFG_MNT $VARS_MNT -ti rdomloge/ansible ansible-playbook -v yaml/prep.yaml
#docker run $HOSTS_MNT $YAML_PB_MNT  $CFG_MNT $VARS_MNT -ti rdomloge/ansible ansible-playbook -v yaml/enable_swap.yaml
#docker run $HOSTS_MNT $YAML_PB_MNT  $CFG_MNT $VARS_MNT -ti rdomloge/ansible ansible-playbook -v yaml/master.yaml
#docker run $HOSTS_MNT $YAML_PB_MNT  $CFG_MNT $VARS_MNT -ti rdomloge/ansible ansible-playbook -v yaml/nodes.yaml

docker run $HOSTS_MNT $YAML_PB_MNT  $CFG_MNT -ti rdomloge/ansible ansible-playbook -v yaml/k8s-runbook.yaml