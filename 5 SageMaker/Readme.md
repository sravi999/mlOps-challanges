# Deploy Model in Amazon Sagemaker

Amazon SageMaker is a fully managed machine learning service. Developers can quickly and easily build and train machine learning models, and then directly deploy them into a production-ready hosted environment

# Create a Train Job

To train a model in AWS SageMaker, you need to create a training job through the SageMaker SDK or the AWS console. Once the training is complete, Amazon SageMaker saves the resulting model artifacts to the Amazon S3 location you specify. The training job includes the following information

- AWS S3 bucket where you've stored the training data

* AWS S3 bucket where you want to store the ouput of the job
* The registry path where the training image is stored in Amazon ECR
* The compute resources that you want SageMaker to use for model training. Compute resources are machine learning (ML) compute instances that are managed by SageMaker.

# Create a Model

To deploy a model to Amazon SageMaker, first create the model by providing the location of the model artifacts and inference code. The create model includes the following information.

- Provide docker image that contains inference code, artifacts (from prior training), and a custom environment map that the inference code uses when you deploy the model for predictions

* Provide the URL where model artifacts are stored in S3

# Create an Endpoint Config

Create an endpoint configuration. In the configuration, specify which models to deploy, and the relative traffic weighting and hardware requirements for each.

```bash
endpoint_config_1_response = client.create_endpoint_config(
    EndpointConfigName="endpoint_config_1_name",
    ProductionVariants=[
        {
            "VariantName": "AllTrafficVariant",
            "ModelName": "model_1_name",
            "InitialInstanceCount": 1,
            "InstanceType": "ml.c5.large",
            "InitialVariantWeight": 1,
        },
    ],
)
```

# Deploy your model

Create an endpoint using the endpoint configuration specified in the request. Amazon SageMaker uses the endpoint to provision resources and deploy models.

```bash
create_endpoint_response = client.create_endpoint(
    EndpointName="endpoint_name",
    EndpointConfigName="endpoint_config_1_name",
)
```

# Dockerize the Model

- Create a directory for your Docker container and navigate into it.
- Create a Dockerfile with the following content:

```bash
# Use an official SageMaker Python image as the base image
FROM 763104351884.dkr.ecr.us-east-1.amazonaws.com/pytorch-inference:1.6.0-cpu-py3

# Set working directory
WORKDIR /opt/ml/code

# Copy your model files to the container
COPY model.py requirements.txt /opt/ml/code/

# Install required dependencies
RUN pip install -r requirements.txt

# Define inference command
ENTRYPOINT ["python", "model.py"]
```

- Build the Docker image

```bash

docker build -t LOCAL_IMAGE_NAME .
```

- Authenticate Docker to your ECR repository

```bash
aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin AWS_ACCOUNT_ID.dkr.ecr.ap-south-1.amazonaws.com
```

- Tag Image

```bash
docker tag LOCAL_IMAGE_NAME:latest AWS_ACCOUNT_ID.dkr.ecr.ap-south-1.amazonaws.com/AWS_ECR_REGISTORY_NAME:latest
```

- Push the image to ECR

```bash
  docker push AWS_ACCOUNT_ID.dkr.ecr.ap-south-1.amazonaws.com/AWS_ECR_REGISTORY_NAME:latest
```
