# Welcome to Cloud Functions for Firebase for Python!
# To get started, simply uncomment the below code or create your own.
# Deploy with `firebase deploy`

from firebase_functions import scheduler_fn, db_fn, https_fn, options
from firebase_admin import initialize_app, db

app = initialize_app()
#
#
# @https_fn.on_request()
# def on_request_example(req: https_fn.Request) -> https_fn.Response:
#     return https_fn.Response("Hello world!")

def addItemToDatabase(item):
    ref = db.reference('/items')
    ref.push(item)
    