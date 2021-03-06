FROM klaemo/couchdb-base

MAINTAINER Clemens Stolle klaemo@fastmail.fm + Jon Richter post@jonrichter.de

# Get the source
RUN cd /opt && \
 wget http://apache.openmirror.de/couchdb/source/1.6.0/apache-couchdb-1.6.0.tar.gz && \
 tar xzf /opt/apache-couchdb-1.6.0.tar.gz

# build couchdb
RUN cd /opt/apache-couchdb-* && ./configure && make && make install

# install github.com/visionmedia/mon v1.2.3
RUN (mkdir /tmp/mon && cd /tmp/mon && curl -L# https://github.com/visionmedia/mon/archive/1.2.3.tar.gz | tar zx --strip 1 && make install)

# cleanup
# RUN apt-get remove -y build-essential wget curl && \
#  apt-get autoremove -y && apt-get clean -y && \
#  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /opt/apache-couchdb-*

### GeoCouch Setup
## With inspiration from https://github.com/rstiller/dockerfiles/blob/master/geocouch/geocouch.tpl

ENV COUCH_SRC /opt/apache-couchdb-1.6.0/src/couchdb/

RUN cd /opt && \
 wget https://github.com/couchbase/geocouch/archive/couchdb1.3.x.tar.gz && \
 tar xzf /opt/couchdb1.3.x.tar.gz

RUN cd /opt/geocouch-couchdb1.3.x ; make
###

ADD ./opt /opt

# Configuration
RUN sed -e 's/^bind_address = .*$/bind_address = 0.0.0.0/' -i /usr/local/etc/couchdb/default.ini
RUN /opt/couchdb-config

# Define mountable directories.
VOLUME ["/usr/local/var/log/couchdb", "/usr/local/var/lib/couchdb", "/usr/local/etc/couchdb", "/opt/apache-couchdb-1.6.0/", "/opt/geocouch-couchdb1.3.x"]
# couchdb + geocouch source folders added for debugging

# hardcode couchdb plugin beam files into start options
ADD ./opts.patch /tmp/opts.patch
RUN patch /usr/local/bin/couchdb </tmp/opts.patch

ENTRYPOINT ["/opt/start_couch"]
EXPOSE 5984
