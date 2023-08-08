import math
import logging
from re import search
import time
import DB
import datetime
import json

import SVY21

import numpy as np

from flask import Flask, abort, render_template, send_from_directory, redirect, request, jsonify, Response

app = Flask(__name__)
app.config['SECRET_KEY'] = "secret!"

db = None

# Log in with credentials
'''
@app.route("/loginCred")
def loginCredentials():
    pass
'''

# Log in with session token 
'''
@app.route("/loginToken)
def loginToken():
    pass
'''

# Car Park Search
@app.route("/searchCarPark", methods=["POST"])
def searchCarPark():
    if(request.method == "POST"):
        reqJson = request.json
        print(reqJson)

        long = reqJson['location']['longitude']
        lat = reqJson['location']['latitude']

        # Date Time Check
        try:
            searchTime = datetime.datetime.strptime(reqJson['time'], "%Y-%m-%d %H:%M:%S")
        except ValueError:
            print(f"Time Format Error: {reqJson['time']}")
            abort(400)

        startWeek = searchTime - datetime.timedelta(days=searchTime.weekday(), hours=searchTime.hour, minutes=searchTime.minute, seconds=searchTime.second)
        dHour = round((searchTime - startWeek).total_seconds() / (60*60), 4)

        maxDist = reqJson['max_distance']
        maxRate = reqJson['max_rate']
        maxCount = reqJson['count']

        # Get data
        converter = SVY21.SVY21()
        y,x = converter.computeSVY21(lat, long)

        db = DB.connectDB()
        query = f"SELECT * FROM \
                ( SELECT *, sqrt(power({x}-x_coord,2) + power({y}-y_coord,2)) as distance FROM carpark ) \
                 as T WHERE distance <= {1000*maxDist:.04f} ORDER BY distance ASC"
        #print(query)
        cursor = db.cursor()
        cursor.execute(query)
        results = cursor.fetchall()
        #print(results)

        # Predict
        predictTotal = 12
        predictPre = 4
        predictPost = predictTotal - predictPre - 1

        data = []
        count = 0

        for id, addr, lotType, lot, priceStr, carX, carY, gantryHeight, nightParking, parkingSystem, _mPrice, freeParkText, distance in results:
            
            # Process Price
            priceObj = json.loads(priceStr)
            if(type(priceObj) is list):
                defPrice = -1
                price = -1
                for c in priceObj:
                    cRange = c["range"]
                    if(len(cRange) == 2):
                        if(dHour >= cRange[0] and dHour <= cRange[1]):
                            price = c["rate"] / c["period"]
                    else:
                        defPrice = c["rate"] / c["period"]

                if(price < 0):
                    price = defPrice

            else:
                # Contains 1 -> default only
                price = priceObj["rate"] / priceObj["period"]

            if(price > maxRate):
                continue

            count += 1
            if(count > maxCount):
                break

            # Predictions
            predictions = []

            #query = f"SELECT * FROM carpark_pred WHERE carpark_id = {id} and "
            preTime = datetime.datetime(year=searchTime.year, month=searchTime.month, day=searchTime.day, hour=searchTime.hour) - datetime.timedelta(hours=predictPre)
            curTime = preTime

            lotRecord=True
            predCount = 0
            while(predCount < predictTotal):
                curStr = datetime.datetime.strftime(curTime, "%Y-%m-%d %H:%M:%S")
                postTime = curTime + datetime.timedelta(hours=1)
                postStr = datetime.datetime.strftime(postTime, "%Y-%m-%d %H:%M:%S")


                if(lotRecord):
                    query = f'SELECT ROUND(AVG(available_lots)) FROM carpark_record WHERE carpark_id = "{id}" and carpark_record.time >= "{curStr}" and carpark_record.time < "{postStr}"'
                else:
                    query = f'SELECT ROUND(AVG(carpark_pred.pred_lots)) FROM carpark_pred WHERE carpark_id = "{id}" and carpark_pred.time >= "{curStr}" and carpark_pred.time < "{postStr}"'
                
                #print(f"Record/Predict: {query}")
                cursor.execute(query)
                recResult = cursor.fetchall()
                if(len(recResult) == 0 or recResult[0][0] is None):
                    if(lotRecord):
                        lotRecord=False
                        continue
                    else:
                        # No data
                        predLots = -1
                else:
                    predLots = recResult[0][0]

                if(curTime.hour == 0):
                    hrStr = "12a"
                elif(curTime.hour < 12):
                    hrStr = f"{curTime.hour}a"
                elif(curTime.hour == 12):
                    hrStr = f"12p"
                else:
                    hrStr = f"{curTime.hour-12}p"

                predictions.append(
                    {
                        "time": hrStr,
                        "lot_count": int(predLots)
                    }
                )

                curTime = postTime
                predCount += 1

            # Process coordinate
            lat, long = converter.computeLatLon(float(carY), float(carX))

            # Process address
            addr = addr.replace("BLK","").replace("BLOCK","").strip()

            data.append({
                "id": id,
                "address": addr,
                "rate": price,
                "lat": lat,
                "long": long,
                "distance": distance/1000,
                "predictions": predictions,
                "gantry_height": gantryHeight,
                "total_lots": lot,
                "parking_system": parkingSystem,
                "car_park_type": lotType, 
                "free_parking_text": freeParkText,
                "night_parking": bool(nightParking)
            })

        cursor.close()
        db.close()

        return jsonify({'results':data})
    else:
        print(request.method)

def main():

    app.run(host="0.0.0.0", port="8001", debug=True)

if __name__ == "__main__":
    main()