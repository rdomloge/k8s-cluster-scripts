FROM ubuntu

RUN apt update && apt-get install -y ansible python
RUN ssh-keygen -b 2048 -t rsa -f /root/.ssh/id_rsa -q -N ""
RUN cat /root/.ssh/id_rsa.pub
