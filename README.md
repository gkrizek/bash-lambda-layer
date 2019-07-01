# Bash in AWS Lambda

Run Bash in [AWS Lambda](https://aws.amazon.com/lambda/) via [Layers](https://docs.aws.amazon.com/lambda/latest/dg/configuration-layers.html). This Layer is 100% Bash and handles all communication with the Lambda Runtime API. This allows you to run full Bash scripts and commands inside of AWS Lambda. This Layer also includes common CLI tools used in Bash scripts.

See the [How To](#how-to) section to understand how to use these layers. Also see the [example-basic.sh](examples/example-basic.sh) file for an example of how to write a Bash script compatible with this Layer.

### ARN

```
arn:aws:lambda:<region>:744348701589:layer:bash:8
```

## How To

### Getting Started

#### AWS Lambda Console

1. Login to your AWS Account and go to the Lambda Console.
2. Create a new function and give it a name and an IAM Role. 
3. For the "Runtime" selection, select `Use custom runtime in function code or layer`. 
4. In the "Designer" section of your function dashboard, select the `Layers` box.
5. Scroll down to the "Referenced Layers" section and click `Add a layer`. 
6. Select the `Provide a layer version ARN` option, then copy/paste the [Layer ARN](#ARN) for your region.
7. Click the `Add` button.
8. Click `Save` in the upper right.
9. Upload your code and start using Bash in AWS Lambda!

#### AWS CLI

1. Create a function that uses the `provided` runtime and the [Layer ARN](#ARN) for your region.

```
$ aws lambda create-function \
    --function-name bashFunction \
    --role bashFunctionRole \
    --handler index.handler \
    --runtime provided \
    --layers arn:aws:lambda:<region>:744348701589:layer:bash:8 \
    --zip-file fileb://function.zip
```

2. Start using Bash in AWS Lambda!

### Updating Versions

#### AWS Lambda Console
 
1. In the "Designer" section of your function dashboard, select the `Layers` box.
2. Scroll down to the "Referenced Layers" section and click `Add a layer`. 
3. Select the `Provide a layer version ARN` option, then copy/paste the [Layer ARN](#ARN) for your region.
4. Click the `Add` button.
5. Still under the "Referenced Layers" section, select the previous version and click `Remove`.
6. Click `Save` in the upper right.


#### AWS CLI

1. Update your function's configration and add the [Layer ARN](#ARN) for your region.

```
$ aws lambda update-function-configuration \
    --function-name bashFunction \
    --layers arn:aws:lambda:<region>:744348701589:layer:bash:8
```

### Writing Scripts

Like any other Lambda function code, your main script's name must match the first part of your handler. Inside your main script, you must define a function that matches the second part of the handler. You must have `set -e` be the first line inside your function. Putting `#!/bin/bash` at the top of your file is not necessary. So if your Lambda handler is `index.handler`, your file and contents should look like:

```
$ cat index.sh
handler () {
    set -e
    ...
}
```

The `event` data is sent to your function as the first parameter. To access it, you should use `$1`. So if you need the `event` data, you should set it to a variable. For example, `EVENT_DATA=$1`.

```
handler () {
    set -e
    EVENT_DATA=$1
}
```

All the pre-installed tools are already in your `$PATH` so you can use them as expected. Any command output is automatically sent to CloudWatch, just like normal Lambda functions. 

```
handler () {
    set -e
    EVENT_DATA=$1
    aws s3 ls $(echo $EVENT_DATA | jq ."bucket")
}
```

If you need to send a response back, you should send the response to `stderr`. (see the [Caveats](#CAVEATS) section for an explanation) To send output to `stderr` you should use `>&2`. This will be picked up and returned from the Lambda function.

```
handler () {
    set -e
    EVENT_DATA=$1
    aws s3 ls $(echo $EVENT_DATA | jq ."bucket")
    echo "{\"success\": true}" >&2
}
```

### Caveats

Bash behaves in ways unlike other programming languages. As such, there are some requirements on the user's end that must be done.

- `set -e` must be set _inside_ your function

    By default, a bash script won't exit when it encounters an error. In order for the layer to correctly catch the error and report it (as well as stop the script from executing), we must set the function to exit on error. 

- You must send your return value to `stderr`

    Inside a normal Bash function, anything that is sent to `stdout` is part of the return value for that function. In order to properly capture the user's return value and still send `stdout` to CloudWatch, this Layer uses `stderr` as the return value. To send something to `stderr` simply append ` >&2` to the end of the command. See the [example scripts](examples) for help.

### Notes

- `$HOME` is set to `/tmp`. This is because the Lambda filesystem is read-only except for the `/tmp` directory. Some programs require `$HOME` to be writeable (like the AWS CLI and some SSH commands), so this allows them to work without issue.

- Files to configure the AWS CLI should be put in `/tmp/.aws`. By default, the CLI uses the same region and IAM Role as your lambda function. If you need to set something different, you can use the `/tmp/.aws/config` and `/tmp/.aws/credentials` files accordingly.

- When using curl, you should use the `-s` flag. Without the silent flag, curl will send the progress bar of your request to `stderr`. This will show up in your response. So it's usually best to disable the progress bar.

- The AWS CLI appears to be much slower than most of the AWS SDKs. Take this into consideration when comparing Bash with another language and evaluating execution times.

- If a command is logging unwanted messages to `stderr` that are being picked up in your response, you can see if there is something similiar to a `--silent` flag. If there is not, you can remove the messages to `stderr` by redirecting to /dev/null (`2>/dev/null`) or redirecting `stderr` to `stdout` for that command (`2>&1`) to send them to CloudWatch.

- With this method there is no `context` in the function, only `event` data. The `event` data is sent to your function as the first parameter. So to access the `event` data, use `$1`, for example `EVENT_DATA=$1`. In order to give some details that were availabe in the `context`, I export a few additional variables.

    `AWS_LAMBDA_REQUEST_ID` - AWS Lambda Request ID 

    `AWS_LAMBDA_DEADLINE_MS` - Time, in epoch, that your function must exit by

    `AWS_LAMBDA_FUNCTION_ARN` - Full AWS Lambda function ARN

    `AWS_LAMBDA_TRACE_ID` - The sampling decision, trace ID, and parent segment ID of AWS XRay

### Building

To build a layer, simply run `make build`. This will create a zip archive of the layer in the `export/` directory.

### Publishing

To publish the layer to the public, simply run `make publish`. This will create a new version of the layer from the `export/layer.zip` file (create from the Build step) and give it a global read permission.

### Adding New Executables

Some executables are able to run by themselves and some require additional dependencies that are present on the server. It's hard to cover here case here, but if the executable run by itself it can easily be added. If it has dependencies, you must explore what those dependencies are and how to add them to the layer as well.

You can either add the executable from an Amazon Linux AMI or from the [lambci/lambda:build-python3.6](https://github.com/lambci/docker-lambda) Docker image.

_Disclaimer: I usually don't add in executables from pull requests for security reasons. If you would like to see an executable in this layer make an issue and I'll try to add it._

### Included Executables

- `$ aws`
- `$ bc`
- `$ git`
- `$ jq`
- `$ rsync`
- `$ scp`
- `$ sftp`
- `$ ssh`
- `$ sshpass`
- `$ time`
- `$ traceroute`
- `$ tree`
- `$ wget`
- `$ vim`
- `$ zip`

**Already included in the Lambda environment:**

- `$ awk`
- `$ cat`
- `$ curl`
- `$ cut`
- `$ date`
- `$ diff`
- `$ grep`
- `$ gzip`
- `$ head`
- `$ md5sum`
- `$ pwd`
- `$ sed`
- `$ tar`
- `$ tail`
- `$ tee`
- `$ xargs`

_If you would like to see more, please create an issue._

Shout-out to the LambCI team for their work on [lambci/git-lambda-layer](https://github.com/lambci/git-lambda-layer) which some of the `git` and `ssh` build process was taken from.
