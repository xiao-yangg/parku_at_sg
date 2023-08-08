import json
import requests

def requestTokenHeader(accessKey: str):
    baseUrl = "https://www.ura.gov.sg/uraDataService/insertNewToken.action"
    headers  = {
        "AccessKey": accessKey,
        "User-Agent": "curl/7.54.0"
    }

    reply = requests.get(baseUrl, headers=headers)

    replyJson = reply.json()
    print(replyJson)
    status = replyJson['Status']

    if(status == "Success"):
        headers  = {
            "AccessKey": accessKey,
            "User-Agent": "curl/7.54.0",
            "Token": replyJson['Result']
        }
        return headers

    return None

def requestCarParkList(headers: dict):
    baseUrl = "https://www.ura.gov.sg/uraDataService/invokeUraDS?service=Car_Park_Details"

    reply = requests.get(baseUrl, headers=headers)
    return reply

def main():
    pass

if __name__ == "__main__":
    main()