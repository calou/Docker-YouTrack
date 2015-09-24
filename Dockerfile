FROM alpine:3.2

ENV YOUTRACK_VERSION 6.5.16713
ENV JAVA_VERSION_MAJOR 8
ENV JAVA_VERSION_MINOR 60
ENV JAVA_VERSION_BUILD 27
ENV JAVA_PACKAGE       jdk

RUN apk --update add curl ca-certificates tar wget bash && \
    curl -Ls https://circle-artifacts.com/gh/andyshinn/alpine-pkg-glibc/6/artifacts/0/home/ubuntu/alpine-pkg-glibc/packages/x86_64/glibc-2.21-r2.apk > /tmp/glibc-2.21-r2.apk && \
    apk add --allow-untrusted /tmp/glibc-2.21-r2.apk

RUN mkdir /opt && curl -jksSLH "Cookie: oraclelicense=accept-securebackup-cookie"\
  http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-b${JAVA_VERSION_BUILD}/${JAVA_PACKAGE}-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz \
    | tar -xzf - -C /opt &&\
    ln -s /opt/jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR} /opt/jdk &&\
    rm -rf /opt/jdk/*src.zip \
           /opt/jdk/lib/missioncontrol \
           /opt/jdk/lib/visualvm \
           /opt/jdk/lib/*javafx* \
           /opt/jdk/jre/lib/plugin.jar \
           /opt/jdk/jre/lib/ext/jfxrt.jar \
           /opt/jdk/jre/bin/javaws \
           /opt/jdk/jre/lib/javaws.jar \
           /opt/jdk/jre/lib/desktop \
           /opt/jdk/jre/plugin \
           /opt/jdk/jre/lib/deploy* \
           /opt/jdk/jre/lib/*javafx* \
           /opt/jdk/jre/lib/*jfx* \
           /opt/jdk/jre/lib/amd64/libdecora_sse.so \
           /opt/jdk/jre/lib/amd64/libprism_*.so \
           /opt/jdk/jre/lib/amd64/libfxplugins.so \
           /opt/jdk/jre/lib/amd64/libglass.so \
           /opt/jdk/jre/lib/amd64/libgstreamer-lite.so \
           /opt/jdk/jre/lib/amd64/libjavafx*.so \
           /opt/jdk/jre/lib/amd64/libjfx*.so

# Set environment
ENV JAVA_HOME /opt/jdk
ENV PATH ${PATH}:${JAVA_HOME}/bin

WORKDIR /opt/youtrack

RUN mkdir -p /youtrack /opt/youtrack/data /opt/youtrack/backup /opt/youtrack/bin
RUN wget -nv https://download.jetbrains.com/charisma/youtrack-${YOUTRACK_VERSION}.jar -O /opt/youtrack/bin/youtrack.jar
COPY log4j.xml /opt/youtrack/bin/log4j.xml

RUN echo "youtrack-server" >> /etc/hostname 
RUN echo "127.0.0.1 localhost" >> /etc/hosts
RUN echo "127.0.0.1 youtrack-server" >> /etc/hosts

RUN apk del curl wget

EXPOSE 80 
VOLUME ["/opt/youtrack/data/", "/opt/youtrack/backup/"]

ENTRYPOINT ["java", \
  "-Xmx1g", \
  "-XX:MaxMetaspaceSize=250m", \
  "-Duser.home=/opt/youtrack", \
  "-Ddatabase.location=/opt/youtrack/data", \
  "-Ddatabase.backup.location=/opt/youtrack/backup", \
  "-Djavax.net.ssl.trustStore=/etc/ssl/certs/java/cacerts", \
  "-Djavax.net.ssl.trustStorePassword=changeit", \
  "-Djetbrains.youtrack.disableBrowser=true", \
  "-Djetbrains.youtrack.enableGuest=false", \
  "-Djava.awt.headless=true", \
  "-Djetbrains.youtrack.disableCheckForUpdate=true", \
  "-Djava.security.egd=/dev/urandom", \
  "-jar", \
  "/opt/youtrack/bin/youtrack.jar", \
  "80" \
]