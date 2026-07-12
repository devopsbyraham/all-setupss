#!/bin/bash

# STEP-1: Install Git, Java 8 (for Maven), Java 21 (for Jenkins), and Maven
if [ -f /etc/os-release ]; then
    . /etc/os-release
    case "$ID" in
        "ubuntu"|"debian")
            echo "Configuring for Ubuntu/Debian-based system"
            sudo apt update
            sudo apt install -y git openjdk-8-jdk openjdk-21-jdk maven
            ;;
        "centos"|"rhel"|"fedora")
            echo "Configuring for CentOS/RHEL/Fedora-based system"
            sudo yum install -y git java-1.8.0-openjdk-devel java-21-openjdk-devel maven
            ;;
        *)
            echo "Unsupported OS. Please install manually."
            exit 1
            ;;
    esac
else
    echo "Cannot determine OS type. Please install manually."
    exit 1
fi

# STEP-2: Add Jenkins Repository (Ubuntu/Debian)
if [ -n "$(command -v apt)" ]; then
    echo "Adding Jenkins repository..."
    sudo mkdir -p /usr/share/keyrings
    sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
      https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
    echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | \
      sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
    sudo apt update
fi

# STEP-3: Install Jenkins and Configure Java Versions
echo "Installing Jenkins and configuring Java versions..."
sudo apt install -y fontconfig jenkins

# Set Java 21 as the default system Java for Jenkins
sudo update-alternatives --set java /usr/lib/jvm/java-21-openjdk-amd64/bin/java
sudo update-alternatives --set javac /usr/lib/jvm/java-21-openjdk-amd64/bin/javac

# Verify Java 21 for Jenkins
java -version
if [ $? -ne 0 ]; then
    echo "Java 21 installation or configuration failed. Please check."
    exit 1
fi

# Configure Maven to use Java 8
echo "Configuring Maven to use Java 8..."
echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" | sudo tee /etc/profile.d/maven-java8.sh
echo "export PATH=\$JAVA_HOME/bin:\$PATH" | sudo tee -a /etc/profile.d/maven-java8.sh
sudo chmod +x /etc/profile.d/maven-java8.sh
source /etc/profile.d/maven-java8.sh

# Verify Maven uses Java 8
mvn -version
if [ $? -ne 0 ]; then
    echo "Maven configuration or Java 8 setup failed. Please check."
    exit 1
fi

# Configure Jenkins to use Java 21
sudo sed -i 's/#JAVA_HOME=/JAVA_HOME=\/usr\/lib\/jvm\/java-21-openjdk-amd64/' /etc/default/jenkins

# STEP-4: Start and Check Jenkins Service
echo "Starting Jenkins..."
sudo systemctl daemon-reload
sudo systemctl start jenkins
sudo systemctl status jenkins --no-pager

echo "Installation complete. Check the output above."
