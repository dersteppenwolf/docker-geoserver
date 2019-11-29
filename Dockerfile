FROM dersteppen/docker-gdal-openjdk:gdal_3.0.2_java_11.0.5
LABEL maintainer="juan@gkudos.com"

###########################################################################################################
ARG GS_MINOR_VERSION=2.16
ARG GS_VERSION=2.16.1
ARG PG_JDBC_JAR_NAME=postgresql-42.2.8.jar
ARG OLD_PG_JDBC_JAR_NAME=postgresql-42.2.5.jar
ARG GITLAB_GEOSERVER_DATA=./build/geoserver_data

# Environment variables Database JNDI Config 
ENV  DB_ENVIRONMENT=dev

# Environment variables tomcat
ENV TOMCAT_MAJOR=9 \
    TOMCAT_VERSION=9.0.29 \
    CATALINA_HOME=/opt/tomcat \
    GEOSERVER_VERSION=$GS_VERSION \
    MARLIN_TAG=0_9_3 \
    MARLIN_VERSION=0.9.3 \
    GEOSERVER_DATA_DIR=/opt/geoserver_data/ \
    GEOSERVER_LIB_DIR=$CATALINA_HOME/webapps/geoserver/WEB-INF/lib/

WORKDIR /tmp
# https://wiki.alpinelinux.org/wiki/Fonts
RUN apk add fontconfig ttf-dejavu

#   \
#     apk --no-cache add msttcorefonts-installer  && \
#     update-ms-fonts && \
#     fc-cache -f

