import threading
from flask_pymongo import PyMongo
from flask_socketio import SocketIO
import json
import time
import boto3
import base64
from datetime import datetime
from flask import Flask, request, jsonify

# AWS_ACCESS_KEY = "AKIA3BOLL3RQYEWKMV4B"
# AWS_SECRET_KEY = "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"
# AWS_REGION = "ap-south-1"
# AWS_S3_BUCKET = "tto-asset"

AWS_ACCESS_KEY = "AKIA6GBMCT6VCEUORAMR"
AWS_SECRET_KEY = "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"
AWS_REGION = "us-east-1"
AWS_S3_BUCKET = "tto-asset2"

s3_client = boto3.client('s3', aws_access_key_id=AWS_ACCESS_KEY,
                         aws_secret_access_key=AWS_SECRET_KEY, region_name=AWS_REGION)


def upload_base64_to_s3(base64_data):
    try:
        file_data = base64.b64decode(base64_data.encode('utf-8'))

        current_time = datetime.now().strftime("%Y%m%d%H%M%S")
        filename = f"{current_time}.png"

        s3_client.put_object(
            Body=file_data, Bucket=AWS_S3_BUCKET, Key=filename)

        return filename
    except Exception as e:
        return str(e)

# filename=str(upload_base64_to_s3("SGVsbG8gd29ybGQh"))
# print(filename)


def get_file_data_from_s3(file_key):
    try:
        response = s3_client.get_object(Bucket=AWS_S3_BUCKET, Key=file_key)
        file_data = response['Body'].read()
        return file_data
    except Exception as e:
        print(f"Error getting file data: {e}")
        return None


# print(get_file_data_from_s3(filename))

FinalPlaces = []

app = Flask(__name__)
app.config["MONGO_URI"] = "mongodb://localhost:27017/myDatabase"
app.config['SECRET_KEY'] = 'secret!'
socketio = SocketIO(app)
db = PyMongo(app).db


@app.route('/upload_user_details', methods=['POST'])
def upload_file():
    if (request.method == 'POST'):
        request_data = request.data
        request_data = json.loads(request_data.decode('utf-8'))
        # print(request_data)
        firstName = request_data["firstName"]
        lastName = request_data["lastName"]
        dob = request_data["dob"]
        gender = request_data["gender"]
        # language = request_data["language"]
        phone = request_data["phone"]
        contribution_of_clothes = []
        contribution_of_food = []
        contribution_of_needy = []
        contribution_of_shelter = []

        db.users.insert_one(
            {"firstName": firstName,
             "lastName": lastName,
             "dob": dob,
             "gender": gender,
             #  "language": language,
             "phone": phone,
             "contribution_of_clothes": contribution_of_clothes,
             "contribution_of_food": contribution_of_food,
             "contribution_of_needy": contribution_of_needy,
             "contribution_of_shelter": contribution_of_shelter
             })

        return ""


@app.route('/contribute_food', methods=['POST'])
def contribute_food():
    if (request.method == 'POST'):
        request_data = request.data
        request_data = json.loads(request_data.decode('utf-8'))
        # print(request_data)
        description = request_data["description"]
        phone = request_data["phone"]
        
        image = request_data["image"]
        food_type = request_data["food_type"]
        latitude = request_data["latitude"]
        longitude = request_data["longitude"]
        startDate = request_data["startDate"]
        endDate = request_data["endDate"]
        startTime = request_data["startTime"]
        endTime = request_data["endTime"]

        image_file_name = upload_base64_to_s3(image)
        print(image_file_name)

        db.users.update_one(
            {"phone": phone},
            {"$push": {"contribution_of_food": {
                "type":"food",
                "image_file_name": image_file_name,
                "thumbsUp": 0,
                "thumbsDown": 0,
                "description": description,  "food_type": food_type, "latitude": latitude, "longitude": longitude, "startDate": startDate, "endDate": endDate, "startTime": startTime, "endTime": endTime}}}
        )

        return ""


