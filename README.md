## Open On Demand 3.1 Containerization
This is the development branch of an attempt to containerize OpenOnDemand 3.1 for UVA Research Computing's system

## Overview
- **Purpose:** This container sets up a Rocky Linux 8.9 environment with Apache HTTP Server configured with PAM authentication and OnDemand (OOD) portal.
- **Author:** Adam Eubanks, Jinwoo Kim

## Authentication
```Dockerfile
#Dependency Installation
dnf install -y mod_authnz_pam passwd openssh-server && \

#Followed PAM tutorial in references
RUN sudo echo "LoadModule authnz_pam_module modules/mod_authnz_pam.so" > /etc/httpd/conf.modules.d/55-authnz_pam.conf
RUN sudo chmod 640 /etc/shadow
RUN sudo chgrp apache /etc/shadow

# Configuring the basic authentication to use PAM
RUN echo "auth required pam_unix.so" > /etc/pam.d/ood && \
    echo "account required pam_unix.so" >> /etc/pam.d/ood

# Create a basic system user with user: username and pass: password
# RUN useradd [username] && \
#    echo "[username]:[password]" | chpasswd
# Replace [username] and [password] with desired username and password
RUN useradd username && \
    echo "username:password" | chpasswd
```
```ood_portal.yml
#ood_portal.yml configuration for PAM authentication
auth:
  - 'AuthType Basic'
  - 'AuthName "Open OnDemand"'
  - 'AuthBasicProvider PAM'
  - 'AuthPAMService ood'
  - 'Require valid-user'
user_map_match: '.*'
```

## Build Instructions
```
docker build -t ondemand .
docker run -d -p 8080:80 -t ondemand
```

## References
- [Installing OOD](https://osc.github.io/ood-documentation/release-1.8/installation/install-software.html)
- [Pam Authentication for OOD](https://osc.github.io/ood-documentation/release-1.8/authentication/pam.html)
