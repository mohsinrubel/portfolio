# jenkins-pipeline-potfolio
![Alt text](https://github.com/mohsinrubel/jenkins-pipeline-potfolio/blob/master/Screenshot%20from%202023-09-03%2022-52-57.png)
## Setup Docker In Linux
### Install using the apt repository 
Before you install Docker Engine for the first time on a new host machine, you need to set up the Docker repository. Afterward, you can install and update Docker from the repository.

* Set up the repository 
Update the apt package index and install packages to allow apt to use a repository over HTTPS:
````
 sudo apt-get update
 sudo apt-get install ca-certificates curl gnupg
````


* Add Docker's official GPG key:
````
 sudo install -m 0755 -d /etc/apt/keyrings
 curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
 sudo chmod a+r /etc/apt/keyrings/docker.gpg

````

* Use the following command to set up the repository:
  
````

$ echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

````

* Update the apt package index:
````
 sudo apt-get update
````
### Install Docker Engine 
* Install Docker Engine, containerd, and Docker Compose.
Latest Specific version
To install the latest version, run:
````
 sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

````


## setup jenkins in docker

### Create a Docker Compose File:

Create a docker-compose.yml file in a directory of your choice. This file will define your Jenkins service and its configuration. You can use a text editor to create and edit the file:

````

version: '3.7'
services:
  jenkins:
    image: jenkins/jenkins:lts-jdk11
    privileged: true
    user: root
    ports:
      - 8080:8080
      - 50000:50000
    container_name: jenkins
    volumes:
      - ./jenkins_home:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock
      - /usr/local/bin/docker:/usr/local/bin/docker
    networks:
      - server-network

#Docker Networks
networks:
  server-network:  
    driver: bridge
    external: true
#Volumes
volumes:
  dbdata:
    driver: local
````


    
* In this Docker Compose file:

We use the official Jenkins LTS (Long Term Support) image from Docker Hub.
We map port 8080 of the host to the Jenkins web UI.
We use a named volume (jenkins_home) to persist Jenkins data such as job configurations and plugins.

* Create a Docker Network:
````  
docker network create server-network
````

For create a Docker network to allow communication between containers.

* Start Jenkins:

In the same directory as your docker-compose.yml file, run the following command to start Jenkins:

````
docker-compose up -d
````
The -d flag stands for "detached mode," which runs the containers in the background.

* Access Jenkins Web UI:

Once Jenkins is up and running, you can access the web UI by opening a web browser and navigating to http://localhost:8080. If you're running Docker on a remote server, replace localhost with the server's IP address or domain name.

* Unlock Jenkins:

During the initial setup, Jenkins will ask for an administrator password. To retrieve the password, you can use the following command:
````
docker exec -it jenkins cat /var/jenkins_home/secrets/initialAdminPassword
````
Copy the provided password and paste it into the Jenkins web UI to unlock Jenkins.

* Install Jenkins Plugins and Set Up:

Follow the on-screen instructions to install the recommended plugins and set up Jenkins according to your needs.

## setup sonar-qube in docker

* Create a Docker Compose YAML File

Create a file named docker-compose.yml and add the following content to it:

````
version: '3'
services:
  sonarqube:
    image: sonarqube:latest
    ports:
      - "9000:9000"
      - "9092:9092" # Optional - for debugging and analysis
    environment:
      - SONARQUBE_JDBC_URL=jdbc:postgresql://sonarqube_db:5432/sonarqube
      - SONAR_JDBC_USERNAME=shihab
      - SONAR_JDBC_PASSWORD=shihab24
    volumes:
      - ./sonarqube_data:/opt/sonarqube/data
      - ./sonarqube_extensions:/opt/sonarqube/extensions
      - ./sonarqube_logs:/opt/sonarqube/logs
    networks:
      - server-network
  sonarqube_db:
    image: postgres:latest
    environment:
      - POSTGRES_USER=sonarqube
      - POSTGRES_PASSWORD=sonarqube
    volumes:
      - ./postgresql:/var/lib/postgresql
      - ./postgresql_data:/var/lib/postgresql/data

    networks:
      - server-network


networks:
  server-network:
    driver: bridge
    external: true

````

This docker-compose.yml file sets up two services: sonarqube and sonarqube_db. The sonarqube service runs the SonarQube application, and the sonarqube_db service runs the PostgreSQL database that SonarQube uses.

* Start SonarQube

Open a terminal window, navigate to the directory where you created the docker-compose.yml file, and run the following command:

````
docker-compose up -d
````

This command starts the SonarQube and PostgreSQL containers in detached mode.

* Access SonarQube Web Interface

After the containers are up and running, you can access the SonarQube web interface by opening your web browser and navigating to http://localhost:9000.

* Initial Configuration

Log in with the default credentials: admin (username) and admin (password).
Follow the on-screen instructions to set up your organization and project.
You might need to generate a token to analyze your code. You can do this in the SonarQube interface under "User > My Account > Security."
That's it! You now have SonarQube running using Docker Compose.


## setup sonarqube-cli and java 17 In Host Machine

### Install Java 17:

````
# Update your package list
sudo apt update

# Install Java 17 from the AdoptOpenJDK and Jre repository
sudo apt install -y openjdk-17-jdk
sudo apt install -y openjdk-17-jre
````
To verify that Java 17 has been installed correctly, you can check the version:

````
java -version
````
You should see output indicating that you have Java 17 installed.

#### Install Sonar Scanner:

````
# Download the Sonar Scanner distribution zip file
curl -O https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.6.2.2472-linux.zip

# Unzip the downloaded file
unzip sonar-scanner-cli-4.6.2.2472-linux.zip -d /opt

# Rename the extracted directory for convenience
sudo mv /opt/sonar-scanner-4.6.2.2472-linux /opt/sonar-scanner

# Add Sonar Scanner to your system's PATH
echo 'export PATH=$PATH:/opt/sonar-scanner/bin' >> ~/.bashrc
source ~/.bashrc
````
Next, add the SonarScanner executable to your system's PATH. You can do this by creating a symbolic link:


````
sudo ln -s /opt/sonar-scanner/bin/sonar-scanner /usr/local/bin/

````
* Verify Sonar Scanner Installation:

To verify that Sonar Scanner has been installed correctly, you can check its version:

````
sonar-scanner -v
````
You should see output indicating the version of Sonar Scanner installed.


## configure jenkins

* Log in to Jenkins:
### Install Plugins
 Log in with your Jenkins administrator or user account.

* Go to Plugin Manager:

 Click on "Manage Jenkins" in the left-hand sidebar.

* Manage Plugins:

In the "Manage Jenkins" page, click on "Manage Plugins."

* Available Tab:

In the "Manage Plugins" page, you'll see several tabs at the top. Click on the "Available" tab. This tab displays all the available plugins that you can install.

* Search for the Plugin:

In the "Filter" text box, type "SSH Plugin And  Build Pipeline." This will filter the available plugins to show the one you want to install.

* Select the Plugin:

Find the "SSH Plugin And  Build Pipeline" plugin in the list and check the checkbox next to it.

* Install the Plugin:

Scroll down to the bottom of the page, and click the "Install without restart" button. Jenkins will download and install the plugin for you.

* Installation Progress:

Jenkins will show the progress of the installation. Once it's completed, you'll see a message indicating that the plugin has been successfully installed.

* Restart Jenkins (if needed):

In some cases, Jenkins may ask you to restart to complete the installation. If prompted, click on the "Restart Jenkins when no jobs are running" checkbox and wait for Jenkins to restart.

### Create Credential
#### For Remote Machine
Go to Credentials:

Click on "Manage Jenkins" in the left-hand sidebar.

* Manage Credentials:

In the "Manage Jenkins" page, click on "Credentials" on the middle page . This will take you to the "Credentials" page, where you can manage various types of credentials.

* Add Credentials:

On the "Credentials" page click on "System global", you'll see a list of credentials if you've already added any. To add a new credential, click on the "Add Credentials" link on the top  side.

* Choose Credential Type:

In the "Kind" dropdown, select the type of credential you want to create. For a username and password combination, choose "Username with Password."

Credential Information:

Username: < Your machine username >
ID: Optionally, you can provide a unique ID for the credential. This can be useful if you need to reference the credential in Jenkins pipelines or configurations.
Description: Add a description to help identify the purpose or usage of this credential.
Password: < give your machine login password > 
Scope:

The "Domain" field allows you to specify the scope or context in which the credential can be used. You can choose to store it globally (available to all jobs) or restrict it to a specific project or folder. The available options may depend on your Jenkins setup and installed plugins.

* Add Credentials:

After filling in the required information, click the "Add" button to create the credential.

Confirmation:

You should see a confirmation message indicating that the credential has been added successfully.
#### For Git
* Choose Credential Type:

In the "Kind" dropdown, select the type of credential you want to create. For a username and password combination, choose "Username with Password."

Credential Information:

Username: < Your git username>
ID: Optionally, you can provide a unique ID for the credential. This can be useful if you need to reference the credential in Jenkins pipelines or configurations.
Description: Add a description to help identify the purpose or usage of this credential.
Password: < give your git personal access token > 
Scope:

The "Domain" field allows you to specify the scope or context in which the credential can be used. You can choose to store it globally (available to all jobs) or restrict it to a specific project or folder. The available options may depend on your Jenkins setup and installed plugins.

* Add Credentials:

After filling in the required information, click the "Add" button to create the credential.

Confirmation:

You should see a confirmation message indicating that the credential has been added successfully.
### Configure SSH remote hosts
* Go to Configure System:

Click on "Manage Jenkins" in the left-hand sidebar.

* Configure System:

In the "Manage Jenkins" page, click on "System" to access the global Jenkins configuration settings.

* SSH Remote Hosts Configuration:

Scroll down to find the "SSH remote hosts" section. In this section, you can define configurations for remote SSH hosts.

* Add SSH Host Configuration:

To add a new SSH host configuration, click on the "Add SSH Server" button. This will open a form where you can enter the SSH host details.

* SSH Server Configuration:

In the SSH host configuration form, fill in the following details

Hostname: < Enter the hostname or IP address of the remote server >
Port: < Enter Your SSH Port  >
Credentials: Choose the SSH username and password credential that you created earlier, or you can use other types of credentials if needed.

* Test Configuration:

To ensure that your SSH host configuration is correct, you can click the "Check connection" button. Jenkins will attempt to connect to the remote server using the provided settings and report whether the connection was successful.


## crate update code job
## Create sonar-qube scan job
## Creade docker deploy job
## Configure Pipeline
## Configure git WebHook
