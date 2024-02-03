#!/bin/bash
 
# Installing necessary packages
sudo yum install -y httpd wget unzip > /dev/null
 
# Starting and enabling httpd service
sudo systemctl start httpd
sudo systemctl enable httpd
 
# Downloading and extracting web files
mkdir -p /tmp/webfiles
cd /tmp/webfiles
wget https://www.tooplate.com/zip-templates/2098_health.zip > /dev/null
unzip 2098_health.zip > /dev/null
 
# Moving web files to the web server directory
sudo cp -r 2098_health/* /var/www/html/
 
# Restarting httpd service
sudo systemctl restart httpd
 
# Cleaning up
rm -rf /tmp/webfiles
 
# Checking the status of the httpd service and the content of the web server directory
sudo systemctl status httpd
ls /var/www/html/