#create Ubuntu ec2 with t2.micro and 30 gb of ebs with port 8081 

apt update
apt install wget tar -y
wget https://download.sonatype.com/nexus/3/nexus-unix-x86-64-3.79.0-09.tar.gz
tar -zxvf nexus-unix-x86-64-3.79.0-09.tar.gz
sudo apt install openjdk-17-jre
sudo useradd nexus
sudo chown -R  nexus:nexus  nexus-3.79.0-09
sudo sh nexus-3.79.0-09/bin/nexus start
