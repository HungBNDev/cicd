# syntax=docker/dockerfile:1
FROM jenkins/jenkins:latest

USER root

RUN curl -fsSL https://get.docker.com | bash -
RUN curl -L "https://github.com/docker/compose/releases/download/2.0.0/docker-compose-linux-amd64" -o /usr/local/bin/docker-compose
RUN chmod +x /usr/local/bin/docker-compose