@app.route('/contribute_clothes', methods=['POST'])
def contribute_clothes():
    if (request.method == 'POST'):
        request_data = request.data
        request_data = json.loads(request_data.decode('utf-8'))
        # print(request_data)
        description = request_data["description"]
        phone = request_data["phone"]
        image = request_data["image"]
        gender = request_data["gender"]
        type_of_clothing = request_data["type_of_clothing"]
        latitude = request_data["latitude"]
        longitude = request_data["longitude"]
        startDate = request_data["startDate"]
        endDate = request_data["endDate"]
        startTime = request_data["startTime"]
        endTime = request_data["endTime"]

        image_file_name = upload_base64_to_s3(image)
        print(image_file_name)

        db.users.update_one(
            {"phone": phone},
            {"$push": {"contribution_of_clothes": {
                "image_file_name": image_file_name,
                "type":"clothes",
                "thumbsUp": 0,
                "thumbsDown": 0,
                "description": description,  "type_of_clothing": type_of_clothing, "gender": gender, "latitude": latitude, "longitude": longitude, "startDate": startDate, "endDate": endDate, "startTime": startTime, "endTime": endTime}}}
        )

        return ""


@app.route('/contribute_shelter', methods=['POST'])
def contribute_shelter():
    if (request.method == 'POST'):
        request_data = request.data
        request_data = json.loads(request_data.decode('utf-8'))
        # print(request_data)
        description = request_data["description"]
        phone = request_data["phone"]
        image = request_data["image"]
        latitude = request_data["latitude"]
        longitude = request_data["longitude"]
        startDate = request_data["startDate"]
        endDate = request_data["endDate"]
        startTime = request_data["startTime"]
        endTime = request_data["endTime"]

        image_file_name = upload_base64_to_s3(image)
        print(image_file_name)

        db.users.update_one(
            {"phone": phone},
            {"$push": {"contribution_of_shelter": {
                "image_file_name": image_file_name,
                "type":"shelter",
                "thumbsUp": 0,
                "thumbsDown": 0,
                "description": description,  "latitude": latitude, "longitude": longitude, "startDate": startDate, "endDate": endDate, "startTime": startTime, "endTime": endTime}}}
        )

        return ""


@app.route('/contribute_needy', methods=['POST'])
def contribute_needy():
    if (request.method == 'POST'):
        request_data = request.data
        request_data = json.loads(request_data.decode('utf-8'))
        # print(request_data)
        description = request_data["description"]
        phone = request_data["phone"]
        help_type = request_data["help_type"]
        image = request_data["image"]
        latitude = request_data["latitude"]
        longitude = request_data["longitude"]
        startDate = request_data["startDate"]
        endDate = request_data["endDate"]
        startTime = request_data["startTime"]
        endTime = request_data["endTime"]

        image_file_name = upload_base64_to_s3(image)
        print(image_file_name)

        db.users.update_one(
            {"phone": phone},
            {"$push": {"contribution_of_needy": {
                "image_file_name": image_file_name,
                "type":"needy",
                "thumbsUp": 0,
                "thumbsDown": 0,
                "description": description,  "help_type": help_type, "latitude": latitude, "longitude": longitude, "startDate": startDate, "endDate": endDate, "startTime": startTime, "endTime": endTime}}}
        )

        return ""


