# VERSION 1.0.7

FROM tianon/ubuntu:13.04
MAINTAINER Sam Zaydel "szaydel@gmail.com"

ENV WGETRC /root/.wgetrc

ADD ./conf/supervisord/ipynotebook.conf /etc/supervisor.d/ipynotebook.conf
ADD ./conf/supervisord/sshd.conf /etc/supervisor.d/sshd.conf
ADD ./conf/supervisord/supervisord.conf /etc/supervisord.conf
ADD ./conf/ssh/authorized_keys /root/.ssh/authorized_keys
ADD ./bin/bootstrap-py.sh /tmp/bootstrap-py.sh
ADD ./arch/fonts.tar.bz2 /tmp/fonts.tar.bz2

# Add the packages.list and .condarc config file.
ADD ./conf/conda/packages.list /root/packages.list
ADD ./conf/conda/.condarc /root/.condarc

RUN echo "deb http://archive.ubuntu.com/ubuntu raring main universe" >> /etc/apt/sources.list \
	&& echo "deb http://archive.canonical.com/ $(lsb_release -sc) partner" >> /etc/apt/sources.list

RUN apt-get update && apt-get install -y --no-install-recommends \
	openssh-server \
	bzip2 \
	sudo \
	wget

# Create fonts directory and unpack fonts
RUN mkdir -p /usr/share/fonts/truetype \
	&& cd /usr/share/fonts/truetype \
	&& tar xjvf /tmp/fonts.tar.bz2; \
	rm -r /tmp/fonts.tar.bz2

# Add username with which ipython notebook will be started. 
RUN useradd -D --shell=/bin/bash; \
	useradd -m ipy; \
	echo "ipy:coo5Iehaepa." | chpasswd; \
	adduser ipy sudo; \
	sudo -u ipy mkdir -p /home/ipy/bin /home/ipy/.matplotlib /home/ipy/.ipython /home/ipy/ipynotebooks /home/ipy/.ssh

# Bootstrap Anaconda installation in ipy's home directory
RUN chmod +x /tmp/bootstrap-py.sh \
	&& /tmp/bootstrap-py.sh; \
	rm /tmp/bootstrap-py.sh

# Adding script necessary to start ipython notebook server.
ADD ./bin/run-nbserver.sh /home/ipy/bin/run-nbserver.sh
ADD ./conf/ipython/ipython_notebook_config_extra.py /home/ipy/.ipython/ipython_notebook_config_extra.py

RUN chown ipy:ipy /home/ipy/.ipython/ipython_notebook_config_extra.py /home/ipy/bin/run-nbserver.sh \
	&& chmod +x /home/ipy/bin/run-nbserver.sh

RUN mkdir -p /var/run/sshd
RUN echo "root:Zoh7sooGh\um" | chpasswd

ENV IPYTHONDIR /home/ipy/.ipython
ENV MPLCONFIGDIR /home/ipy/.matplotlib

# Exposing ports 22 == ssh, 8888 == ipython-notebook, 9001 == supervisord.
EXPOSE 22
EXPOSE 8888
EXPOSE 9001

# Make sure that file ownership and permissions are correct.
RUN chown -R 0:0 /etc/supervisor.d/ /root/.ssh/authorized_keys; chmod 400 /root/.ssh/authorized_keys

# the following command works when running docker as a daemon, but it doesn't when running docker interactively:
CMD /opt/local/anaconda/bin/supervisord -n 
