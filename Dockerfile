
FROM tomcat:11.0-jdk21-temurin-noble

ENV CATALINA_HOME=/usr/local/tomcat

RUN rm -rf "$CATALINA_HOME/webapps/ROOT"

COPY . /tmp/grievance-app/

RUN mkdir -p "$CATALINA_HOME/webapps/ROOT" \
    && cp -a /tmp/grievance-app/. "$CATALINA_HOME/webapps/ROOT/" \
    && rm -rf "$CATALINA_HOME/webapps/ROOT/src" \
               "$CATALINA_HOME/webapps/ROOT/database" \
               "$CATALINA_HOME/webapps/ROOT/Dockerfile" \
               "$CATALINA_HOME/webapps/ROOT/render-entrypoint.sh" \
    && mkdir -p "$CATALINA_HOME/webapps/ROOT/WEB-INF/classes" \
    && find "$CATALINA_HOME/webapps/ROOT/WEB-INF/classes" -name '*.class' -delete \
    && javac -encoding UTF-8 \
       -cp "$CATALINA_HOME/lib/servlet-api.jar:$CATALINA_HOME/webapps/ROOT/WEB-INF/lib/mysql-connector-j-26.7.0.jar" \
       -d "$CATALINA_HOME/webapps/ROOT/WEB-INF/classes" \
       $(find /tmp/grievance-app/src -name '*.java') \
    && rm -rf /tmp/grievance-app \
    && mkdir -p /var/data/uploads

COPY render-entrypoint.sh /usr/local/bin/render-entrypoint.sh

RUN sed -i 's/\r$//' /usr/local/bin/render-entrypoint.sh \
    && chmod +x /usr/local/bin/render-entrypoint.sh

EXPOSE 10000

ENTRYPOINT ["/usr/local/bin/render-entrypoint.sh"]