#!/bin/bash

list_install_tasks=(
	"openssh-server"
)

list_uninstall_pkgs=(
)

list_prohibit_pkgs=(

)

list_install_pkgs=(
	"sudo"
	"build-essential"
	"libboost-all-dev"
	"libboost-doc"
	"man-db"
	"manpages"
	"manpages-dev"
	"manpages-posix"
	"manpages-posix-dev"
	"cppman"
	"flex"
	"flex-doc"
	"bison"
	"bison-doc"
	"bisonc++"
	"bisonc++-doc"
	"automake"
	"autotools-dev"
	"autoconf"
	"autopoint"
	"libtool"
	"cmake"
	"ninja-build"
	"doxygen"
	"graphviz"
	"pandoc"
	"asciidoc"
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
	"gdb"
	"clang"
	"clang-format"
	"clang-tidy"
	"libclang-dev"
	"libclang1"
	"libllvm-ocaml-dev"
	"lldb"
	"llvm"
	"llvm-dev"
	"llvm-runtime"
	"clang-3.8"
	"clang-3.8-doc"
	"clang-3.8-examples"
	"clang-format-3.8"
	"clang-tidy-3.8"
	"libclang-3.8-dev"
	"libclang-common-3.8-dev"
	"libclang1-3.8"
	"libclang1-3.8-dbg"
	"liblldb-3.8"
	"liblldb-3.8-dbg"
	"liblldb-3.8-dev"
	"libllvm-3.8-ocaml-dev"
	"libllvm3.8"
	"libllvm3.8-dbg"
	"lldb-3.8"
	"lldb-3.8-dev"
	"llvm-3.8"
	"llvm-3.8-dev"
	"llvm-3.8-doc"
	"llvm-3.8-examples"
	"llvm-3.8-runtime"
	"python-clang-3.8"
	"python-lldb-3.8"
	"php-all-dev"
	"python-all"
	"python-dev"
	"python-all-dev"
	"python-virtualenv"
	"python-pip"
	"python-sphinx"
	"python-doc"
	"python3-all"
	"python3-dev"
	"python3-all-dev"
	"python3-venv"
	"python3-virtualenv"
	"python3-pip"
	"python3-sphinx"
	"python3-doc"
	"virtualenv"
	"virtualenvwrapper"
	# need to be checked for existence when ubuntu is upgraded {
	"ruby-full"
	"ruby2.3-doc"
	# }
	"rustc"
	"cargo"
	"perl"
	"perl-doc"
	"golang"
	"nodejs"
	"mono-complete"
	"swig"
	"gettext"
	"dialog"
	"vim"
	"vim-doc"
	"exuberant-ctags"
	"cscope"
	"ack-grep"
	"zsh"
	"inxi"
	"htop"
	"glances"
	"nmon"
	"tree"
	"mc"
	"tmux"
	"nmap"
	"cvs"
	"subversion"
	"subversion-tools"
	"curl"
	"git-all"
	"git-arch"
	"git-core"
	"git-cvs"
	"git-daemon-sysvinit"
	"git-doc"
	"git-email"
	"git-gui"
	"git-svn"
	"gitk"
	"gitweb"
	"tig"
	"mercurial"
	"moreutils"
	"parallel"
	"libffi-dev"
	"libncurses5"
	"libncurses5-dev"
	"libncursesw5"
	"libncursesw5-dev"
	"e2fslibs-dev"
	"libglib2.0-dev"
	"libgnutls-dev"
	"libssh2-1-dev"
	"libslang2-dev"
	"libevent-dev"
	"libedit-dev"
	"libcurl4-openssl-dev"
	# build dependency for vim {
	"lua5.2"
	"liblua5.2-dev"
	"tcl8.6"
	"tcl8.6-dev"
	"libperl-dev"
	"hstr"
	# }
)

apt_update="retry aptitude update"
apt_fetch="retry aptitude -y --with-recommends --download-only install"
apt_install="aptitude -y --with-recommends install"
apt_remove="aptitude -y purge"

