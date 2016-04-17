FROM centos:7
MAINTAINER Thonatos.Yang <thonatos.yang@gmail.com>

LABEL vendor=Implements.io
LABEL io.implements.version=0.0.1

USER root

ENV HOME /root

ENV NGINX_PORT 8080
ENV NODE_PORT 3000
ENV NODE_VERSION 4.4.1
ENV NVM_DIR /root/.tnvm
ENV NVM_BIN $NVM_DIR/versions/node/v$NODE_VERSION/bin
# Configure Environment
RUN mkdir -p /app
RUN	mkdir -p /opt/docker

WORKDIR	/app

COPY src/ /app
COPY opt/ /opt/docker/

# Add sources for latest nginx
COPY conf/yum.repos.d/nginx-7.x.repo /etc/yum.repos.d/nginx-7.x.repo

# Change mirrors
RUN yum install wget -y
RUN mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
RUN wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo

# Update System
RUN yum -y update

# Install required software
RUN yum install -y python \
                   curl \
                   git \
                   unzip \
                   tree \
                   gcc \
                   gcc-c++ \
                   make \
                   openssl-devel \
                   nginx

# Install nginx
# RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN rm -rf /etc/nginx/conf.d/*
COPY conf/nginx/conf.d/*.conf /etc/nginx/conf.d/

# Install supervisor
RUN wget -qO- https://bootstrap.pypa.io/get-pip.py | python && \
    pip install supervisor
    
RUN mkdir -p /var/log/supervisor
RUN touch /var/log/supervisor/supervisord.log     
COPY conf/supervisor/supervisord.conf /etc/supervisord.conf
COPY conf/supervisor/conf.d/ /etc/supervisor/conf.d/

# Install node.js
RUN wget -qO- https://raw.githubusercontent.com/aliyun-node/tnvm/master/install.sh | bash && \
    source $HOME/.bashrc && \
    tnvm install "node-v$NODE_VERSION" && \
    tnvm use "node-v$NODE_VERSION" && \ 
    npm install -g node-gyp --registry=https://registry.npm.taobao.org && \
    npm install --registry=https://registry.npm.taobao.org

# RUN wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.31.0/install.sh | bash
# RUN source $HOME/.bashrc && nvm install v$NODE_VERSION && nvm use v$NODE_VERSION               
# RUN source $HOME/.bashrc && npm install -g node-gyp

# Initialize the app
RUN source $HOME/.bashrc && \
    npm install		
        
# Add log directories
RUN mkdir -p /var/log/node/
RUN mkdir -p /var/log/nginx/        

EXPOSE  $NGINX_PORT $NODE_PORT

RUN source $HOME/.bashrc
CMD [ "/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf" ]