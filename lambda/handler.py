import json
import urllib.parse


def handler(event, context):

    for record in event["Records"]:

        bucket = record["s3"]["bucket"]["name"]

        key = urllib.parse.unquote_plus(
            record["s3"]["object"]["key"]
        )


        print(
            f"Image received: {key}"
        )

    return {
        "statusCode":200
    }