retry() {
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

pre_process() {
	echo "dash dash/sh boolean false" | debconf-set-selections
	dpkg-reconfigure --frontend noninteractive dash

	echo "debconf debconf/frontend select noninteractive" | debconf-set-selections

	rm -f /etc/apt/apt.conf.d/docker-clean

	home="$(getent passwd ${uid} | cut -d: -f6)"

	sudo -u ${user} -H -i bash -c "mkdir -p ${home}/work/"

	sudo -u ${user} -H -i bash -c "touch ${home}/.ssh/known_hosts && chmod -v 600 ${home}/.ssh/known_hosts && ssh-keyscan -H github.com >> ${home}/.ssh/known_hosts"
	sudo -u ${user} -H -i bash -c "git clone ssh://git@github.com/wonmin82/dotfiles.git ${home}/work/dotfiles/"

	sudo -u ${user} -H -i bash -c "pushd ${home}/work/dotfiles/ && ./install-ubuntu-config.sh --system && popd"
	sudo -u ${user} -H -i bash -c "pushd ${home}/work/dotfiles/ && ./install-zsh-config.sh && popd"
	sudo -u ${user} -H -i bash -c "pushd ${home}/work/dotfiles/ && ./install-vim-config.sh && popd"

}

install_prerequisites() {
	eval ${apt_update}
	eval ${apt_fetch} apt-transport-https ca-certificates tasksel curl
	eval ${apt_install} apt-transport-https ca-certificates tasksel curl
}

add_repo() {
	# oracle java
	# add-apt-repository ppa:webupd8team/java </dev/null

	# node.js v10.x
	curl -sL --retry 10 --retry-delay 3 \
		https://deb.nodesource.com/setup_10.x | bash -

	# golang
	add-apt-repository ppa:longsleep/golang-backports </dev/null

	# mono
	retry apt-key adv \
		--keyserver hkp://keyserver.ubuntu.com:80 \
		--recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
	echo "deb \
		https://download.mono-project.com/repo/ubuntu \
		stable-xenial \
		main" |
		tee /etc/apt/sources.list.d/mono-official-stable.list

	add-apt-repository ppa:ultradvorka/ppa </dev/null

	eval ${apt_update}
}

install_java() {
	ORACLE_JAVA_PKG_PREFIX="oracle-java8"
	eval ${apt_fetch} \
		${ORACLE_JAVA_PKG_PREFIX}-installer \
		${ORACLE_JAVA_PKG_PREFIX}-set-default \
		${ORACLE_JAVA_PKG_PREFIX}-unlimited-jce-policy
	lastStatus=65536
	until [[ ${lastStatus} == 0 ]]; do
		if ((lastStatus != 65536)); then
			eval ${apt_remove} \
				${ORACLE_JAVA_PKG_PREFIX}-installer \
				${ORACLE_JAVA_PKG_PREFIX}-set-default \
				${ORACLE_JAVA_PKG_PREFIX}-unlimited-jce-policy
		fi
		echo "${ORACLE_JAVA_PKG_PREFIX}-installer \
			shared/accepted-oracle-license-v1-1 \
			select true" | debconf-set-selections
		eval ${apt_install} \
			${ORACLE_JAVA_PKG_PREFIX}-installer \
			${ORACLE_JAVA_PKG_PREFIX}-set-default \
			${ORACLE_JAVA_PKG_PREFIX}-unlimited-jce-policy
		lastStatus=$?
	done
}

fetch_all() {
	for task in "${list_install_tasks[@]}"; do
		list_pkg=($(tasksel --task-packages ${task}))
		eval ${apt_fetch} ${list_pkg[@]}
	done

	eval ${apt_fetch} ${list_install_pkgs[@]}
}

install_all() {
	for task in "${list_install_tasks[@]}"; do
		list_pkg=($(tasksel --task-packages ${task}))
		eval ${apt_install} ${list_pkg[@]}
	done

	if [ ${#list_uninstall_pkgs[@]} -ne 0 ]; then
		eval ${apt_remove} ${list_uninstall_pkgs[@]}
	fi

	eval ${apt_install} ${list_install_pkgs[@]}
}

post_process() {
	echo "debconf debconf/frontend select dialog" | debconf-set-selections

	home="$(getent passwd ${uid} | cut -d: -f6)"

	sudo -u ${user} -H -i bash -c "pushd ${home}/work/dotfiles/buildpkg/ && ./setup.sh && popd"

	sudo -u ${user} -H -i bash -c "vim"
}

main() {
	pre_process
	install_prerequisites
	add_repo
	fetch_all
	# install_java
	install_all
	post_process
}

main
