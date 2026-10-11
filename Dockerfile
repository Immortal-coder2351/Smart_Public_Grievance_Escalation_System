FROM tomcat:11.0-jdk21-temurin-noble

ENV CATALINA_HOME=/usr/local/tomcat \
    PORT=10000 \
    DB_NAME=smart_grievance \
    UPLOAD_DIR=/var/data/uploads

COPY render-entrypoint.sh /usr/local/bin/render-entrypoint.sh
COPY . /tmp/smart-grievance-source/

RUN chmod +x /usr/local/bin/render-entrypoint.sh \
    && apt-get update \
    && apt-get install -y --no-install-recommends curl \
    && rm -rf "$CATALINA_HOME/webapps/ROOT" \
    && mkdir -p "$CATALINA_HOME/webapps/ROOT/WEB-INF/classes" \
    && cp -a /tmp/smart-grievance-source/. "$CATALINA_HOME/webapps/ROOT/" \
    && rm -rf "$CATALINA_HOME/webapps/ROOT/WEB-INF/classes" \
    && mkdir -p "$CATALINA_HOME/webapps/ROOT/WEB-INF/classes" \
    && curl -fsSL "https://repo.maven.apache.org/maven2/com/mysql/mysql-connector-j/9.4.0/mysql-connector-j-9.4.0.jar" \
       -o "$CATALINA_HOME/webapps/ROOT/WEB-INF/lib/mysql-connector-j.jar" \
    && javac -encoding UTF-8 \
       -cp "$CATALINA_HOME/lib/servlet-api.jar:$CATALINA_HOME/webapps/ROOT/WEB-INF/lib/mysql-connector-j.jar" \
       -d "$CATALINA_HOME/webapps/ROOT/WEB-INF/classes" \
       $(find "$CATALINA_HOME/webapps/ROOT/src" -name '*.java') \
    && rm -rf /tmp/smart-grievance-source \
    && apt-get purge -y --auto-remove curl \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p "$UPLOAD_DIR"

EXPOSE 10000

ENTRYPOINT ["/usr/local/bin/render-entrypoint.sh"]
