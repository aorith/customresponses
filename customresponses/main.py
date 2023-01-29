from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles

from customresponses.routers import api_v1, views

app = FastAPI()
app.mount("/static", StaticFiles(directory="files/static"), name="static")
app.include_router(views.router)
app.include_router(api_v1.router)
