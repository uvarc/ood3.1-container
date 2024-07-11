FROM rockylinux:8.9

# Update the system and install necessary packages
RUN dnf -y update && \
    dnf -y install \
    sudo \
    dnf-plugins-core \
    epel-release && \
    dnf config-manager --set-enabled powertools && \
    dnf module enable ruby:3.1 nodejs:18 -y && \
    dnf install -y https://yum.osc.edu/ondemand/3.1/ondemand-release-web-3.1-1.el8.noarch.rpm && \
    dnf install -y ondemand httpd httpd-tools && \
    dnf install -y mod_authnz_pam passwd openssh-server&&\
    dnf clean all

RUN sudo systemctl enable httpd
RUN sudo echo "LoadModule authnz_pam_module modules/mod_authnz_pam.so" > /etc/httpd/conf.modules.d/55-authnz_pam.conf

# Enable permissions for PAM auth
RUN sudo chmod 640 /etc/shadow
RUN sudo chgrp apache /etc/shadow


# Create the /etc/pam.d/ood file and configure PAM
RUN echo "auth required pam_unix.so" > /etc/pam.d/ood && \
    echo "account required pam_unix.so" >> /etc/pam.d/ood

# Create a system user with
# user: username
# pass: password
RUN useradd username && \
    echo "username:password" | chpasswd

# Configurations for ood portal
COPY ood_portal.yml /etc/ood/config/ood_portal.yml

# Set the ServerName directive globally in Apache configuration
RUN echo "ServerName localhost" >> /etc/httpd/conf/httpd.conf

# Generate a self-signed certificate for HTTPS
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/pki/tls/private/localhost.key -out /etc/pki/tls/certs/localhost.crt -subj "/CN=localhost"

# Expose the necessary ports
EXPOSE 80

# Start the Apache service
RUN sudo /opt/ood/ood-portal-generator/sbin/update_ood_portal

CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]
