# Bash in AWS Lambda

Run Bash in [AWS Lambda](https://aws.amazon.com/lambda/) via [Layers](https://docs.aws.amazon.com/lambda/latest/dg/configuration-layers.html). This Layer is 100% Bash and handles all communication with the Lambda API. This allows you to run full Bash scripts and commands inside of AWS Lambda. This Layer also includes common CLI tools used in Bash scripts.

See the [How To](#how-to) section to understand how to use these layers. Also see the [example.sh](example.sh) file for an example of how to write a Bash script compatible with AWS Lambda.

## How To

### Getting Started

#### AWS Lambda Console

1. Login to your AWS Account and go to the Lambda Console.
2. Create a new function and give it a name and an IAM Role. 
3. For the "Runtime" selection, select `Use custom runtime in function code or layer`. 
4. In the "Designer" section of your function dashboard, select the `Layers` box.
5. Scroll down to the "Referenced Layers" section and click `Add a layer`. 
6. Select the `Provide a layer version ARN` option, then copy/paste the [Layer ARN](#ARNs) for your region.
7. Click the `Add` button.
8. Click `Save` in the upper right.
9. Upload your code and start using Bash in AWS Lambda!

#### AWS CLI

1. Create a function that uses the `provided` runtime and the [Layer ARN](#ARNs) for your region.

```
$ aws lambda create-function \
    --function-name bashFunction \
    --role bashFunctionRole \
    --handler index.handler \
    --runtime provided \
    --layers $ARN
```

2. Upload your code and start using Bash in AWS Lambda!

### Updating Versions

#### AWS Lambda Console
 
1. In the "Designer" section of your function dashboard, select the `Layers` box.
2. Scroll down to the "Referenced Layers" section and click `Add a layer`. 
3. Select the `Provide a layer version ARN` option, then copy/paste the [Layer ARN](README.md#ARNs) for your region.
4. Click the `Add` button.
5. Still under the "Referenced Layers" section, select the previous version and click `Remove`.
6. Click `Save` in the upper right.


#### AWS CLI

1. Update your function's configration and add the [Layer ARN](README.md#ARNs) for your region.

```
$ aws lambda update-function-configuration \
    --function-name bashFunction \
    --layers $ARN
```

### Caveats

Bash behaves in ways unlike other programming languages. As such, there are some requirements on the user's end that must be done.

- `set -e` must be set _inside_ your function

    By default, a bash script won't exit when it encounters an error. In order for the layer to correctly catch the error and report it (as well as stop the script from executing), we must set the function to exit on error. 

- You must send your return value to `stderr`

    Inside a Bash function, anything that is sent to `stdout` is part of the return value for that function. In order to properly capture the user's return value and still send `stdout` to CloudWatch, this Layer uses `stderr` as the return value. To send something to `stderr` simply append ` >&2` to the end of the command. See the example.sh script for help.

### ARNs

**us-east-1**

`arn`


### Included Executables

- `$ aws`
- `$ curl`
- `$ git`
- `$ gunzip`
- `$ gzip`
- `$ jq`
- `$ tar`
- `$ unzip`
- `$ wget`
- `$ zip`

_If you would like to see more, please create an issue._