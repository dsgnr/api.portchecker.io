# Standard Library
import ast
import json

# First Party
from portchecker.portchecker.port_checker import do_portcheck


def lambda_handler(event, context):
    # We must ignore the undefined variable here to allow pylint to pass,
    # since this is provided to us inside AWS Lambda
    # pylint: disable=undefined-variable
    body = ast.literal_eval(event["body"])
    # pylint: enable=undefined-variable
    address = body["host"]
    ports = body["ports"]
    response_body = {"error": False, "msg": None, "results": {}}
    try:
        response_body["results"] = do_portcheck(address, ports)
    except Exception as ex:
        response_body["error"] = True
        response_body["msg"] = str(ex)
    return {
        "statusCode": 200 if not response_body["error"] else 400,
        "headers": {
            "Access-Control-Allow-Origin": "*",
            "Content-Type": "application/json",
        },
        "body": json.dumps(response_body),
    }
