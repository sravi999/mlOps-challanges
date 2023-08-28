import boto3
import datetime, time
from sagemaker import image_uris, get_execution_role

# Create a SageMaker client
sagemaker = boto3.client('sagemaker')

FRAMEWORK_VERSION = "1.2-1"

training_image = image_uris.retrieve(
    framework="sklearn",
    region="ap-south-1",
    version=FRAMEWORK_VERSION,
    py_version="py3",
    instance_type="ml.c5.xlarge",
)
print(training_image)

# Specify the details of the training job
training_job_name = 'retraining-job'
role_arn = 'arn:aws:iam::123456789012:role/service-role/sageMakerRole'
training_data_uri = 's3://training-data-bucket/train-data'

# Create a new training job for retraining
response = sagemaker.create_training_job(
    TrainingJobName=training_job_name,
    AlgorithmSpecification={
        'TrainingImage': training_image,
        'TrainingInputMode': 'File',
    },
    RoleArn=role_arn,
    InputDataConfig=[
        {
            'ChannelName': 'train',
            'DataSource': {
                'S3DataSource': {
                    'S3DataType': 'S3Prefix',
                    'S3Uri': training_data_uri,
                },
            },
        },
    ],
    OutputDataConfig={
        'S3OutputPath': 's3://training-output-bucket/output',
    },
    ResourceConfig={
        'InstanceType': 'ml.m4.xlarge',
        'InstanceCount': 1,
        'VolumeSizeInGB': 30,
    },
    StoppingCondition={
        'MaxRuntimeInSeconds': 86400,  
    }
)

print(response)


# Wait for training job success
training_job_1_details = sagemaker.describe_training_job(TrainingJobName=training_job_1_name)

while training_job_1_details["TrainingJobStatus"] == "InProgress":
    training_job_1_details = sagemaker.describe_training_job(TrainingJobName=training_job_1_name)
    print(training_job_1_details["TrainingJobStatus"])
    time.sleep(15)
    
model_1_name = "sklearn-model-1-" + datetime.datetime.now().strftime("%Y-%m-%d-%H-%M-%S")

create_model_1_response = sagemaker.create_model(
    ModelName=model_1_name,
    PrimaryContainer={
        "Image": training_job_1_details["AlgorithmSpecification"]["TrainingImage"],
        "Mode": "SingleModel",
        "ModelDataUrl": training_job_1_details["ModelArtifacts"]["S3ModelArtifacts"],
        "Environment": {
            "SAGEMAKER_CONTAINER_LOG_LEVEL": "20",
            "SAGEMAKER_PROGRAM": training_job_1_details["HyperParameters"]["sagemaker_program"],
            "SAGEMAKER_REGION": "ap-south-1",
            "SAGEMAKER_SUBMIT_DIRECTORY": training_job_1_details["HyperParameters"][
                "sagemaker_submit_directory"
            ],
        },
    },
    ExecutionRoleArn=get_execution_role(),
)


# Create a endpoint configuration

endpoint_config_1_name = "sklearn-endpoint-config-1-" + datetime.datetime.now().strftime(
    "%Y-%m-%d-%H-%M-%S"
)

endpoint_config_1_response = sagemaker.create_endpoint_config(
    EndpointConfigName=endpoint_config_1_name,
    ProductionVariants=[
        {
            "VariantName": "AllTrafficVariant",
            "ModelName": model_1_name,
            "InitialInstanceCount": 1,
            "InstanceType": "ml.c5.large",
            "InitialVariantWeight": 1,
        },
    ],
)


# Deploy the model
endpoint_name = "sklearn-endpoint-" + datetime.datetime.now().strftime("%Y-%m-%d-%H-%M-%S")

create_endpoint_response = sagemaker.create_endpoint(
    EndpointName=endpoint_name,
    EndpointConfigName=endpoint_config_1_name,
)