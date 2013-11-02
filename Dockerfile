# VERSION 1.0.3

FROM ubuntu:quantal
MAINTAINER Sam Zaydel "szaydel@gmail.com"

ENV WGETRC /tmp/.wgetrc
ADD ./conf/supervisord/ipynotebook.conf /etc/supervisor.d/ipynotebook.conf
ADD ./conf/supervisord/sshd.conf /etc/supervisor.d/sshd.conf
ADD ./conf/supervisord/supervisord.conf /etc/supervisord.conf
ADD ./ssh/authorized_keys /root/.ssh/authorized_keys
ADD ./bin/bootstrap-py.sh /tmp/bootstrap-py.sh

RUN echo "deb http://archive.ubuntu.com/ubuntu quantal main universe" > /etc/apt/sources.list
RUN apt-get update

RUN cd /tmp; printf "%s\n" "check_certificate = off" "check_certificate = off" "timeout = 90" "tries = 2" "wait = 15" >> .wgetrc

RUN apt-get install -y --no-install-recommends \
                wget python-numpy python-scipy \
                python-matplotlib ipython \
                ipython-notebook python-pandas \
                python-nose openssh-server

RUN chmod +x /tmp/bootstrap-py.sh && /tmp/bootstrap-py.sh

# Add username with which ipython notebook will be started. 
RUN useradd -D --shell=/bin/bash
RUN useradd -m ipy
RUN echo "ipy:coo5Iehaepa." | chpasswd
RUN adduser ipy sudo
RUN sudo -u ipy mkdir  -p /home/ipy/.matplotlib /home/ipy/.ipython /home/ipy/ipynotebooks /home/ipy/.ssh

RUN mkdir -p /var/run/sshd
RUN echo "root:Zoh7sooGh\um" | chpasswd

ENV IPYTHONDIR /home/ipy/.ipython
ENV MPLCONFIGDIR /home/ipy/.matplotlib

EXPOSE 22
EXPOSE 8888

# the following command works when running docker as a daemon, but it doesn't when running docker interactively:
CMD /usr/local/bin/supervisord -n 
