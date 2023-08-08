import math
import time
import datetime
import logging

from typing import List, Tuple, Union

import numpy as np

import mysql.connector
import mysql.connector.cursor

import DB

logging.basicConfig(level=logging.DEBUG)

def getAverage(cursor: mysql.connector.cursor.CursorBase, dateStart: datetime.datetime, timeStart: float, timeEnd: float, noWeeks: int, carparkIds: Union[List, Tuple]):

    # timeStart and timeEnd are hours in float format, 12 am = 0; 1 am = 1; 1am next day = 25

    dateStr = datetime.datetime.strftime(dateStart, "%Y-%m-%d")
    dateCapStr = datetime.datetime.strftime(dateStart - datetime.timedelta(weeks=noWeeks), "%Y-%m-%d")

    timeStr = f"{int(timeStart):02}:{int((timeStart % 1) * 60):02}:00"

    idsStr = "("
    for i, cId in enumerate(carparkIds):
        if( i < len(carparkIds) - 1):
            idsStr += f"'{cId}', "
        else:
            idsStr += f"'{cId}')"

    #query = f'SELECT * from carpark_record WHERE (carpark_id = "{carparkId}") and (time(carpark_record.time) > "{timeStr}") and time(carpark_record.time) <= time("{timeStr}") + INTERVAL {timeEnd-timeStart:.02f} HOUR and date("{dateCapStr}") < date(carpark_record.time) and weekday(carpark_record.time) = weekday("{dateStr}")'
    query = f'SELECT carpark_id, "{dateStr + " " + timeStr}", ROUND(AVG(carpark_record.available_lots)) from carpark_record WHERE (time(carpark_record.time) > "{timeStr}") and time(carpark_record.time) <= time("{timeStr}") + INTERVAL {timeEnd-timeStart:.02f} HOUR and date("{dateCapStr}") < date(carpark_record.time) and weekday(carpark_record.time) = weekday("{dateStr}") and lot_type = "C" and carpark_id in {idsStr} GROUP BY carpark_id'
    #print(query)

    cursor.execute(query)
    results = cursor.fetchall()
    #print(results)

    return results

def predictCarpark(cursor: mysql.connector.cursor, carparkId: str):

    pass

def predictAll(db: mysql.connector.MySQLConnection, cursor: mysql.connector.cursor.CursorBase, dateStart: datetime.datetime, timeStart: float, timeEnd: float, noWeeks: int, batchSize=600):

    query = "SELECT carpark_id FROM carpark"

    cursor.execute(query)
    results = cursor.fetchall()

    for i in range(0, len(results), batchSize):
        batch = list(zip(*results[i:i+batchSize]))[0]
        print(batch)
        avgs = getAverage(cursor, dateStart, timeStart, timeEnd, noWeeks, batch)
        print(avgs)
        insertDB(cursor, avgs)
        db.commit()

    pass

def insertDB(cursor: mysql.connector.cursor, data: List):
    query = "INSERT INTO carpark_pred (carpark_id, time, pred_lots) VALUES (%s, %s, %s) AS new\
        ON DUPLICATE KEY UPDATE pred_lots=new.pred_lots"
    logging.debug(f"Insert Query: {query}")
    cursor.executemany(query, data)

def cleanDB(cursor: mysql.connector.cursor, beforeDateTime: datetime.datetime):
    # remove prediction before this date
    dateStr = datetime.datetime.strftime(beforeDateTime, "%Y-%m-%d %H:%M:%S")
    query = f'DELETE FROM carpark_pred WHERE carpark_pred.time <  "{dateStr}"'
    logging.debug(f"Delete Query: {query}")
    cursor.execute(query)

def updatePeriod(db: mysql.connector.MySQLConnection, cursor: mysql.connector.cursor.CursorBase, dateStart: datetime.datetime, dateEnd: datetime.datetime, intervals: List, noWeeks: int, batchSize: int=600):

    # Includesive of dateEnd

    startDate = datetime.datetime(year=dateStart.year, month=dateStart.month, day=dateStart.day)
    endDate = datetime.datetime(year=dateEnd.year, month=dateEnd.month, day=dateEnd.day)

    d1 = datetime.timedelta(days=1)

    curDate = startDate

    while(curDate < endDate):

        for s,e in intervals:
            predictAll(db, cursor, curDate, s, e, noWeeks, batchSize)

        curDate = curDate + d1

def test1():

    db = DB.connectDB()
    cursor = db.cursor()

    #dateStart = datetime.datetime.now()
    dateStart = datetime.datetime(year=2022, month=3, day=30)
    timeStart = 10
    timeEnd = 10.9
    noWeeks = 3
    carparkIds = ["BE3", "A10", "STAM"]

    getAverage(cursor, dateStart, timeStart, timeEnd, noWeeks, carparkIds)
    
    cursor.close()
    db.close()

def test2():

    db = DB.connectDB()
    cursor = db.cursor()

    dateStart = datetime.datetime(year=2022, month=3, day=30)
    timeStart = 10
    timeEnd = 10.9
    noWeeks = 3

    predictAll(db, cursor, dateStart, timeStart, timeEnd, noWeeks, batchSize=5)

    cursor.close()
    db.close()

def test3():

    db = DB.connectDB()
    cursor = db.cursor()

    startDate = datetime.datetime.now()
    endDate = startDate + datetime.timedelta(days=7)

    intervals = [
        (i, i+0.9) for i in range(24)
    ]

    noWeeks = 5

    cleanDB(cursor, datetime.datetime.now())
    db.commit()

    updatePeriod(db, cursor, startDate, endDate, intervals, noWeeks, batchSize=50)

    cursor.close()
    db.close()

def main():
    #test1()
    #test2()
    test3()
    pass

if __name__ == "__main__":
    main()