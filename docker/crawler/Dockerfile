FROM python:3.6-alpine

RUN apk add git

ENV MONGO crawler_db
ENV MONGO_PORT 27017
ENV RMQ_HOST rabbitmq
ENV RMQ_QUEUE queue
ENV RMQ_USERNAME guest
ENV RMQ_PASSWORD guest
ENV CHECK_INTERVAL 5
ENV EXCLUDE_URLS='.*github.com'


ENV APP_HOME /app
RUN git clone https://github.com/express42/search_engine_crawler.git $APP_HOME
WORKDIR $APP_HOME
RUN pip install -r requirements.txt

CMD python -u ./crawler/crawler.py https://vitkhab.github.io/search_engine_test_site/
