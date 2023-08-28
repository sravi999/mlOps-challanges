# AWS Lambda

AWS Lambda is a serverless, event-driven compute service that lets you run code for virtually any type of application or backend service without provisioning or managing servers. For example, create Lambda function to trigger a another Lambda function or SNS Topic or SQS based on the S3 events like createObject, deleteObject etc.

# Problem Statement

We use python heavily in our systems and infrastructure. It's important to us that you demonstrate your software development skills, and python is an appropriate vehicle for that. Write a simple AWS Lambda function in Python that reads data from an S3 bucket, processes it, and saves the results back to S3. Explain how you would structure the code and handle errors. If you don't know python, go ahead and use a language you are comfortable with; however keep in mind that you'll need to pick up python quickly if you accept a position with our team

# Implementation

- Write a function to download the .csv file from an S3 bucket and read the contents of the file using the AWS SDK

* You can find the sample CSV file [lambda-s3-process.csv](lambda-s3-process.csv)

```bash
def lambda_handler(event, context):
    #print("Received event: " + json.dumps(event, indent=2))

    # Get the object from the event and show its content type
    source_bucket = event['Records'][0]['s3']['bucket']['name']

    # Get the object key from the event
    object_key = event['Records'][0]['s3']['object']['key']

    try:
        # Read the content of the source object
        response = s3.get_object(Bucket=source_bucket, Key=object_key)

        content = response['Body'].read().decode('utf-8')
        modified_content=process_csv(content=content)

```

- I added two rows to the existing content of the CSV file and uploaded the updated CSV file back to the S3 bucket

```bash
def process_csv(content):
    # Parse the CSV content
    csv_data = io.StringIO(content)
    reader = csv.DictReader(csv_data)
    fieldnames=reader.fieldnames
    rows=[row for row in reader]
    extra_rows=[{"EMPLOYEE_ID":"203","FIRST_NAME":"Susan","LAST_NAME":"Mavris",
                 "EMAIL":"SMAVRIS","PHONE_NUMBER":"515.123.7777","HIRE_DATE":"07-JUN-02","JOB_ID":"HR_REP",
                 "SALARY":"6500","COMMISSION_PCT":" - ","MANAGER_ID":"101","DEPARTMENT_ID":"40"},
                {"EMPLOYEE_ID":"204","FIRST_NAME":"Hermann","LAST_NAME":"Baer",
                 "EMAIL":"HBAER","PHONE_NUMBER":"515.123.8888","HIRE_DATE":"07-JUN-02","JOB_ID":"PR_REP",
                 "SALARY":"10000","COMMISSION_PCT":" - ","MANAGER_ID":"101","DEPARTMENT_ID":"70"}]

    rows=rows+extra_rows

    output_csv=io.StringIO()
    writer = csv.DictWriter(output_csv, fieldnames=fieldnames)
    writer.writeheader()
    writer.writerows(rows)
    return output_csv.getvalue()
```
