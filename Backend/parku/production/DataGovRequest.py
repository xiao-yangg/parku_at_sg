import json
import requests

def requestDataGov(resourceId: str, limit: int = 100, offset: int = 0):
    baseUrl = "https://data.gov.sg/api/action/datastore_search"
    params = {
        "resource_id": resourceId,
        "limit": limit,
        "offset": offset
    }
    url = baseUrl + f"?resource_id={resourceId}&limit={limit}&offset={offset}"
    reply = requests.get(baseUrl, params)
    return reply

def main():
    pass

if __name__ == "__main__":
    main()