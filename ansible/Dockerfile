FROM ubuntu

RUN apt update && apt-get install -y ansible python sshpass python3-pip python3-pexpect
RUN ssh-keygen -b 2048 -t rsa -f /root/.ssh/id_rsa -q -N ""
RUN cat /root/.ssh/id_rsa.pub
RUN ansible-galaxy collection install community.crypto
