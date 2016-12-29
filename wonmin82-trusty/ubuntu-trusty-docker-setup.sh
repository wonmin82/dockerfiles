#!/bin/bash

list_tasks_to_be_installed=(
"openssh-server"
)

list_pkgs_to_be_uninstalled=(
)

list_pkgs_to_be_prohibited=(

)

list_pkgs_to_be_installed=(
"build-essential"
"libboost-all-dev"
"libboost-doc"
"cmake"
"automake"
"autotools-dev"
"autoconf"
"autopoint"
"libtool"
"cpp"
"gcc"
"g++"
"gfortran"
"gcj-jdk"
"gobjc"
"gobjc++"
"gnat"
"gdc"
"libgcj-common"
"libgcj-bc"
"gcc-multilib"
"gfortran-multilib"
"g++-multilib"
"gobjc++-multilib"
"gobjc-multilib"
"man-db"
"manpages"
"manpages-dev"
"manpages-posix"
"manpages-posix-dev"
"dialog"
"sudo"
"zsh"
"curl"
"git"
"htop"
"glances"
"exuberant-ctags"
"cscope"
"gettext"
"doxygen"
"graphviz"
"pandoc"
"asciidoc"
"sphinx-common"
"cvs"
"subversion"
"subversion-tools"
"git-all"
"git-arch"
"git-core"
"git-cvs"
"git-daemon-run"
"git-doc"
"git-email"
"git-gui"
"git-svn"
"gitk"
"gitweb"
"tig"
"mercurial"
"libffi-dev"
"libncurses5-dev"
"e2fslibs-dev"
"libglib2.0-dev"
"libgnutls-dev"
"libssh2-1-dev"
"libslang2-dev"
"libevent-dev"
"libcurl4-openssl-dev"
"liblua5.2-dev"
"python-all"
"python-dev"
"python-all-dev"
"python-doc"
"python-flake8"
"python3-all"
"python3-dev"
"python3-all-dev"
"python3-doc"
"python3-flake8"
# need to be checked for existence when ubuntu is upgraded {
"ruby-full"
# }
# lua version should be matched with 'vim --version | grep lua' {
"liblua5.2-dev"
"lua5.2"
# }
"golang"
"nodejs"
"nodejs-legacy"
"npm"
"mono-complete"
)

retry()
{
	local nTrys=0
	local maxTrys=50
	local delayBtwnTrys=3
	local lastStatus=256
	until [[ $lastStatus == 0 ]]; do
		$*
		lastStatus=$?
		nTrys=$(($nTrys + 1))
		if [[ $nTrys -gt $maxTrys ]]; then
			echo "Number of re-trys exceeded. Exit code: $lastStatus"
			exit $lastStatus
		fi
		if [[ $lastStatus != 0 ]]; then
			echo "Failed (exit code $lastStatus)... retry count $nTrys/$maxTrys"
			sleep $delayBtwnTrys
		fi
	done
}

pre_process()
{
	echo "dash dash/sh boolean false" | debconf-set-selections
	dpkg-reconfigure --frontend noninteractive dash

	echo "debconf debconf/frontend select Noninteractive" | debconf-set-selections

	rm -f /etc/apt/apt.conf.d/docker-clean

	user="$(getent passwd 1000 | cut -d: -f1)"
	home="$(getent passwd 1000 | cut -d: -f6)"

	sudo -u ${user} -H -i bash -c "mkdir -p ${home}/work/"

	sudo -u ${user} -H -i bash -c "git clone https://github.com/wonmin82/dotfiles.git ${home}/work/dotfiles/"

	sudo -u ${user} -H -i bash -c "pushd ${home}/work/dotfiles/ && ./install-ubuntu-config.sh && popd"
	sudo -u ${user} -H -i bash -c "pushd ${home}/work/dotfiles/ && ./install-zsh-config.sh && popd"
	sudo -u ${user} -H -i bash -c "pushd ${home}/work/dotfiles/ && ./install-vim-config.sh && popd"

}

install_prerequisites()
{
	retry aptitude update
	retry aptitude -y --with-recommends --download-only install apt-transport-https ca-certificates tasksel
	aptitude -y --with-recommends install apt-transport-https ca-certificates tasksel
}

add_ppa()
{
	# oracle java
	add-apt-repository ppa:webupd8team/java < /dev/null

	# mono
	retry apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
	echo "deb http://download.mono-project.com/repo/debian wheezy main" | tee /etc/apt/sources.list.d/mono-xamarin.list

	retry aptitude update
}

install_java()
{
	ORACLE_JAVA_PKG_PREFIX="oracle-java8"
	retry aptitude -y -d install ${ORACLE_JAVA_PKG_PREFIX}-installer ${ORACLE_JAVA_PKG_PREFIX}-set-default ${ORACLE_JAVA_PKG_PREFIX}-unlimited-jce-policy
	lastStatus=256
	until [[ ${lastStatus} == 0 ]]; do
		aptitude -y purge ${ORACLE_JAVA_PKG_PREFIX}-installer ${ORACLE_JAVA_PKG_PREFIX}-set-default ${ORACLE_JAVA_PKG_PREFIX}-unlimited-jce-policy
		echo ${ORACLE_JAVA_PKG_PREFIX}-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
		aptitude -y install ${ORACLE_JAVA_PKG_PREFIX}-installer ${ORACLE_JAVA_PKG_PREFIX}-set-default ${ORACLE_JAVA_PKG_PREFIX}-unlimited-jce-policy
		lastStatus=$?
	done
}

fetch_all()
{
	aptitude_fetch_command="retry aptitude -y --with-recommends --download-only install"
	for task in "${list_tasks_to_be_installed[@]}"; do
		list_pkg=($(tasksel --task-packages ${task}))
		aptitude_fetch_command="${aptitude_fetch_command} ${list_pkg[@]}"
		eval $aptitude_fetch_command
	done

	aptitude_fetch_command="retry aptitude -y --with-recommends --download-only install"
	aptitude_fetch_command="${aptitude_fetch_command} ${list_pkgs_to_be_installed[@]}"
	eval $aptitude_fetch_command
}

install_all()
{
	aptitude_install_command="aptitude -y --with-recommends install"
	for task in "${list_tasks_to_be_installed[@]}"; do
		list_pkg=($(tasksel --task-packages ${task}))
		aptitude_install_command="${aptitude_install_command} ${list_pkg[@]}"
		eval $aptitude_install_command
	done

	aptitude_remove_command="aptitude -y purge"
	aptitude_remove_command="${aptitude_remove_command} ${list_pkgs_to_be_uninstalled[@]}"
	eval $aptitude_remove_command

	aptitude_install_command="aptitude -y --with-recommends install"
	aptitude_install_command="${aptitude_install_command} ${list_pkgs_to_be_installed[@]}"
	eval $aptitude_install_command
}

post_process()
{
	echo "debconf debconf/frontend select Dialog" | debconf-set-selections

	user="$(getent passwd 1000 | cut -d: -f1)"
	home="$(getent passwd 1000 | cut -d: -f6)"

	sudo -u ${user} -H -i bash -c "pushd ${home}/work/dotfiles/ubuntu/buildpkg/ && ./setup.sh && popd"

	sudo -u ${user} -H -i bash -c "vim"
}

main()
{
	pre_process
	install_prerequisites
	add_ppa
	fetch_all
	install_java
	install_all
	post_process
}

main
