import json
import urllib.parse
import boto3
import csv
import io

print('Loading function')

s3 = boto3.client('s3')

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

        # Upload the modified content back to the source bucket
        s3.put_object(Bucket=source_bucket, Key=object_key, Body=modified_content)

        return {
            'statusCode': 200,
            'body': 'Adding new lines and uploading completed!'
        }
    except Exception as e:
        print(e)
        raise e
    
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