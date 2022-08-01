FROM python:3.6-alpine

RUN apk add git

ENV MONGO crawler_db
ENV MONGO_PORT 27017


ENV APP_HOME /app
COPY . $APP_HOME
WORKDIR $APP_HOME
RUN pip install -r requirements.txt

WORKDIR $APP_HOME/ui
ENTRYPOINT FLASK_APP=ui.py gunicorn ui:app -b 0.0.0.0
