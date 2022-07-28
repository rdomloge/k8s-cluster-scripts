HOSTS_MNT="--mount type=bind,source="${PWD}"/hosts,target=/etc/ansible/hosts"
PB_MNT="--mount type=bind,source="${PWD}"/testrunbook.yaml,target=/testrunbook.yaml"
KNOWN_USERS_MNT="--mount type=bind,source="${PWD}"/known_hosts,target=/root/.ssh/known_hosts"
CFG_MNT="--mount type=bind,source="${PWD}"/ansible.cfg,target=/etc/ansible/ansible.cfg"
VARS_MNT="--mount type=bind,source="${PWD}"/vars.yml,target=/vars.yml"

docker run $HOSTS_MNT $PB_MNT  $CFG_MNT $VARS_MNT -ti rdomloge/ansible ansible-playbook -v testrunbook.yaml