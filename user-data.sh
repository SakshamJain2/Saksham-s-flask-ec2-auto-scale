#!/bin/bash
apt update -y
apt install -y python3 python3-pip git

cd /home/ubuntu
git clone https://github.com/sakshamjain2/auto-scaling-flask-app.git
cd auto-scaling-flask-app/app

pip3 install -r requirements.txt

nohup python3 app.py &
