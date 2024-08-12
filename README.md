# OpenStack-NSO-Project

This project involves the deployment and operation of a service within an OpenStack Cloud, integrating elements of network design, service deployment, and automation. The solution operates in three distinct phases: deployment, operations, and cleanup. During deployment, essential network infrastructure and nodes are created, tagged for easy identification, and configured to ensure secure communication. The operations phase involves continuous monitoring of node availability and dynamically adjusting resources to maintain system integrity. Finally, the cleanup phase ensures the release of all allocated resources, promoting efficient resource management.

First, we need to generate an SSH key by executing  "ssh-keygen -t rsa".

The second step involves creating an "openrc" file within OpenStack users, copying and pasting its contents into Ubuntu,Before pasting, simply update the password you created for the openrc file and put that password in the openrc file and running the following commands for proper configuration: 

```bash
#chmod 600 openrc 
#source openrc
#openstack token

## To run the code, follow these commands:
