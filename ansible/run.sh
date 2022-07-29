HOSTS_MNT="--mount type=bind,source="${PWD}"/hosts,target=/etc/ansible/hosts"
PREP_PB_MNT="--mount type=bind,source="${PWD}"/prep.yaml,target=/prep.yaml"
SWAP_PB_MNT="--mount type=bind,source="${PWD}"/enable_swap.yaml,target=/enable_swap.yaml"
MASTER_PB_MNT="--mount type=bind,source="${PWD}"/master.yaml,target=/master.yaml"
NODES_PB_MNT="--mount type=bind,source="${PWD}"/nodes.yaml,target=/nodes.yaml"
CFG_MNT="--mount type=bind,source="${PWD}"/ansible.cfg,target=/etc/ansible/ansible.cfg"
VARS_MNT="--mount type=bind,source="${PWD}"/vars.yml,target=/vars.yml"

docker run $HOSTS_MNT $PREP_PB_MNT  $CFG_MNT $VARS_MNT -ti rdomloge/ansible ansible-playbook -v prep.yaml
#docker run $HOSTS_MNT $SWAP_PB_MNT  $CFG_MNT $VARS_MNT -ti rdomloge/ansible ansible-playbook -v enable_swap.yaml
docker run $HOSTS_MNT $MASTER_PB_MNT  $CFG_MNT $VARS_MNT -ti rdomloge/ansible ansible-playbook -v master.yaml
docker run $HOSTS_MNT $NODES_PB_MNT  $CFG_MNT $VARS_MNT -ti rdomloge/ansible ansible-playbook -v nodes.yaml