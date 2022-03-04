HOSTS_MOUNT="--mount type=bind,source="${PWD}"/hosts,target=/etc/ansible/hosts"
PB_MOUNT="--mount type=bind,source="${PWD}"/testrunbook.yaml,target=/testrunbook.yaml"

docker run $HOSTS_MOUNT $PB_MOUNT -ti rdomloge/ansible ansible-playbook testrunbook.yaml
# ansible all -m ping -u ubuntu