@app.route('/thumbs_up', methods=['POST'])
def thumbs_up():
    if (request.method == 'POST'):
        request_data = request.data
        request_data = json.loads(request_data.decode('utf-8'))
        # print(request_data)

        type = request_data["type"]
        # find the entry in the database and increment the thumbsUp count using attribute like Description,latitide,longitude,image_file_name and its type
        if type == "food":
            description = request_data["description"]
            latitude = request_data["latitude"]
            longitude = request_data["longitude"]
            image_file_name = request_data["image_file_name"]
            db.users.update_one(
                {"contribution_of_food.description": description, "contribution_of_food.image_file_name": image_file_name,
                    "contribution_of_food.latitude": latitude, "contribution_of_food.longitude": longitude},
                {"$inc": {"contribution_of_food.$.thumbsUp": 1}}
            )
        elif type == "clothes":
            description = request_data["description"]
            latitude = request_data["latitude"]
            longitude = request_data["longitude"]
            image_file_name = request_data["image_file_name"]

            db.users.update_one(
                {"contribution_of_clothes.description": description, "contribution_of_clothes.image_file_name": image_file_name,
                    "contribution_of_clothes.latitude": latitude, "contribution_of_clothes.longitude": longitude},
                {"$inc": {"contribution_of_clothes.$.thumbsUp": 1}}
            )

        elif type == "shelter":
            description = request_data["description"]
            latitude = request_data["latitude"]
            longitude = request_data["longitude"]
            image_file_name = request_data["image_file_name"]
            print(description)
            print(latitude)
            print(longitude)
            print(image_file_name)

            db.users.update_one(
                { "contribution_of_shelter.description": description, "contribution_of_shelter.image_file_name": image_file_name,
                    "contribution_of_shelter.latitude": latitude, "contribution_of_shelter.longitude": longitude},
                {"$inc": {"contribution_of_shelter.$.thumbsUp": 1}}
            )
        elif type == "needy":
            description = request_data["description"]
            latitude = request_data["latitude"]
            longitude = request_data["longitude"]
            image_file_name = request_data["image_file_name"]

            db.users.update_one(
                { "contribution_of_needy.description": description, "contribution_of_needy.image_file_name": image_file_name,
                    "contribution_of_needy.latitude": latitude, "contribution_of_needy.longitude": longitude},
                {"$inc": {"contribution_of_needy.$.thumbsUp": 1}}
            )

        return ""


@app.route('/thumbs_down', methods=['POST'])
def thumbs_down():
    if (request.method == 'POST'):
        request_data = request.data
        request_data = json.loads(request_data.decode('utf-8'))
        # print(request_data)
        # phone = request_data["phone"]
        type = request_data["type"]
        # find the entry in the database and increment the thumbsUp count using attribute like Description,latitide,longitude and its type
        if type == "food":
            description = request_data["description"]
            latitude = request_data["latitude"]
            longitude = request_data["longitude"]
            image_file_name = request_data["image_file_name"]
            db.users.update_one(
                { "contribution_of_food.description": description, "contribution_of_food.image_file_name": image_file_name,
                    "contribution_of_food.latitude": latitude, "contribution_of_food.longitude": longitude},
                {"$inc": {"contribution_of_food.$.thumbsDown": 1}}
            )
        elif type == "clothes":
            description = request_data["description"]
            latitude = request_data["latitude"]
            longitude = request_data["longitude"]
            image_file_name = request_data["image_file_name"]

            db.users.update_one(
                {"contribution_of_clothes.description": description, "contribution_of_clothes.image_file_name": image_file_name,
                    "contribution_of_clothes.latitude": latitude, "contribution_of_clothes.longitude": longitude},
                {"$inc": {"contribution_of_clothes.$.thumbsDown": 1}}
            )
        elif type == "shelter":
            description = request_data["description"]
            latitude = request_data["latitude"]
            longitude = request_data["longitude"]
            image_file_name = request_data["image_file_name"]

            db.users.update_one(
                { "contribution_of_shelter.description": description, "contribution_of_shelter.image_file_name": image_file_name,
                    "contribution_of_shelter.latitude": latitude, "contribution_of_shelter.longitude": longitude},
                {"$inc": {"contribution_of_shelter.$.thumbsDown": 1}}
            )
        elif type == "needy":
            description = request_data["description"]
            latitude = request_data["latitude"]
            longitude = request_data["longitude"]
            image_file_name = request_data["image_file_name"]

            db.users.update_one(
                { "contribution_of_needy.description": description, "contribution_of_needy.image_file_name": image_file_name,
                    "contribution_of_needy.latitude": latitude, "contribution_of_needy.longitude": longitude},
                {"$inc": {"contribution_of_needy.$.thumbsDown": 1}}
            )

        return ""


user_name = -1


