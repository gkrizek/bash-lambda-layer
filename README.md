# Bash in AWS Lambda

Run Bash in AWS Lambda via Layers. This Layer is 100% Bash and handles all communication with the Lambda API. This allows you to run full Bash scripts and commands inside of AWS Lambda. This Layer also includes common CLI tools used in Bash scripts.

## How To

#### Caveats

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