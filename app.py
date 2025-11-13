from flask import Flask, render_template, request, redirect
import boto3
import uuid
from datetime import datetime
from config import S3_BUCKET, DYNAMO_TABLE, AWS_REGION

app = Flask(__name__)

s3 = boto3.client('s3', region_name=AWS_REGION)
dynamodb = boto3.resource('dynamodb', region_name=AWS_REGION)
table = dynamodb.Table(DYNAMO_TABLE)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/upload', methods=['POST'])
def upload():
    name = request.form['name']
    email = request.form['email']
    file = request.files['resume']

    if file.filename == '':
        return "No file selected", 400

    file_key = f"{uuid.uuid4()}_{file.filename}"
    s3.upload_fileobj(file, S3_BUCKET, file_key)

    resume_url = f"https://{S3_BUCKET}.s3.{AWS_REGION}.amazonaws.com/{file_key}"

    table.put_item(
        Item={
            'id': str(uuid.uuid4()),
            'name': name,
            'email': email,
            'resume_url': resume_url,
            'timestamp': datetime.utcnow().isoformat()
        }
    )

    return redirect('/')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
