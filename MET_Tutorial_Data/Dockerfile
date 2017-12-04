FROM centos:latest
MAINTAINER John Halley Gotway <johnhg@ucar.edu>

ENV MET_VERSION 6.1
ENV DATA_URL    http://www.dtcenter.org/met/users/support/online_tutorial/tutorial_data/METv${MET_VERSION}_tutorial_data.tar.gz

RUN mkdir -p /met/met-${MET_VERSION}

#
# Pull input data for the online tutorial
#
RUN echo "Downloading input data for the met-${MET_VERSION} online tutorial from ${DATA_URL}" \
 && curl -SL ${DATA_URL} | tar zxC /met/met-${MET_VERSION} data

VOLUME /met/met-${MET_VERSION}/data
CMD ["true"]
