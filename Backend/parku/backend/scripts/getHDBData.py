import time
import math
import logging
import json

from typing import List, Tuple

import mysql.connector
import mysql.connector.cursor

import DB
import DataGovRequest

logging.basicConfig(level=logging.INFO)

# HDB Carpark Info resource ID
resourceId = "139a3035-e624-4f56-b63f-89ae28d4ae4c"

# Central Area Carpark (used for rate assignment)
# https://www.hdb.gov.sg/car-parks/shortterm-parking/short-term-parking-charges
CENTRAL_CARPARK = {
    "ACB",
    "BBB",
    "BRB1",
    "CY",
    "DUXM",
    "HLM",
    "KAB",
    "KAM",
    "KAS",
    "PRM",
    "SLS",
    "SR1",
    "SR2",
    "TPM",
    "UCS",
    "WCB"
}

# Time
# Monday 00:00 = hr 0
# Monday 01:00 = hr 1

# Central rate 7am - 5pm MON-SAT 1.2 per half hour, others 0.6 per half hour
CAR_CENTRAL_PERIODS = [] # List of conditions
for i in range(6): # MON - SAT
    d = {
        'range': [7 + i * 24, 17 + i * 24], # [min, max] range
        'period': 0.5, # Period (0.5 -> half hour)
        'rate': 1.2 # Rate per period
    }
    CAR_CENTRAL_PERIODS.append(d)
# Default
d = {
    'range': [-1], # [min, max] range
    'period': 0.5, # Period (0.5 -> half hour)
    'rate': 0.6 # Rate per period
}
CAR_CENTRAL_PERIODS.append(d)

CAR_CENTRAL_PARK_RATE = json.dumps(CAR_CENTRAL_PERIODS)

# Non Central rate
CAR_NON_CENTRAL_PARK_RATE = json.dumps(
    {
        'range': [-1], # [min, max] range
        'period': 0.5, # Period (0.5 -> half hour)
        'rate': 0.6 # Rate per period
    }
)

# Motor Rate
MOTOR_PARK_RATE = json.dumps(
    {
        'range': [-1], # [min, max] range
        'period': 0.5, # Period (0.5 -> half hour)
        'rate': 0.6 # Rate per period
    }
)


def getData(limit: int, offset: int) -> Tuple: 
    reply = DataGovRequest.requestDataGov(resourceId, limit=limit, offset=offset)

    logging.debug(f"Request Status: {reply.status_code}")
    # logging.error(f"Json Data: {reply.json()}")

    table = reply.json()['result']
    records = table['records']

    ids = "("
    data = []

    for r in records:
        parkId = r['car_park_no']
        carRate = CAR_CENTRAL_PARK_RATE if parkId in CENTRAL_CARPARK else CAR_NON_CENTRAL_PARK_RATE
        ids += f'"{parkId}",'

        allowNight = 'y' in r['night_parking'].lower()

        data.append((parkId, r['address'], r['car_park_type'], -1, carRate, "", float(r['x_coord']), float(r['y_coord']), allowNight, float(r['gantry_height']), r['type_of_parking_system'], r['free_parking']))
    ids = ids[:-1] + ")"

    return ids, data

def clearId(cursor: mysql.connector.cursor.CursorBase, ids: str):
    query = f"DELETE FROM carpark WHERE carpark_id IN {ids}"
    logging.debug(f"Delete Query: {query}")
    cursor.execute(query)

def insertDB(cursor: mysql.connector.cursor.CursorBase, data: List):
    query = "INSERT INTO carpark (carpark_id, name, carpark_type, lots, car_price, motor_price, x_coord, y_coord, night_parking, gantry_height, parking_system, free_parking_text) \
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s) AS new\
        ON DUPLICATE KEY UPDATE name=new.name, carpark_type=new.carpark_type, lots=new.lots, car_price=new.car_price, motor_price=new.motor_price, x_coord=new.x_coord, y_coord=new.y_coord, night_parking=new.night_parking, gantry_height=new.gantry_height, parking_system=new.parking_system, free_parking_text=new.free_parking_text"
    logging.debug(f"Insert Query: {query}")
    cursor.executemany(query, data)

def getTotalLots(cursor: mysql.connector.cursor.CursorBase):
    query = "SELECT t.total_lots, t.carpark_id FROM carpark_record as t INNER JOIN ( SELECT carpark_id, max(time) as maxTime FROM carpark_record GROUP BY carpark_id ) tm on t.carpark_id = tm.carpark_id and t.time = tm.maxTime"
    cursor.execute(query)
    results = cursor.fetchall()
    return results

def updateTotalLots(cursor: mysql.connector.cursor.CursorBase, totalLots: List):
    query = "UPDATE carpark SET lots=%s WHERE carpark_id=%s"
    cursor.executemany(query, totalLots)

def update():

    db = DB.connectDB()
    cursor = db.cursor()

    DELAY = 0.5
    LIMIT = 100
    i = 0
    while(True):
        logging.info(f"Querying: {i*LIMIT} - {LIMIT}")
        ids, data = getData(LIMIT, i*LIMIT)
        # clearId(cursor, ids) # Use ON DUPLICATE KEY UPDATE instead
        logging.debug(f"Data: {data}")
        insertDB(cursor, data)
               
        logging.info(f"Query Info: {len(data)}")
        if(len(data) < LIMIT):
            logging.info(f"Stopping at: {i*LIMIT + len(data)}")
            break

        i += 1 
    db.commit()

    totalLots = getTotalLots(cursor)
    updateTotalLots(cursor, totalLots)
    db.commit()

    
    cursor.close()
    db.close()

def main():
    update()

if __name__ == "__main__":
    main()