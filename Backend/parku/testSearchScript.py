import math
import time
import datetime
import requests

def main():

    dataDict = {}

    #dataDict['location'] = {'longitude': 103.7067, 'latitude': 1.3397} # Jurong Point
    dataDict['location'] = {'longitude': 103.8543, 'latitude': 1.30125} # Carpark: ACB
    
    dataDict['time'] = datetime.datetime.strftime(datetime.datetime.now(), "%Y-%m-%d %H:%M:%S")
    #dataDict['time'] = "2022-04-02 17:25:00"
    dataDict['count'] = 50

    dataDict['max_distance'] = 0.5
    dataDict['max_rate'] = 5.0

    searchPath = "http://localhost:8001/searchCarPark"

    headers = {"Content-Type":"application/json"}

    reply = requests.post(searchPath, json=dataDict, headers=headers)

    print(reply.status_code)
    print(reply.json())
    pass

if __name__ == "__main__":
    main()