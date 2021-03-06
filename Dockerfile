FROM alpine:3.13

# ===============
# Alpine packages
# ===============

RUN apk update \
    && apk add --no-cache py3-pip tini openjdk11-jre-headless py3-cryptography py3-lxml py3-psycopg2 \
    && apk add --no-cache --virtual build-deps wget git \
    && mkdir -p /usr/java/latest \
    && ln -sf /usr/lib/jvm/default-jvm/jre /usr/java/latest/jre

# =====
# Jetty
# =====

ARG JETTY_VERSION=9.4.35.v20201120
ARG JETTY_HOME=/opt/jetty
ARG JETTY_BASE=/opt/gluu/jetty
ARG JETTY_USER_HOME_LIB=/home/jetty/lib

# Install jetty
RUN wget -q https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-distribution/${JETTY_VERSION}/jetty-distribution-${JETTY_VERSION}.tar.gz -O /tmp/jetty.tar.gz \
    && mkdir -p /opt \
    && tar -xzf /tmp/jetty.tar.gz -C /opt \
    && mv /opt/jetty-distribution-${JETTY_VERSION} ${JETTY_HOME} \
    && rm -rf /tmp/jetty.tar.gz

# Ports required by jetty
EXPOSE 8080

# ==========
# Jackrabbit
# ==========

# Install Jackrabbit
ARG JACKRABBIT_VERSION=2.20.2
RUN wget -q https://repo1.maven.org/maven2/org/apache/jackrabbit/jackrabbit-webapp/${JACKRABBIT_VERSION}/jackrabbit-webapp-${JACKRABBIT_VERSION}.war -O /tmp/jackrabbit.war \
    && mkdir -p ${JETTY_BASE}/jackrabbit/webapps/jackrabbit \
    && unzip -qq /tmp/jackrabbit.war -d ${JETTY_BASE}/jackrabbit/webapps/jackrabbit \
    && java -jar ${JETTY_HOME}/start.jar jetty.home=${JETTY_HOME} jetty.base=${JETTY_BASE}/jackrabbit --add-to-start=server,deploy,resources,http,http-forwarded,jsp \
    && rm -f /tmp/jackrabbit.war

# Postgres binding
ARG POSTGRES_VERSION=42.2.14
RUN wget -q https://repo1.maven.org/maven2/org/postgresql/postgresql/${POSTGRES_VERSION}/postgresql-${POSTGRES_VERSION}.jar -O ${JETTY_BASE}/jackrabbit/webapps/jackrabbit/WEB-INF/lib/postgresql-${POSTGRES_VERSION}.jar

# ======
# Python
# ======

COPY requirements.txt /app/requirements.txt
RUN pip3 install --no-cache-dir -U pip \
    && pip3 install --no-cache-dir -r /app/requirements.txt \
    && rm -rf /src/pygluu-containerlib/.git

# =======
# Cleanup
# =======

RUN apk del build-deps \
    && rm -rf /var/cache/apk/*

# =======
# License
# =======

RUN mkdir -p /licenses
COPY LICENSE /licenses/

# ====
# misc
# ====

ENV GLUU_MAX_RAM_PERCENTAGE=75.0 \
    GLUU_JAVA_OPTIONS="" \
    GLUU_WAIT_MAX_TIME=300 \
    GLUU_WAIT_SLEEP_DURATION=10 \
    GLUU_JACKRABBIT_CLUSTER=false \
    GLUU_JACKRABBIT_POSTGRES_USER=postgres \
    GLUU_JACKRABBIT_POSTGRES_PASSWORD_FILE=/etc/gluu/conf/postgres_password \
    GLUU_JACKRABBIT_POSTGRES_HOST=localhost \
    GLUU_JACKRABBIT_POSTGRES_PORT=5432 \
    GLUU_JACKRABBIT_POSTGRES_DATABASE=jackrabbit \
    GLUU_JACKRABBIT_ADMIN_ID=admin \
    GLUU_JACKRABBIT_ADMIN_PASSWORD_FILE=/etc/gluu/conf/jackrabbit_admin_password

LABEL name="Jackrabbit" \
    maintainer="Gluu Inc. <support@gluu.org>" \
    vendor="Gluu Federation" \
    version="4.2.3" \
    release="03" \
    summary="Jackrabbit" \
    description="A fully conforming implementation of the Content Repository for Java Technology API (JCR)"

RUN mkdir -p /deploy /opt/webdav /etc/gluu/conf
COPY static/jackrabbit /opt/jackrabbit/
COPY static/jetty/web.xml ${JETTY_BASE}/jackrabbit/webapps/jackrabbit/WEB-INF/
COPY static/jetty/protectedHandlersConfig.xml ${JETTY_BASE}/jackrabbit/webapps/jackrabbit/WEB-INF/
COPY static/jetty/jackrabbit.xml ${JETTY_BASE}/jackrabbit/webapps/
COPY templates /app/templates
COPY scripts /app/scripts
RUN chmod +x /app/scripts/entrypoint.sh

ENTRYPOINT ["tini", "-e", "143", "-g", "--"]
CMD ["sh", "/app/scripts/entrypoint.sh"]
