FROM ubuntu:21.04
MAINTAINER Wonmin Jung <wonmin82@gmail.com>

ARG user="user"
ARG uid=1000
ARG gid=1000
ARG ssh_prv_key
ARG ssh_pub_key

ENV user=${user}
ENV uid=${uid}
ENV gid=${gid}

USER root
WORKDIR /root

RUN ln -s -f /usr/share/zoneinfo/Asia/Seoul /etc/localtime

RUN sed \
		-e 's/http:\/\/archive\.ubuntu\.com\//http:\/\/kr\.archive\.ubuntu\.com\//g' \
		-i /etc/apt/sources.list
RUN sed \
		-e 's/kr\.archive\.ubuntu\.com/mirror\.kakao\.com/g' \
		-i /etc/apt/sources.list && \
	sed \
		-e 's/security\.ubuntu\.com/mirror\.kakao\.com/g' \
		-i /etc/apt/sources.list && \
	sed \
		-e 's/extras\.ubuntu\.com/mirror\.kakao\.com/g' \
		-i /etc/apt/sources.list
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
# RUN echo 'root:default' | chpasswd
# RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

RUN addgroup --system --force-badname --gid ${gid} ${user} && \
	adduser --disabled-password --gecos '' --shell /bin/bash \
		--force-badname --uid ${uid} --gid ${gid} ${user} && \
	adduser ${user} sudo && \
	sed -i.bkp -e \
		's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' \
		/etc/sudoers
# RUN echo "${user}:default" | chpasswd

USER ${user}
WORKDIR /home/${user}

RUN mkdir -p /home/${user}/.ssh && \
	chmod 0700 /home/${user}/.ssh && \
	echo "$ssh_prv_key" > /home/${user}/.ssh/id_rsa && \
	echo "$ssh_pub_key" > /home/${user}/.ssh/id_rsa.pub && \
	echo "$ssh_pub_key" > /home/${user}/.ssh/authorized_keys && \
	chmod 600 /home/${user}/.ssh/id_rsa && \
	chmod 400 /home/${user}/.ssh/id_rsa.pub && \
	chmod 400 /home/${user}/.ssh/authorized_keys

COPY setup-docker-ubuntu-21.04.sh /home/${user}/
RUN sudo chown ${user}:${user} /home/${user}/setup-docker-ubuntu-21.04.sh && \
	chmod a+x /home/${user}/setup-docker-ubuntu-21.04.sh && \
	zsh -c "sudo user=${user} uid=${uid} gid=${gid} \
		/home/${user}/setup-docker-ubuntu-21.04.sh" && \
	rm -f /home/${user}/setup-docker-ubuntu-21.04.sh && \
	zsh -c "sudo aptitude -y clean" && \
	zsh -c "sudo aptitude -y purge \$( dpkg --get-selections | grep deinstall | cut -f1 )"

USER root
WORKDIR /root

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]