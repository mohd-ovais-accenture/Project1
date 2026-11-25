#!/bin/bash
set -e

apt-get update -y
apt-get install -y nginx

systemctl enable nginx
systemctl start nginx

cat << 'HTML' > /var/www/html/index.html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Terraform Linux EC2 Web Server</title>
  <style>
    body { font-family: Arial, sans-serif; background: #0f172a; color: #f8fafc; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; }
    .box { background: #1e293b; padding: 2rem 3rem; border-radius: 10px; text-align: center; }
    h1 { color: #38bdf8; margin-top: 0; }
  </style>
</head>
<body>
  <div class="box">
    <h1>Web Server Live</h1>
    <p>Provisioned with Terraform on AWS EC2.</p>
  </div>
</body>
</html>
HTML
