# ipython-docker
----

__Description:__ This project is an attempt at making it easy to quickly run my own _IPython Notebook_ server with Docker, and in a most typical use-case with a hand from __Vagrant__ and __CoreOS__. CoreOS is not a requirement to deploy this container, nor is Vagrant for that matter.

## Project Setup
----

There is not much to do to get things going. Simply `git clone` this repository and you are ready to roll. The repository is assumed to be cloned to machine with a working `Docker` and `LXC` configuration.

1. If you are interested in being able to ssh into the container, it is best to setup ssh keys. Simply add `conf/ssh/authorized_keys` file with your public key, and it will be injected into `root's` profile during the container build. `ssh` is exposed publicly on port 22. If you would like to change the port, simply edit `Dockerfile` and change `EXPOSE 22` to whatever port suits your need. You will also need to inject a version of `sshd` config file with modified port, and there may be a need to open-up a part in `UFW`.
2. _IPython Notebook_ is configured to be accessible on port 8888. Again, if you want to change the port you will need to change `EXPOSE 8888` to correct port and change this line `c.NotebookApp.port = 8888` in `conf/ipython/ipython_notebook_config_extra.py` to match port being exposed.
3. Processes are managed through _supervisord_, which is an excellent pure-python implementation of a process manager. It effectively daemonizes `sshd` and `IPython Notebook` and we expose port `9001` to the outside world, which allows us access to the control interface for `supervisord` through HTTP. Simply access via web browser and you have control over restarting services, etc.

A bunch of things could have been done better and hopefully others will consider forking and making improvements. There is a lot of room for improvement at the moment.

## Testing
----

YES! Really, it would be good to have at least _some_ tests, which at the moment we do not.

### Unit Tests

### Integration Tests

## Deploying
----

### _How to setup the deployment environment_

- Nothing is required beyond files in this repository and optionally key in `authorized_keys` file.
- Use `docker build` to build this container and you are ready to roll: `docker build -t szaydel/ipython-nb:1.0.4 .` You may want to replace the `szaydel/ipython-nb` part with something closer to heart. :)


### _How to deploy_

- After building the container from the included `Dockerfile`, run the container in the same way as you would any other `docker` container.

## Troubleshooting & Useful Tools
----

## License
----
__MIT - Copyright (c) 2013 Sam Zaydel.__
