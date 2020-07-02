FROM balenalib/intel-nuc-debian:latest

USER 0

RUN update-ca-certificates --fresh

RUN install_packages tini

RUN groupadd -r tini && useradd -r -g tini tini

### SUPERCRONIC
RUN install_packages curl 
ENV SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/v0.1.9/supercronic-linux-amd64 \
    SUPERCRONIC=supercronic-linux-amd64 \
    SUPERCRONIC_SHA1SUM=5ddf8ea26b56d4a7ff6faecdd8966610d5cb9d85

RUN groupadd -r supercronic && usermod -a -G supercronic tini

RUN curl -fsSLO "$SUPERCRONIC_URL" \
 && echo "${SUPERCRONIC_SHA1SUM}  ${SUPERCRONIC}" | sha1sum -c - \
 && chmod 550 "$SUPERCRONIC" \
 && chgrp supercronic "$SUPERCRONIC" \
 && mv "$SUPERCRONIC" "/usr/local/bin/${SUPERCRONIC}" \
 && ln -s "/usr/local/bin/${SUPERCRONIC}" /usr/local/bin/supercronic
RUN echo '@daily echo "still running"' > /opt/crontab \
  && supercronic -test /opt/crontab \
  && chown tini:supercronic /opt/crontab \
  && chmod 440 /opt/crontab
### END SUPERCRONIC

USER tini

ENTRYPOINT  ["tini", "--"]

CMD  ["supercronic", "-json", "/opt/crontab"]
