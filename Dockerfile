FROM balenalib/intel-nuc-debian:latest

ARG SUPERCRONIC_VERSION

USER 0

RUN update-ca-certificates --fresh

RUN install_packages tini

RUN groupadd -r tini && useradd -m -r -g tini tini

### SUPERCRONIC
RUN install_packages curl 
# Latest releases available at https://github.com/aptible/supercronic/releases
ENV SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/v$SUPERCRONIC_VERSION/supercronic-linux-386 \
    SUPERCRONIC=supercronic-linux-386 \
    SUPERCRONIC_SHA1SUM=1b5ebdd122b05cd2ff38b585022f1d909b0146ff

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
