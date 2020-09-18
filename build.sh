#!/bin/bash
echo First, you must install sshpass
echo In order for this work, you first need to log onto each pi and set an initial password. This then needs to be set as an environment variable outside this shell with 
echo SSHPASS=mypassword
echo export SSHPASS




pubkey=$(</home/domloger/.ssh/id_rsa.pub)
echo "$pubkey"

master=10.0.0.12
nodes=("10.0.0.9" "10.0.0.10" "10.0.0.11" "10.0.0.15" "10.0.0.16" "10.0.0.17" "10.0.0.18")
all=("${nodes[@]}")
all+=($master)

cmdlinefile=/boot/firmware/cmdline.txt
cmdlinecontents='cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory net.ifnames=0 dwc_otg.lpm_enable=0 console=serial0,115200 console=tty1 root=LABEL=writable rootfstype=ext4 elevator=deadline rootwait fixrtc'

for i in "${all[@]}"
do
   :
   echo Adding key to $i
   sshpass -e ssh ubuntu@$i "mkdir -p .ssh && touch .ssh/authorized_keys && echo $pubkey >> .ssh/authorized_keys"
   echo Key copied
   sshpass -e ssh ubuntu@$i "sudo bash -c 'echo $cmdlinecontents > $cmdlinefile'"
   echo Enabled container features - REBOOTING $i
   sshpass -e ssh ubuntu@$i sudo reboot
done

echo Waiting for nodes to reboot
sleep 60

echo Generating key pair on master
ssh ubuntu@$master ssh-keygen -q -f /home/ubuntu/.ssh/id_rsa -P \"\"

echo Adding keypair to its own authorised keys
ssh ubuntu@$master "cat .ssh/id_rsa.pub >> .ssh/authorized_keys"

echo Installing k3sup on master
ssh ubuntu@$master "curl -sLS https://get.k3sup.dev | sh"
ssh ubuntu@$master sudo cp k3sup-arm64 /usr/local/bin/k3sup 

echo Setting up k3s on master
ssh ubuntu@$master k3sup install --ip $master --user ubuntu

echo Capturing master public key to copy to slaves
masterkey=$(ssh ubuntu@$master cat .ssh/id_rsa.pub)
echo Master key: $masterkey


for i in "${nodes[@]}"
do
   :
   echo Adding master public key to node $i
   ssh ubuntu@$i "echo $masterkey >> .ssh/authorized_keys" 
   echo Creating cluster node on $i
   ssh ubuntu@$master k3sup join --ip $i --server-ip $master --user ubuntu
   ssh ubuntu
done

for i in "${all[@]}"
do
   :
   echo Installing NFS driver on $i
   ssh ubuntu@$i sudo apt install -y nfs-kernel-server
done

echo Installing OpenFaaS
ssh ubuntu@$master "curl -sLS https://dl.get-arkade.dev | sudo sh"
ssh ubuntu@$master export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
ssh ubuntu@$master sudo chmod +r /etc/rancher/k3s/k3s.yaml
ssh ubuntu@$master arkade install openfaas --gateways 2 --load-balancer false

