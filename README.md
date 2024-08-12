###### **OpenStack-NSO-Project**

This project involves the deployment and operation of a service within an OpenStack Cloud, integrating elements of network design, service deployment, and automation. The solution operates in three distinct phases: deployment, operations, and cleanup. During deployment, essential network infrastructure and nodes are created, tagged for easy identification, and configured to ensure secure communication. The operations phase involves continuous monitoring of node availability and dynamically adjusting resources to maintain system integrity. Finally, the cleanup phase ensures the release of all allocated resources, promoting efficient resource management.

First, we need to generate an SSH key by executing either "ssh-keygen" or "ssh-keygen -t rsa -b 4096"(cat ~/.ssh/id_rsa.pub). 

The second step involves creating an "openrc" file within OpenStack users, copying and pasting its contents into Ubuntu,Before pasting, simply update the password you created for the openrc file and put that password in the openrc file and running the following commands for proper configuration: 

#chmod 600 openrc (to set permissions) 
#source openrc (to source the file) 
#openstack token issue (to establish connection between Ubuntu and OpenStack)
