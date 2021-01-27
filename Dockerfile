FROM python:3.9

RUN apt-get update -y; apt-get upgrade -y; \
    apt-get install -y curl jq

WORKDIR /tmp

ENV PATH=/root/bin:$PATH
RUN echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
RUN echo 'alias l="ls -lah"' >> ~/.bashrc
RUN pip install --upgrade awscli boto3

# Get terraform
RUN export TF_VERSION=0.14.5 && wget https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip \
    && unzip terraform_${TF_VERSION}_linux_amd64.zip \
    && mv terraform /usr/local/bin \
    && rm terraform_${TF_VERSION}_linux_amd64.zip

WORKDIR /livestorm