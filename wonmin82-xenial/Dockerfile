FROM ubuntu:16.04
MAINTAINER Wonmin Jung <wonmin82@gmail.com>

ENV user wonmin82

USER root
WORKDIR /root

RUN ln -s -f /usr/share/zoneinfo/Asia/Seoul /etc/localtime

RUN sed -e 's/http:\/\/archive\.ubuntu\.com\//http:\/\/kr\.archive\.ubuntu\.com\//g' -i /etc/apt/sources.list
RUN locale-gen "en_US" "en_US.UTF-8"
RUN dpkg-reconfigure --frontend noninteractive locales
RUN echo "debconf debconf/frontend select Noninteractive" | debconf-set-selections
RUN apt-get update
RUN apt-get -y install aptitude
RUN aptitude -y install apt-utils software-properties-common
RUN add-apt-repository multiverse
RUN aptitude update
RUN aptitude -y upgrade
RUN aptitude -y install openssh-server
RUN aptitude -y install sudo zsh git

RUN echo "debconf debconf/frontend select Dialog" | debconf-set-selections

RUN mkdir /var/run/sshd
# RUN echo 'root:screencast' | chpasswd
# RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

RUN adduser --disabled-password --gecos '' --shell /bin/bash ${user}
RUN echo "${user}:xenial" | chpasswd
RUN adduser ${user} sudo
RUN sed -i.bkp -e \
		's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' \
		/etc/sudoers

USER ${user}
WORKDIR /home/${user}

COPY ubuntu-xenial-docker-setup.sh /home/${user}/
RUN sudo chown ${user}:${user} /home/${user}/ubuntu-xenial-docker-setup.sh
RUN chmod a+x /home/${user}/ubuntu-xenial-docker-setup.sh
RUN zsh -c "sudo /home/${user}/ubuntu-xenial-docker-setup.sh"
RUN rm -f /home/${user}/ubuntu-xenial-docker-setup.sh

USER root
WORKDIR /root

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
