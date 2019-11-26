# docker-geoserver

Alpine based docker image for geoserver using Tomcat 9.x,  Gdal 3.x and OpenJDK  11.x


## Supported tags

* `2.16.0_tomcat_9.0.27_v1.0.0`,  `latest`

## Description

* Alpine based Docker image (see    [The 3 Biggest Wins When Using Alpine as a Base Docker Image ](https://nickjanetakis.com/blog/the-3-biggest-wins-when-using-alpine-as-a-base-docker-image)   )
* Includes Gdal 3.x and Java 11 from [docker-gdal-openjdk](https://github.com/dersteppenwolf/docker-gdal-openjdk)  
* Uses Tomcat 11.x
* Includes the Postgresql Jdbc driver to be used in JNDI datasources.
* Default JVM options optimized for production https://docs.geoserver.org/stable/en/user/production/container.html
* Excludes Geoserver's default example data

### Advanced options

* Cors
* JNDI datasource. See  [context.xml](tomcat/conf/dev/context.xml)    
* OGR based output formats.  See    [ogr2ogr.xml](ogr2ogr.xml )

### Included extensions

Official: 

* CSS https://docs.geoserver.org/latest/en/user/styling/css/index.html
* Image Mosaic JDBC https://docs.geoserver.org/latest/en/user/data/raster/imagemosaicjdbc.html
* OGR based WFS Output Format (https://docs.geoserver.org/stable/en/user/extensions/ogr.html)
* OGR WPS https://docs.geoserver.org/stable/en/user/extensions/ogr.html#ogr-based-wps-output-format
* Vector tiles https://docs.geoserver.org/latest/en/user/extensions/vectortiles/index.html
* WPS https://docs.geoserver.org/latest/en/user/services/wps/index.html
* Ysld https://docs.geoserver.org/stable/en/user/styling/ysld/index.html


Community:

* Geopackage  https://docs.geoserver.org/stable/en/user/community/geopkg/index.html


TODO:

* libjpeg-turbo Map Encoder Extension https://docs.geoserver.org/stable/en/user/extensions/libjpeg-turbo/index.html
* Geofence https://docs.geoserver.org/stable/en/user/extensions/geofence-server/index.html
* Control flow (?) https://docs.geoserver.org/latest/en/user/extensions/controlflow/index.html




## Usage example

Pull image:

    docker pull dersteppen/docker-geoserver

Execute image:

    docker run -p 18080:8080 dersteppen/docker-geoserver:2.16.0_tomcat_9.0.27_v1.0.0

Execute in detached mode:

    # delete previous image
    docker rm -f my-geoserver

    docker run --name my-geoserver   -p 18080:8080  -d dersteppen/docker-geoserver:2.16.0_tomcat_9.0.27_v1.0.0

    # fetch some  some logs...
    docker logs -f my-geoserver 

    # connect to container (verify contents...)
    docker exec -it my-geoserver  /bin/ash

Open geoserver: http://localhost:18080/geoserver

## Customization

Mount existing geoserver data directory from host: 

    sudo docker run --name my-geoserver -v $HOME/geoserver_data:/opt/geoserver_data/  -p 18080:8080  -d dersteppen/docker-geoserver:2.16.0_tomcat_9.0.27_v1.0.0

Storing data on the host rather than the container:

    TODO

Replace context.xml for JNDI:

    TODO

Override JVM Options:

    TODO



## Build Image

Build:

```bash
docker build -t dersteppen/docker-geoserver .
docker images dersteppen/docker-geoserver
docker tag xxxx dersteppen/docker-geoserver:2.16.0_tomcat_9.0.27_v1.0.0
```

Push image to dockerhub:

    docker push dersteppen/docker-geoserver:2.16.0_tomcat_9.0.27_v1.0.0

## Related images

* meggsimum https://github.com/meggsimum/geoserver-docker 
* kartoza https://github.com/kartoza/docker-geoserver


## Contributing

You are invited to contribute new features, fixes, or updates, large or small; we are always thrilled to receive pull requests, and do our best to process them as fast as we can.

## License

This project is published under [MIT License](LICENSE).
