# USAGE:
# Dev Env
# docker build -t dynamodb:dev .
# docker run -it --rm -p 8058:8058 dynamodb:dev

# Test Env
# docker build -t dynamodb:test .
# docker run -it --rm -p 8059:8059 dynamodb:test

FROM kraynezero/aws-dynamodb-local:latest

COPY bootstrap-dynamodb.sh /opt/dynamodb-local

RUN mkdir -p /bootstrap

EXPOSE 8058
EXPOSE 8059