#!/bin/bash

ssh ubuntu@10.0.0.9 "sudo bash -c 'echo k8s-node-1 > /etc/hostname' && sudo reboot"
ssh ubuntu@10.0.0.10 "sudo bash -c 'echo k8s-node-2 > /etc/hostname' && sudo reboot"
ssh ubuntu@10.0.0.11 "sudo bash -c 'echo k8s-node-3 > /etc/hostname' && sudo reboot"
ssh ubuntu@10.0.0.15 "sudo bash -c 'echo k8s-node-4 > /etc/hostname' && sudo reboot"
ssh ubuntu@10.0.0.16 "sudo bash -c 'echo k8s-node-5 > /etc/hostname' && sudo reboot"
ssh ubuntu@10.0.0.17 "sudo bash -c 'echo k8s-node-6 > /etc/hostname' && sudo reboot"
ssh ubuntu@10.0.0.18 "sudo bash -c 'echo k8s-node-7 > /etc/hostname' && sudo reboot"
ssh ubuntu@10.0.0.12 "sudo bash -c 'echo k8s-master-1 > /etc/hostname' && sudo reboot"
