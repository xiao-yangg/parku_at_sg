import time
import math
import logging
import requests
import datetime

from typing import List, Tuple

import mysql.connector
import mysql.connector.cursor

import DB
import DataGovRequest

logging.basicConfig(level=logging.DEBUG)

baseUrl = "https://api.data.gov.sg/v1/transport/carpark-availability"

def getData(date: datetime.datetime, TIMEOUT=10) -> Tuple:
    dateStr = datetime.datetime.strftime(date, "%Y-%m-%dT%H:%M:%S")
    logging.debug(f"Querying: {dateStr}")
    params = {
        "date_time": dateStr
    }
    try:
        reply = requests.get(baseUrl, params, timeout=TIMEOUT)
    except requests.exceptions.ReadTimeout:
        logging.debug(f"Request timed out")
        return None

    logging.debug(f"Request Status: {reply.status_code}")
    logging.error(f"Json Data: {reply.json()}")

    if(reply.status_code != 200):
        return None

    data = []

    if(len(reply.json()['items']) == 0): # No data at requested time
        return data

    dataList = reply.json()['items'][0]['carpark_data']

    for d in dataList:
        parkId = d['carpark_number']
        carparkInfo = d['carpark_info'][0]
        totalLots = carparkInfo['total_lots']
        lotType = carparkInfo['lot_type']
        availableLots = carparkInfo['lots_available']
        updateTime = d['update_datetime'].replace('T', ' ')
        data.append((parkId, updateTime, totalLots, availableLots, lotType))

    return data


def getDataRange(startDate: datetime.datetime, endDate: datetime.datetime, increment: datetime.timedelta, DELAY=1, RETRIES=5, RETRY_DELAY=20, TIMEOUT=10):
    '''
    Request data in range from [startDate, endDate] increment by increment.
    Data gov specify max 60 request per minute per api key.
    
    '''

    data = []

    curDate = startDate

    while(curDate <= endDate):
        ret = 0
        while(ret < RETRIES):
            singleData = getData(curDate, TIMEOUT=TIMEOUT)
            if(singleData is not None):
                break
            ret += 1
            logging.debug(f"[{ret}] Retrying in {RETRY_DELAY}")
            time.sleep(RETRY_DELAY)
        if(singleData is not None):
            data.extend(singleData)
        curDate += increment
        time.sleep(DELAY)

    return data


def insertDB(cursor: mysql.connector.cursor.CursorBase, data: List):
    query = "INSERT INTO carpark_record (carpark_id, time, total_lots, available_lots, lot_type) VALUES (%s, %s, %s, %s, %s) AS new\
        ON DUPLICATE KEY UPDATE total_lots=new.total_lots, available_lots=new.available_lots"
    logging.debug(f"Insert Query: {query}")
    cursor.executemany(query, data)

def updateRange(db: mysql.connector.MySQLConnection, cursor: mysql.connector.cursor.CursorBase,startDate: datetime.datetime, endDate: datetime.datetime, increment: datetime.timedelta):
    data = getDataRange(startDate, endDate, increment)
    insertDB(cursor, data)
    db.commit()

def update():

    db = DB.connectDB()
    cursor = db.cursor()

    data = getData(datetime.datetime.now())

    logging.debug(f"Data: {data}")
    insertDB(cursor, data)

    db.commit()

    cursor.close()
    db.close()

def main():

    logFile = "logs/HDBaval.log"

    with open(logFile, 'r') as f:
        startDateStr = f.read()

    startDate = datetime.datetime.strptime(startDateStr, "%Y-%m-%d %H:%M:%S")
    endDate = datetime.datetime.now()
    mins = endDate.minute
    if(mins > 30):
        mins = 30
    else:
        mins = 0
    endDate = datetime.datetime(year=endDate.year, month=endDate.month, day=endDate.day, hour=endDate.hour, minute=mins)
    increment = datetime.timedelta(minutes=30)

    batchSize = 10

    curStart = startDate
    curEnd = startDate + increment * batchSize

    db = DB.connectDB()
    cursor = db.cursor()

    while(curEnd <= endDate):

        logging.info(f"Starting {curStart} - {curEnd}")
        updateRange(db, cursor, curStart, curEnd, increment)

        if(curEnd == endDate):
            break

        curStart = curEnd
        curEnd = min(curStart + increment * batchSize, endDate)

    cursor.close()
    db.close()

    with open(logFile, 'w') as f:
        f.write(datetime.datetime.strftime(endDate, "%Y-%m-%d %H:%M:%S"))


if __name__ == "__main__":
    main()