@app.route('/get_username', methods=['GET', 'POST'])
def GetUserName():
    global user_name
    if (request.method == 'POST'):
        request_data = request.data
        request_data = json.loads(request_data.decode('utf-8'))
        # print(request_data)
        phone = request_data["phone"]

        user = db.users.find({"phone": phone}, {
                             "firstName": 1, "lastName": 1, "_id": 0})

        for item in user:
            print(item)
            user_name = item
            return item
    if (request.method == 'GET'):
        flag = user_name
        user_name = -1

        if flag == -1:
            return "No user found"
        UserName = flag["firstName"] + " " + flag["lastName"]
        return UserName


@app.route('/get_places', methods=['POST', 'GET'])
def get_places():

    if (request.method == 'GET'):

        return FinalPlaces
        pass


def is_between(start_date, end_date, start_time, end_time):
    # Get current date and time
    current_datetime = datetime.now()

    # Convert start and end date strings to datetime objects
    start_datetime = datetime.strptime(
        f"{start_date} {start_time}", "%d/%m/%Y %H:%M")
    end_datetime = datetime.strptime(
        f"{end_date} {end_time}", "%d/%m/%Y %H:%M")

    # Check if current datetime is between start and end datetime
    return start_datetime <= current_datetime <= end_datetime


def getPlaces():
    places = db.users.find({}, {"contribution_of_food": 1, "contribution_of_clothes": 1,
                           "contribution_of_shelter": 1, "contribution_of_needy": 1, "_id": 0})
    currPlaces = {}

    contribution_of_food = []
    contribution_of_clothes = []
    contribution_of_shelter = []
    contribution_of_needy = []
    current_date = datetime.now().strftime('%d/%m/%Y')

    # Get current time in HH:MM format
    current_time = datetime.now().strftime('%H:%M')
    # print(current_date,current_time)
    for place in places:
        # print(place)
        for _ in place["contribution_of_food"]:
            # _["image"] = "o"
            data = get_file_data_from_s3(_["image_file_name"])
            # print(data)
            # with open("image.png", "wb") as f:
            #     f.write(data)
            _["image"] = base64.b64encode(data).decode('utf-8')
            if is_between(_["startDate"], _["endDate"], _["startTime"], _["endTime"]):
                contribution_of_food.append(_)
                # print(_)

        for _ in place["contribution_of_clothes"]:
            # _["image"] = "o"
            data = get_file_data_from_s3(_["image_file_name"])
            _["image"] = base64.b64encode(data).decode('utf-8')
            if is_between(_["startDate"], _["endDate"], _["startTime"], _["endTime"]):
                contribution_of_clothes.append(_)
                # print(_)

        for _ in place["contribution_of_shelter"]:
            # _["image"] = "o"
            data = get_file_data_from_s3(_["image_file_name"])
            _["image"] = base64.b64encode(data).decode('utf-8')
            if is_between(_["startDate"], _["endDate"], _["startTime"], _["endTime"]):
                contribution_of_shelter.append(_)
                # print(_)

        for _ in place["contribution_of_needy"]:
            # _["image"] = "o"
            data = get_file_data_from_s3(_["image_file_name"])
            _["image"] = base64.b64encode(data).decode('utf-8')
            if is_between(_["startDate"], _["endDate"], _["startTime"], _["endTime"]):
                contribution_of_needy.append(_)
                # print(_)

    currPlaces["contribution_of_food"] = (contribution_of_food)
    currPlaces["contribution_of_clothes"] = (contribution_of_clothes)
    currPlaces["contribution_of_shelter"] = (contribution_of_shelter)
    currPlaces["contribution_of_needy"] = (contribution_of_needy)
    global FinalPlaces
    if FinalPlaces != currPlaces:
        FinalPlaces = currPlaces


def Thread_to_fetch():
    while True:
        getPlaces()
        time.sleep(10)
        pass


my_thread = threading.Thread(target=Thread_to_fetch)

my_thread.start()

socketio.run(app, debug=True, port=6174, host='192.168.33.248')
