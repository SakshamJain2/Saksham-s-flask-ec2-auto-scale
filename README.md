# AWS Auto Scaling Flask App

This project deploys a Flask web app on EC2 instances managed by an Auto Scaling Group behind an Application Load Balancer.

## Setup Steps

1. Launch the setup script:
```bash
bash asg-setup.sh
```

2. Retrieve the Load Balancer DNS:
```bash
aws elbv2 describe-load-balancers --names FlaskAppLoadBalancer --query "LoadBalancers[0].DNSName" --output text
```

3. Visit the DNS in your browser to test the app.
