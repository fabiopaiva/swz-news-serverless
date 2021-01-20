# SWZ News

## Projects description

4 projects share this repository:

### 1) [Terraform AWS master account](terraform-main-account/README.md) 

The master account is responsible for the initial setup on AWS for the following components:

* Terraform S3/DynamoDB backend (state management)
* CodePipeline and CodeDeploy for Terraform management responsible for both Terraform AWS master account and 
  Terraform AWS SWZ News account.
  * Pipeline for Terraform has the following steps:
    * Pull source
    * Terraform plan
    * Confirm (Manual approval)
    * Terraform apply

### 2) [Terraform SWZ News AWS account](terraform/README.md)

Terraform project used to manage SWZ News project infrastructure.

### 3) [Backend](backend/README.md)

The backend project is a [Serverless](http://serverless.com/) application responsible for the following endpoints:

* GET /news
* GET /news/:slug
* POST /news

### 4) [Frontend](terraform/README.md)

The frontend is a regular [CRA](https://reactjs.org/docs/create-a-new-react-app.html) responsible for:

* displaying a list with news
* displaying a news item

## Cloud Components used on this application

The following components have been used to build and run this application

### ACM (SSL)

Frontend, API, and Authorization subdomains using HTTPS

### CloudFormation

Serverless framework orchestration

### Cloudfront (Webserver)

* Website static files server
* React SPA 404 error handling
* Cache
* Access restricted to The Netherlands
* API Gateway Edge-optimized

### CodePipeline and CodeBuild

Pipeline for testing, building, and deploying both frontend and serverless backend.

### Cognito

Identity manager providing OAuth2 client credentials grant for POST /news endpoint

### DynamoDB

Storing Terraform state and news

### IAM

Roles and policies configuring the accesses to the following resources:

* KMS
* CodePipeline
* CodeBuild
* ~~Serverless deployment~~
* Serverless Lambda functions
* S3 buckets policies
* ~~Cross account roles~~

### KMS

Encrypting/decrypting data stored on S3, SQS and API Gateway cache

### Lambda functions

Serverless functions and SQS consumer

### Route53

DNS management

* SSL Validations
* Subdomains
    * Website
    * API
    * OAuth2 Token endpoint 

### S3 Buckets

Data storage for:

* Pipeline artifacts
* logs
* Serverless deployment artifacts
* Terraform state
* ~~File uploads~~

### SQS

Simple queue for data coming from POST /news endpoint and processed by a Lambda function

## Performance, scalability and availability considerations

### API Gateway 

> By default, API Gateway allows for up to 10,000 requests per second. 

[source](https://aws.amazon.com/blogs/architecture/things-to-consider-when-you-build-rest-apis-with-amazon-api-gateway/#:~:text=By%20default%2C%20API%20Gateway%20allows,to%2010%2C000%20requests%20per%20second.&text=If%20you%20receive%20a%20large,the%20total%20number%20of%20connections.)

Plus:

* [Payload compression](https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-gzip-compression-decompression.html)
* [API cache](https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-caching.html)
* [Edge-optimized API endpoint](https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-basic-concept.html#apigateway-definition-edge-optimized-api-endpoint)

### Lambda functions

>Q: How available are AWS Lambda functions?
> 
>AWS Lambda is designed to use replication and redundancy to provide high availability for both the service itself and for the Lambda functions it operates. There are no maintenance windows or scheduled downtimes for either.

> Q: How do I scale an AWS Lambda function?
> 
> You do not have to scale your Lambda functions – AWS Lambda scales them automatically on your behalf.

[source](https://aws.amazon.com/lambda/faqs)

### Cloudfront

Cloudfront speeds up distribution of your static and dynamic web content for both API backend and static frontend files.

## DynamoDB 

DynamoDB scalability depends on the min/max levels of read and write capacity. 
Alternativaly, it's possible to configure the billing mode to on-demand pricing and 
AWS will take care of the scalability of the database.

For this application it not used on-demand pricing as the project has only data read through CloudFront, 
which provides a great cache layer for GET requests, and it has SQS for writing data to the database.

## SQS 

SQS doesn't improve writing speed to the database, but it provides a great application decoupling, and a
CQRS approach for future developments. 