###########################################################################################################
## Tomcat
RUN curl --retry 10  -jkSL -o /tmp/apache-tomcat.tar.gz http://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
    gunzip /tmp/apache-tomcat.tar.gz && \
    tar -C /opt -xf /tmp/apache-tomcat.tar && \
    mv /opt/apache-tomcat-$TOMCAT_VERSION $CATALINA_HOME   && \
    rm -rf $CATALINA_HOME/webapps/*     

###########################################################################################################
# install geoserver
RUN curl --retry 10  -jkSL -o /tmp/geoserver.zip http://managedway.dl.sourceforge.net/project/geoserver/GeoServer/$GEOSERVER_VERSION/geoserver-$GEOSERVER_VERSION-war.zip && \
    unzip geoserver.zip geoserver.war -d $CATALINA_HOME/webapps && \
    mkdir -p $CATALINA_HOME/webapps/geoserver && \
    unzip -q $CATALINA_HOME/webapps/geoserver.war -d $CATALINA_HOME/webapps/geoserver && \
    rm $CATALINA_HOME/webapps/geoserver.war && \
    mkdir -p $GEOSERVER_DATA_DIR

WORKDIR /tmp

# # install java advanced imaging
# RUN wget --tries=100 https://download.java.net/media/jai/builds/release/1_1_3/jai-1_1_3-lib-linux-amd64.tar.gz && \
#     wget --tries=100 https://download.java.net/media/jai-imageio/builds/release/1.1/jai_imageio-1_1-lib-linux-amd64.tar.gz && \
#     gunzip -c jai-1_1_3-lib-linux-amd64.tar.gz | tar xf - && \
#     gunzip -c jai_imageio-1_1-lib-linux-amd64.tar.gz | tar xf - && \
#     # ls  -lah /tmp/    \
#     ls -lah $JAVA_HOME/lib    \
#     mv /tmp/jai-1_1_3/lib/*.jar $JAVA_HOME/jre/lib/ext/ && \
#     mv /tmp/jai-1_1_3/lib/*.so $JAVA_HOME/jre/lib/amd64/ && \
#     mv /tmp/jai_imageio-1_1/lib/*.jar $JAVA_HOME/jre/lib/ext/ && \
#     mv /tmp/jai_imageio-1_1/lib/*.so $JAVA_HOME/jre/lib/amd64/

# uninstall JAI default installation from geoserver to avoid classpath conflicts
# see http://docs.geoserver.org/latest/en/user/production/java.html#install-native-jai-and-imageio-extensions
# WORKDIR $GEOSERVER_LIB_DIR
# RUN rm jai_core-*jar jai_imageio-*.jar jai_codec-*.jar

# install marlin renderer
RUN curl --retry 10 -jkSL -o $CATALINA_HOME/lib/marlin.jar https://github.com/bourgesl/marlin-renderer/releases/download/v$MARLIN_TAG/marlin-$MARLIN_VERSION-Unsafe.jar && \
     curl --retry 10 -jkSL -o $CATALINA_HOME/lib/marlin-sun-java2d.jar https://github.com/bourgesl/marlin-renderer/releases/download/v$MARLIN_TAG/marlin-$MARLIN_VERSION-Unsafe-sun-java2d.jar

###########################################################################################################
# Geoserver extensions : Download the predefined GS plugins for this image

ENV EXTENSIONS_PATH=/tmp/extensions/
RUN mkdir -p $EXTENSIONS_PATH

# Vector tiles https://docs.geoserver.org/latest/en/user/extensions/vectortiles/index.html
ARG EXT_NAME=vectortiles
ARG EXT_ZIP_NAME=geoserver-$GEOSERVER_VERSION-$EXT_NAME-plugin.zip

RUN curl --retry 10 -jkSL -o $EXT_ZIP_NAME https://sourceforge.net/projects/geoserver/files/GeoServer/$GEOSERVER_VERSION/extensions/$EXT_ZIP_NAME    &&  \
    unzip ./$EXT_ZIP_NAME -d  $EXTENSIONS_PATH && \
    mv $EXTENSIONS_PATH*.jar $CATALINA_HOME/webapps/geoserver/WEB-INF/lib/ 
    


# Image Mosaic JDBC https://docs.geoserver.org/latest/en/user/data/raster/imagemosaicjdbc.html
ARG EXT_NAME=imagemosaic-jdbc
ARG EXT_ZIP_NAME=geoserver-$GEOSERVER_VERSION-$EXT_NAME-plugin.zip

RUN curl --retry 10 -jkSL -o $EXT_ZIP_NAME https://sourceforge.net/projects/geoserver/files/GeoServer/$GEOSERVER_VERSION/extensions/$EXT_ZIP_NAME    &&  \
    unzip ./$EXT_ZIP_NAME -d  $EXTENSIONS_PATH && \
    mv $EXTENSIONS_PATH*.jar $CATALINA_HOME/webapps/geoserver/WEB-INF/lib/ 

# CSS https://docs.geoserver.org/latest/en/user/styling/css/index.html
ARG EXT_NAME=css
ARG EXT_ZIP_NAME=geoserver-$GEOSERVER_VERSION-$EXT_NAME-plugin.zip

RUN curl --retry 10 -jkSL -o $EXT_ZIP_NAME https://sourceforge.net/projects/geoserver/files/GeoServer/$GEOSERVER_VERSION/extensions/$EXT_ZIP_NAME    &&  \
    unzip ./$EXT_ZIP_NAME -d  $EXTENSIONS_PATH && \
    mv $EXTENSIONS_PATH*.jar $CATALINA_HOME/webapps/geoserver/WEB-INF/lib/ 

# Ysld https://docs.geoserver.org/stable/en/user/styling/ysld/index.html
ARG EXT_NAME=ysld
ARG EXT_ZIP_NAME=geoserver-$GEOSERVER_VERSION-$EXT_NAME-plugin.zip

RUN curl --retry 10 -jkSL -o $EXT_ZIP_NAME https://sourceforge.net/projects/geoserver/files/GeoServer/$GEOSERVER_VERSION/extensions/$EXT_ZIP_NAME    &&  \
    unzip ./$EXT_ZIP_NAME -d  $EXTENSIONS_PATH && \
    mv $EXTENSIONS_PATH*.jar $CATALINA_HOME/webapps/geoserver/WEB-INF/lib/ 

# OGR WFS  https://docs.geoserver.org/stable/en/user/extensions/ogr.html
ARG EXT_NAME=ogr-wfs
ARG EXT_ZIP_NAME=geoserver-$GEOSERVER_VERSION-$EXT_NAME-plugin.zip

RUN curl --retry 10 -jkSL -o $EXT_ZIP_NAME https://sourceforge.net/projects/geoserver/files/GeoServer/$GEOSERVER_VERSION/extensions/$EXT_ZIP_NAME   && \
    unzip ./$EXT_ZIP_NAME -d  $EXTENSIONS_PATH && \
    mv $EXTENSIONS_PATH*.jar $CATALINA_HOME/webapps/geoserver/WEB-INF/lib/ 

# OGR WPS https://docs.geoserver.org/stable/en/user/extensions/ogr.html#ogr-based-wps-output-format
ARG EXT_NAME=ogr-wps
ARG EXT_ZIP_NAME=geoserver-$GEOSERVER_VERSION-$EXT_NAME-plugin.zip

RUN curl --retry 10 -jkSL -o $EXT_ZIP_NAME https://sourceforge.net/projects/geoserver/files/GeoServer/$GEOSERVER_VERSION/extensions/$EXT_ZIP_NAME   && \
    unzip -o ./$EXT_ZIP_NAME -d  $EXTENSIONS_PATH && \
    mv $EXTENSIONS_PATH*.jar $CATALINA_HOME/webapps/geoserver/WEB-INF/lib/ 

# WPS https://docs.geoserver.org/latest/en/user/services/wps/index.html
ARG EXT_NAME=wps
ARG EXT_ZIP_NAME=geoserver-$GEOSERVER_VERSION-$EXT_NAME-plugin.zip

RUN curl --retry 10 -jkSL -o $EXT_ZIP_NAME https://sourceforge.net/projects/geoserver/files/GeoServer/$GEOSERVER_VERSION/extensions/$EXT_ZIP_NAME    &&  \
    unzip ./$EXT_ZIP_NAME -d  $EXTENSIONS_PATH && \
    mv $EXTENSIONS_PATH*.jar $CATALINA_HOME/webapps/geoserver/WEB-INF/lib/ 

#RUN echo https://sourceforge.net/projects/geoserver/files/GeoServer/$GEOSERVER_VERSION/extensions/$EXT_ZIP_NAME

###########################################################################################################
# Community extensions 

# Geopackage  https://docs.geoserver.org/stable/en/user/community/geopkg/index.html
ARG EXT_NAME=geopkg
ARG EXT_ZIP_NAME=geoserver-$GS_MINOR_VERSION-SNAPSHOT-$EXT_NAME-plugin.zip

# RUN echo  https://build.geoserver.org/geoserver/$GS_MINOR_VERSION.x/community-latest/$EXT_ZIP_NAME 

RUN curl --retry 10 -jkSL -o $EXT_ZIP_NAME https://build.geoserver.org/geoserver/$GS_MINOR_VERSION.x/community-latest/$EXT_ZIP_NAME  && \
    unzip -o ./$EXT_ZIP_NAME -d  $EXTENSIONS_PATH && \
    mv $EXTENSIONS_PATH*.jar $CATALINA_HOME/webapps/geoserver/WEB-INF/lib/ 

###########################################################################################################
# JDBC Download latest to tomcat lib and delete the driver included by default in geoserver 
RUN curl --retry 10 -jkSL -o $PG_JDBC_JAR_NAME https://jdbc.postgresql.org/download/$PG_JDBC_JAR_NAME  && \
    mv $PG_JDBC_JAR_NAME $CATALINA_HOME/lib/  && \
    rm $CATALINA_HOME/webapps/geoserver/WEB-INF/lib/$OLD_PG_JDBC_JAR_NAME
###########################################################################################################
# ENABLE CORS:  add web.xml with CORS enabled
COPY web-cors-enabled.xml /opt/web-cors-enabled.xml
RUN echo "Enabling CORS for GeoServer"  &&  \
    cp /opt/web-cors-enabled.xml $CATALINA_HOME/webapps/geoserver/WEB-INF/web.xml
###########################################################################################################
# Postgresql JNDI  Conf
COPY tomcat/conf/$DB_ENVIRONMENT/context.xml /opt/context.xml
RUN echo "Enabling Postgresql JNDI Config for GeoServer"  &&  \
    cp /opt/context.xml $CATALINA_HOME/conf/context.xml
###########################################################################################################
COPY ogr2ogr.xml $GEOSERVER_DATA_DIR
###########################################################################################################
# cleanup
RUN apk del curl && \
    rm -rf /tmp/* /var/cache/apk/*
###########################################################################################################
# JVM Parameters    
# -Xbootclasspath/a:$CATALINA_HOME/lib/marlin.jar \
# -Xbootclasspath/p:$CATALINA_HOME/lib/marlin-sun-java2d.jar  \

# see http://docs.geoserver.org/stable/en/user/production/container.html

ENV CATALINA_OPTS "-Djava.awt.headless=true -server -Xms1024M -Xmx4g \
  -Dsun.java2d.renderer=org.marlin.pisces.MarlinRenderingEngine \
 -DGEOWEBCACHE_CACHE_DIR=/opt/geoserver_tiles \
 -DENABLE_JSONP=true \
 -Dfile.encoding=UTF-8 \
 -Dorg.geotools.coverage.jaiext.enabled=true \
 -Dorg.geotools.referencing.forceXY=true \
 -Dhttps.protocols=TLSv1,TLSv1.1,TLSv1.2 \
 -XX:SoftRefLRUPolicyMSPerMB=36000 \
 -XX:+UnlockExperimentalVMOptions \
 -XX:+UseParallelGC  \
 -XX:PerfDataSamplingInterval=500  \
 -XX:NewRatio=2  \
 -XX:+UseContainerSupport "

## Tomcat
EXPOSE 8080

ENTRYPOINT $CATALINA_HOME/bin/catalina.sh run

WORKDIR /opt