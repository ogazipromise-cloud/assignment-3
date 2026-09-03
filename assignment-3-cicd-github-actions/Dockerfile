FROM alpine:3.22

RUN apk add --no-cache\
    bash\ 
    iputils \
    iproute2 \
    procps

WORKDIR /app

COPY app/app.sh /app/app.sh

RUN chmod +x /app/app.sh

ENTRYPOINT ["/app/app.sh"]

CMD ["help"]
