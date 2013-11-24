# VERSION 1.0.5

FROM 0xffea/saucy-server-cloudimg-amd64:latest
MAINTAINER Sam Zaydel "szaydel@gmail.com"

ENV WGETRC /tmp/.wgetrc
ADD ./conf/supervisord/ipynotebook.conf /etc/supervisor.d/ipynotebook.conf
ADD ./conf/supervisord/sshd.conf /etc/supervisor.d/sshd.conf
ADD ./conf/supervisord/supervisord.conf /etc/supervisord.conf
ADD ./conf/ssh/authorized_keys /root/.ssh/authorized_keys
ADD ./bin/bootstrap-py.sh /tmp/bootstrap-py.sh

RUN echo "deb http://archive.ubuntu.com/ubuntu saucy main universe" > /etc/apt/sources.list
RUN apt-get update

RUN cd /tmp; printf "%s\n" "check_certificate = off" "check_certificate = off" "timeout = 90" "tries = 2" "wait = 15" >> .wgetrc

RUN apt-get install -y --no-install-recommends openssh-server

# Add username with which ipython notebook will be started. 
RUN useradd -D --shell=/bin/bash; \
	useradd -m ipy; \
	echo "ipy:coo5Iehaepa." | chpasswd; \
	adduser ipy sudo; \
	sudo -u ipy mkdir -p /home/ipy/bin /home/ipy/.matplotlib /home/ipy/.ipython /home/ipy/ipynotebooks /home/ipy/.ssh

# Add the packages 
ADD ./conf/conda/packages.list /root
ADD conf/conda/.condarc /root

# Bootstrap Anaconda installation in ipy's home directory
RUN chmod +x /tmp/bootstrap-py.sh && /tmp/bootstrap-py.sh; rm /tmp/bootstrap-py.sh

# Adding script necessary to start ipython notebook server.
ADD ./bin/run-nbserver.sh /home/ipy/bin/run-nbserver.sh
ADD ./conf/ipython/ipython_notebook_config_extra.py /home/ipy/.ipython/ipython_notebook_config_extra.py
RUN chown ipy:ipy /home/ipy/.ipython/ipython_notebook_config_extra.py /home/ipy/bin/run-nbserver.sh && chmod +x /home/ipy/bin/run-nbserver.sh

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
