# ambari-rancher
The Base Docker image for Diamond platform . Run in Rancher, base on Ubuntu 14.04

#Build:

1. Add the sources.list/ambari.list/HDP*.list from ambari-base
2. Download the `ambariinst.tar` as the file-need described
3. Download the jdk-8u60-linux-x64.tar.gz jce_policy-8.zip
4. Build the 3 images :<br>
`docker build -t diamondreg:5000/ambari-base:14.04 .`<br>
`docker build -t diamondreg:5000/ambari-server:2.2.2.0 .`<br>
`docker build -t diamondreg:5000/ambari-node:2.2.2.0 .`<br>

#Run
use the `ambari-compose-file.zip` in Rancher, will create a 1 Server + 3 node cluster 
