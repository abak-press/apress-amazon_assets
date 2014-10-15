FROM ubuntu:trusty
MAINTAINER Merkushin Michail <merkushin.m.s@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

# ensure UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8

# YEKT locale
RUN mv /etc/localtime /etc/localtime-old
RUN ln -sf /usr/share/zoneinfo/Asia/Yekaterinburg /etc/localtime

# add apt repositories
RUN echo "deb http://archive.ubuntu.com/ubuntu/ trusty main universe" > /etc/apt/sources.list
RUN echo "deb http://archive.ubuntu.com/ubuntu/ trusty-updates main universe" >> /etc/apt/sources.list
RUN apt-get update
RUN apt-get -y -q upgrade

# create init script
RUN touch /root/init
RUN echo "#!/bin/sh" >> /root/init
RUN echo "set -x" >> /root/init
RUN chmod +x /root/init

# gem env
ENV GEM_HOME /usr/local/gems
ENV GEM_PATH /usr/local/gems
ENV PATH $GEM_PATH/bin:$PATH

# install curl and git
RUN apt-get install -y -q curl git vim

# install time command
RUN apt-get -y -q install time

# add GitHub to known hosts
RUN ssh-keyscan -H github.com >> /etc/ssh/ssh_known_hosts

# install ruby
ENV RVM_PATH /usr/local/rvm
ENV RVM ${RVM_PATH}/bin/rvm
ENV RVM_RUBY ruby-1.9.3-p545
RUN curl -L https://get.rvm.io | bash -s stable
RUN $RVM install $RVM_RUBY --patch railsexpress
ENV PATH ${RVM_PATH}/rubies/${RVM_RUBY}/bin:$PATH

# project deps
RUN apt-get install -y -q libxslt-dev libxml2-dev
RUN apt-get install -y -q libcurl3-dev
RUN apt-get install -y -q libpq-dev

# dnsmasq
RUN apt-get install -y -q dnsmasq-base dnsutils
RUN mkdir /etc/dnsmasq.d
RUN echo "address=/dev/127.0.0.1" >> /etc/dnsmasq.d/0hosts
RUN echo '$(which dnsmasq) -C /etc/dnsmasq.conf' >> /root/init
# dnsmasq configuration
RUN echo 'user=root' >> /etc/dnsmasq.conf
RUN echo 'listen-address=127.0.0.1' >> /etc/dnsmasq.conf
RUN echo 'resolv-file=/etc/resolv.dnsmasq.conf' >> /etc/dnsmasq.conf
RUN echo 'conf-dir=/etc/dnsmasq.d' >> /etc/dnsmasq.conf
# google dns
RUN echo 'nameserver 8.8.8.8' >> /etc/resolv.dnsmasq.conf
RUN echo 'nameserver 8.8.4.4' >> /etc/resolv.dnsmasq.conf

# postgres
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" > /etc/apt/sources.list.d/pgdg.list
RUN apt-get update
RUN apt-get -y -q install postgresql-9.3 postgresql-client-9.3 postgresql-plperl-9.3
RUN pg_dropcluster --stop 9.3 main
RUN pg_createcluster --locale $LC_ALL --start 9.3 main
RUN echo "sudo -u postgres /etc/init.d/postgresql start" >> /root/init
RUN echo "host all all 0.0.0.0/0 trust" > /etc/postgresql/9.3/main/pg_hba.conf
RUN echo "host all all ::1/128 trust" > /etc/postgresql/9.3/main/pg_hba.conf
RUN echo "local all all trust" >> /etc/postgresql/9.3/main/pg_hba.conf
RUN echo "listen_addresses='*'" >> /etc/postgresql/9.3/main/postgresql.conf
RUN echo "ssl=false" >> /etc/postgresql/9.3/main/postgresql.conf

# project db
RUN /etc/init.d/postgresql start &&\
    sudo -u postgres psql -c "CREATE USER docker WITH SUPERUSER PASSWORD 'docker';" &&\
    sudo -u postgres createdb -O docker docker
