#!/bin/bash
echo First, you must install sshpass
echo In order for this work, you first need to log onto each pi and set an initial password. This then needs to be set as an environment variable outside this shell with 
echo SSHPASS=mypassword
echo export SSHPASS




pubkey='ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDG4kPSGvLp9hPue4UolYIW9Rf05rnkcSrcRTp7SzV1Ybs/NTyRirk07QB/R8n3de4rEc0FvXsvtjRQzGkACqr5sYywqpghx9NzhNidgZlaDHoBOHFR6aDwiQKBLHtD8z0eHyL7fNYE3qx3+uxh0zMuKzmTitYSVgGVju8bl5zef5R4JQ5+P8kJQggvPWlWUTdo1gJ+yGO7Bn+o5GdsR+v3twc3SVrNgDoKIGXlTSk9E6J4dKASCYkaFme7LSxrw3c9sify8sjc2CFqMvCse6NJT+uZkzSMBixn6uK8mSULJlRk6OF7eki8xK4Iqfwn2T8Ywg81FqdEGxAWjdtu3CjRlR5gH1Cx9hijoZJpWX+r2YGij1Frqe06O+YC3UNIH9SFyeNlbsE2lmhyH+1J3YxJn6jhFgX5sjxz+YKUMS/9+kXazjVK7oBVJTxwvLD+0oriUJ3bAeX1KGJ9+Oe9sHRuc3LieSIXMEggXRDTvZLad5tJybeyEcB/XHUKXC4bF8VroYN3oOep/sAx7c5B+BQvYeX+MJlb9p18+f7YULhG6DwuhZuhnlSqimUs81eeuGuzgSm6/WaJ3H7d5ctc20So+OfPovXD80N7c0/T+WMYEIK/bwljgsSskvnpZpQXEnqXXyFShBw5l61TFqo5e7FQeA1A94pXQbFAuAg/MFZCtw== bca\domloger@LP032542'
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
   sshpass -e ssh -oStrictHostKeyChecking=no ubuntu@$i "mkdir -p .ssh && touch .ssh/authorized_keys && echo $pubkey >> .ssh/authorized_keys"
   echo Key copied
   sshpass -e ssh -oStrictHostKeyChecking=no ubuntu@$i "sudo bash -c 'echo $cmdlinecontents > $cmdlinefile'"
done

echo 'Rebooting each worker (cant reboot master since that would kill this script)'
for i in "${nodes[@]}"
do
   :
   echo Enabled container features - REBOOTING $i
   sshpass -e ssh -oStrictHostKeyChecking=no ubuntu@$i sudo reboot
done


echo Waiting for nodes to reboot
sleep 60


version=v1.21.2+k3s1
echo Version of k3s is $version

echo Generating key pair on master
sshpass -e ssh ubuntu@$master ssh-keygen -q -f /home/ubuntu/.ssh/id_rsa -P \"\"

echo Adding keypair to its own authorised keys
sshpass -e ssh ubuntu@$master "cat .ssh/id_rsa.pub >> .ssh/authorized_keys"

echo Installing k3sup on master
ssh ubuntu@$master "curl -sLS https://get.k3sup.dev | sh"
ssh ubuntu@$master sudo cp k3sup-arm64 /usr/local/bin/k3sup 

echo Setting up k3s on master
ssh ubuntu@$master k3sup install --ip $master --user ubuntu --k3s-version=$version

echo Capturing master public key to copy to slaves
masterkey=$(ssh ubuntu@$master cat .ssh/id_rsa.pub)
echo Master key: $masterkey

# Before we join the nodes, we have to rename all of them otherwise k3s won't allow them to join with existing names
ssh ubuntu@$master "sudo bash -c 'echo k8s-master-1 > /etc/hostname'"
COUNTER=1
for i in "${nodes[@]}"
do
   :
   echo Renaming node $i
   sshpass -e ssh ubuntu@$i "sudo bash -c 'echo k8s-node-$COUNTER > /etc/hostname' && sudo reboot"
   let COUNTER++
done

for i in "${nodes[@]}"
do
   :
   echo Adding master public key to node $i
   sshpass -e ssh ubuntu@$i "echo $masterkey >> .ssh/authorized_keys"
   echo Creating cluster node on $i
   ssh ubuntu@$master k3sup join --ip $i --server-ip $master --user ubuntu --k3s-version=$version
done

for i in "${all[@]}"
do
   :
   echo Installing NFS driver on $i
   ssh ubuntu@$i sudo apt install -y nfs-kernel-server
done

echo Installing OpenFaaS
ssh ubuntu@$master "curl -sLS https://dl.get-arkade.dev | sudo sh"
ssh ubuntu@$master "echo export KUBECONFIG=/etc/rancher/k3s/k3s.yaml > .bash_profile"
ssh ubuntu@$master "echo alias kc=sudo kubectl >> .bash_profile"
ssh ubuntu@$master sudo chmod +r /etc/rancher/k3s/k3s.yaml
ssh ubuntu@$master arkade install openfaas --gateways 2 --load-balancer false --set faasIdler.dryRun=false

# Once OpenFaas is installed, use these 2 lines to find out the password for logging into the interface, with the username 'admin'
# PASSWORD=$(kubectl -n openfaas get secret basic-auth -o jsonpath="{.data.basic-auth-password}" | base64 --decode) && \
# echo "OpenFaaS admin password: $PASSWORD"

echo Installing OpenFaaS CLI
ssh ubuntu@$master "curl -sSL https://cli.openfaas.com | sh"
ssh ubuntu@$master sudo cp faas-cli-arm64 /usr/local/bin/faas-cli
ssh ubuntu@$master sudo ln -sf /usr/local/bin/faas-cli /usr/local/bin/faas

echo 'All done - rebooting master to get hostname rename and boot config changes'
sudo reboot

rem https://github.com/carlosedp/cluster-monitoring.git