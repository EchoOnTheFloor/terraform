#!/bin/bash
apt-get update
apt-get install -y apache2
echo "<h1>Hello from Terraform Instance Group</h1>" > /var/www/html/index.html