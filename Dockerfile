FROM openjdk:8-jdk-alpine

WORKDIR /zookeeper

ARG MIRROR=http://mirror.vorboss.net/apache
ARG VERSION=3.4.9
ARG SIGN=http://www-eu.apache.org/dist
ARG EXHIBITOR_VERSION=1.5.6

LABEL name="zookeeper" version=$VERSION

COPY ["pom.xml", "./"]

RUN set -ex && \
  apk --no-cache --update --repository https://dl-3.alpinelinux.org/alpine/edge/community/ add \
    bash \
    ca-certificates \
    gnupg \
    maven \
    tar \
    wget && \
\
# Zookeeper
  wget -q $SIGN/zookeeper/zookeeper-$VERSION/zookeeper-$VERSION.tar.gz.asc && \
  wget -q --show-progress --progress=bar:force $MIRROR/zookeeper/zookeeper-$VERSION/zookeeper-$VERSION.tar.gz && \
  wget -q -O - http://www-eu.apache.org/dist/zookeeper/KEYS | gpg --import && \
  gpg --verify zookeeper-$VERSION.tar.gz.asc && \
  tar -zxf zookeeper-$VERSION.tar.gz --strip=1 && \
  rm zookeeper-$VERSION.tar.gz* && \
\
# Exhibitor
  mvn -Dexhibitor-version=$EXHIBITOR_VERSION -Dmaven.repo.local=/zookeeper/target/repo package && \
  mv target/exhibitor-$EXHIBITOR_VERSION.jar exhibitor.jar && \
  rm -fr recipes contrib dist-maven docs src target pom.xml && \
  apk del wget gnupg maven && \
  rm -rf /var/cache/apk/*

RUN set -e && \
  echo "zookeeper-install-directory=/zookeeper" >> exhibitor.properties && \
  echo "zookeeper-data-directory=/zookeeper/zk-data" >> exhibitor.properties && \
  echo "zookeeper-log-directory=/zookeeper/zk-log" >> exhibitor.properties && \
  echo "auto-manage-instances=1" >> exhibitor.properties

EXPOSE 2181 2888 3888 8080

COPY docker-entrypoint.sh /usr/local/bin

ENTRYPOINT ["docker-entrypoint.sh"]
