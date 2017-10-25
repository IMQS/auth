FROM alpine:3.5
RUN mkdir -p /etc/imqsbin
RUN mkdir -p /var/log/imqs/
RUN mkdir -p /var/imqs/secrets
COPY bin/imqsauth /opt/imqsauth
EXPOSE 80
ENTRYPOINT ["/opt/imqsauth"]

