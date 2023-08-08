import math
import time
import datetime
import parse

import logging
import json
from typing import List, Tuple

import mysql.connector
import mysql.connector.cursor

import DB
import UraDataRequest


accessKey = "a4dc91ea-4ac3-44b0-aab8-5c7e80da9ef2"

def getData():
    headers = UraDataRequest.requestTokenHeader(accessKey)
    reply = UraDataRequest.requestCarParkList(headers)
    
    replyJson = reply.json()
    status = replyJson["Status"]
    if(status != "Success"):
        return None

    for d in replyJson["Result"]:
        pass

def insertDB(cursor: mysql.connector.cursor.CursorBase, data: List):
    query = "INSERT INTO carpark (carpark_id, name, carpark_type, lots, car_price, motor_price, x_coord, y_coord) \
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s) AS new\
        ON DUPLICATE KEY UPDATE name=new.name, carpark_type=new.carpark_type, lots=new.lots, car_price=new.car_price, motor_price=new.motor_price, x_coord=new.x_coord, y_coord=new.y_coord"
    logging.debug(f"Insert Query: {query}")
    cursor.executemany(query, data)

def main():

    pass

if __name__ == "__main__":
    main()