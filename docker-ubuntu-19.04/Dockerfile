FROM ubuntu:19.04
MAINTAINER Wonmin Jung <wonmin82@gmail.com>

ARG user="user"
ENV user=${user}

USER root
WORKDIR /root

RUN ln -s -f /usr/share/zoneinfo/Asia/Seoul /etc/localtime

RUN sed -e 's/http:\/\/archive\.ubuntu\.com\//http:\/\/kr\.archive\.ubuntu\.com\//g' -i /etc/apt/sources.list
RUN apt-get update && \
		apt-get -y install aptitude && \
		aptitude -y install locales apt-utils software-properties-common
RUN locale-gen "en_US" "en_US.UTF-8"
ENV LANG en_US.utf8
RUN add-apt-repository multiverse && \
		aptitude update && \
		aptitude -y upgrade
RUN yes | unminimize
RUN aptitude -y install openssh-server sudo zsh git

RUN mkdir /var/run/sshd
# RUN echo 'root:screencast' | chpasswd
# RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

RUN adduser --disabled-password --gecos '' --shell /bin/bash ${user} && \
		echo "${user}:docker" | chpasswd && \
		adduser ${user} sudo && \
		sed -i.bkp -e \
				's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' \
				/etc/sudoers

USER ${user}
WORKDIR /home/${user}

COPY setup-docker-ubuntu-19.04.sh /home/${user}/
RUN sudo chown ${user}:${user} /home/${user}/setup-docker-ubuntu-19.04.sh && \
		chmod a+x /home/${user}/setup-docker-ubuntu-19.04.sh && \
		zsh -c "sudo /home/${user}/setup-docker-ubuntu-19.04.sh" && \
		rm -f /home/${user}/setup-docker-ubuntu-19.04.sh && \
		zsh -c "sudo aptitude -y clean" && \
		zsh -c "sudo aptitude -y purge \$( dpkg --get-selections | grep deinstall | cut -f1 )"

RUN sudo zsh -c "rm -r -f /home/${user}/tmp/"

USER root
WORKDIR /root

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
