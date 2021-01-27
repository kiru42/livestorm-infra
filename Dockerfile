FROM python:3.9

RUN apt-get update -y; apt-get upgrade -y; \
    apt-get install -y curl jq

WORKDIR /tmp

ENV PATH=/root/bin:$PATH
RUN echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
RUN echo 'alias l="ls -lah"' >> ~/.bashrc
RUN pip install --upgrade awscli boto3

# Get aws-iam-authenticator
RUN curl -o aws-iam-authenticator \
    https://amazon-eks.s3.us-west-2.amazonaws.com/1.18.9/2020-11-02/bin/darwin/amd64/aws-iam-authenticator
RUN chmod +x ./aws-iam-authenticator
RUN mkdir -p ~/bin && cp ./aws-iam-authenticator ~/bin/aws-iam-authenticator

# Get Kubectl
RUN curl -o kubectl \
    https://amazon-eks.s3.us-west-2.amazonaws.com/1.18.9/2020-11-02/bin/darwin/amd64/kubectl
RUN chmod +x ./kubectl
RUN mv ./kubectl ~/bin/kubectl

# Get Helm3
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
RUN chmod 700 get_helm.sh
RUN ./get_helm.sh

# Get terraform
RUN export TF_VERSION=0.14.5 && wget https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip \
 && unzip terraform_${TF_VERSION}_linux_amd64.zip \
 && mv terraform /usr/local/bin \
 && rm terraform_${TF_VERSION}_linux_amd64.zip

WORKDIR /livestorm