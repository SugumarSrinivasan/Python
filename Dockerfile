# Dockerfile
FROM jenkins/jenkins:lts

USER root

# Install Python and pip
RUN apt-get update && apt-get install -y python3 python3-pip

# Optional: Install Git, unzip, etc.
RUN apt-get install -y git

# Switch back to Jenkins user
USER jenkins
