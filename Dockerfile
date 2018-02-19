FROM imqs/ubuntu-base
RUN mkdir -p /etc/imqsbin
RUN mkdir -p /var/log/imqs/
RUN mkdir -p /var/imqs/secrets
COPY bin/imqsauth /opt/imqsauth
ENV IMQS_CONTAINER=true
EXPOSE 80
ENTRYPOINT ["/opt/imqsauth"]

