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
	"gobjc"
	"gobjc++"
	"gnat"
	"gdc"
	"gcc-multilib"
	"gfortran-multilib"
	"g++-multilib"
	"gobjc++-multilib"
	"gobjc-multilib"
	"gdb"
	# llvm package list taken from following URL
	# https://packages.ubuntu.com/source/groovy/llvm-defaults
	# {
	"clang"
	"clang-format"
	"clang-tidy"
	"clang-tools"
	"libc++-dev"
	"libc++1"
	"libc++abi-dev"
	"libc++abi1"
	"libclang-cpp-dev"
	"libclang-dev"
	"libclang1"
	"liblldb-dev"
	"libllvm-ocaml-dev"
	"libomp-dev"
	"libomp5"
	"lld"
	"lldb"
	"llvm"
	"llvm-dev"
	"llvm-runtime"
	"python-clang"
	"python-lldb"
	"python3-clang"
	"python3-lldb"
	# }
	# {
	"libllvm-12-ocaml-dev"
	"libllvm12"
	"llvm-12"
	"llvm-12-dev"
	"llvm-12-doc"
	"llvm-12-examples"
	"llvm-12-runtime"
	"clang-12"
	"clang-tools-12"
	"clang-12-doc"
	"libclang-common-12-dev"
	"libclang-12-dev"
	"libclang1-12"
	"clang-format-12"
	"python3-clang-12"
	"clangd-12"
	"libfuzzer-12-dev"
	"lldb-12"
	"lld-12"
	"libc++-12-dev"
	"libc++abi-12-dev"
	"libomp-12-dev"
	# }
	"php-all-dev"
	"python-all"
	"python-all-dev"
	"python-dev-is-python3"
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
	"ruby2.7-doc"
	# }
	"rustc"
	"cargo"
	"perl"
	"perl-doc"
	"golang"
	"nodejs"
	"yarn"
	"mono-complete"
	"openjdk-11-jdk"
	"openjdk-11-jre"
	"openjdk-11-jre-headless"
	"openjdk-11-demo"
	"openjdk-11-doc"
	"swig"
	"gettext"
	"dialog"
	"vim"
	"vim-doc"
	"exuberant-ctags"
	"cscope"
	"ack"
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
	"libgnutls-openssl-dev"
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

apt_update="aptitude update"
apt_fetch="aptitude -y --with-recommends --download-only install"
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

gpg_init() {
	# Make sure that the /root/.gnupg is exist
	gpg --update-trustdb
}

gpg_get_repo_key() {
	gpg \
		--no-default-keyring \
		--keyring /tmp/archive-keyring.gpg \
		--keyserver hkp://keyserver.ubuntu.com:80 \
		--recv-keys $1
	gpg \
		--no-default-keyring \
		--keyring /tmp/archive-keyring.gpg \
		--output $2 \
		--export $1
	rm -f /tmp/archive-keyring.gpg*
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
	local flag_nodejs_auto_install=true
	local flag_golang_auto_install=true
	local flag_hstr_auto_install=false

	gpg_init

	# remove multiverse from source http://archive.canonical.com/ubuntu
	local buf_src=$(cat /etc/apt/sources.list | grep -e "^deb http://archive.canonical.com/ubuntu" | head -n 1)
	local buf_dst=$(echo ${buf_src} | sed -e "s/ multiverse//")
	sed -e "s#^${buf_src}#${buf_dst}#" -i /etc/apt/sources.list

	# llvm
	curl -sSL --retry 10 --retry-connrefused --retry-delay 3 \
		https://apt.llvm.org/llvm-snapshot.gpg.key |
		gpg --dearmor \
			--output /etc/apt/trusted.gpg.d/llvm-snapshot-archive-keyring.gpg
	LLVM_VERSION="12"
	DISTRO="$(lsb_release -s -c)"
	echo "deb \
		[arch=$(dpkg --print-architecture) \
		signed-by=/etc/apt/trusted.gpg.d/llvm-snapshot-archive-keyring.gpg] \
		http://apt.llvm.org/${DISTRO}/ \
		llvm-toolchain-${DISTRO}-${LLVM_VERSION} main" |
		tee /etc/apt/sources.list.d/llvm.list
	echo "deb-src \
		[arch=$(dpkg --print-architecture) \
		signed-by=/etc/apt/trusted.gpg.d/llvm-snapshot-archive-keyring.gpg] \
		http://apt.llvm.org/${DISTRO}/ \
		llvm-toolchain-${DISTRO}-${LLVM_VERSION} main" |
		tee -a /etc/apt/sources.list.d/llvm.list

	# node.js v12.x
	NODE_VERSION="12.x"
	if [[ ${flag_nodejs_auto_install} == true ]]; then
		# automatic installation
		curl -sSL --retry 10 --retry-connrefused --retry-delay 3 \
			https://deb.nodesource.com/setup_${NODE_VERSION} | bash -
	else
		# manual installation
		curl -sSL --retry 10 --retry-connrefused --retry-delay 3 \
			https://deb.nodesource.com/gpgkey/nodesource.gpg.key |
			gpg --dearmor \
				--output /etc/apt/trusted.gpg.d/nodesource-archive-keyring.gpg
		VERSION="node_${NODE_VERSION}"
		DISTRO="$(lsb_release -s -c)"
		echo "deb \
			[arch=$(dpkg --print-architecture) \
			signed-by=/etc/apt/trusted.gpg.d/nodesource-archive-keyring.gpg] \
			https://deb.nodesource.com/${VERSION} \
			${DISTRO} main" |
			tee /etc/apt/sources.list.d/nodesource.list
		echo "deb-src \
			[arch=$(dpkg --print-architecture) \
			signed-by=/etc/apt/trusted.gpg.d/nodesource-archive-keyring.gpg] \
			https://deb.nodesource.com/${VERSION} \
			${DISTRO} main" |
			tee -a /etc/apt/sources.list.d/nodesource.list
	fi

	# yarn
	curl -sSL --retry 10 --retry-connrefused --retry-delay 3 \
		https://dl.yarnpkg.com/debian/pubkey.gpg |
		gpg --dearmor \
			--output /etc/apt/trusted.gpg.d/yarn-archive-keyring.gpg
	echo "deb \
		[arch=$(dpkg --print-architecture) \
		signed-by=/etc/apt/trusted.gpg.d/yarn-archive-keyring.gpg] \
		https://dl.yarnpkg.com/debian \
		stable main" |
		tee /etc/apt/sources.list.d/yarn.list

	# golang
	if [[ ${flag_golang_auto_install} == true ]]; then
		# automatic installation
		add-apt-repository --yes --no-update \
			ppa:longsleep/golang-backports </dev/null
	else
		# manual installation
		gpg_get_repo_key \
			52B59B1571A79DBC054901C0F6BC817356A3D45E \
			/etc/apt/trusted.gpg.d/golang-backports-archive-keyring.gpg
		DISTRO="$(lsb_release -s -c)"
		echo "deb \
			[arch=$(dpkg --print-architecture) \
			signed-by=/etc/apt/trusted.gpg.d/golang-backports-archive-keyring.gpg] \
			http://ppa.launchpad.net/longsleep/golang-backports/ubuntu \
			${DISTRO} main" |
			tee /etc/apt/sources.list.d/golang-backports.list
	fi

	# mono
	# automatic installation
	gpg_get_repo_key \
		3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF \
		/etc/apt/trusted.gpg.d/mono-archive-keyring.gpg
	# DISTRO="$(lsb_release -s -c)"
	DISTRO="focal"
	echo "deb \
		[arch=$(dpkg --print-architecture) \
		signed-by=/etc/apt/trusted.gpg.d/mono-archive-keyring.gpg] \
		https://download.mono-project.com/repo/ubuntu \
		stable-${DISTRO} main" |
		tee /etc/apt/sources.list.d/mono-official-stable.list

	# hstr
	if [[ ${flag_hstr_auto_install} == true ]]; then
		# automatic installation
		add-apt-repository --yes --no-update \
			ppa:ultradvorka/ppa </dev/null
	else
		# manual installation
		gpg_get_repo_key \
			1E841C1E5C04D97ABFF8FCB63A9508A2CC6FC1EB \
			/etc/apt/trusted.gpg.d/ultradvorka-archive-keyring.gpg
		# DISTRO="$(lsb_release -s -c)"
		DISTRO="focal"
		echo "deb \
			[arch=$(dpkg --print-architecture) \
			signed-by=/etc/apt/trusted.gpg.d/ultradvorka-archive-keyring.gpg] \
			http://ppa.launchpad.net/ultradvorka/ppa/ubuntu \
			${DISTRO} main" |
			tee /etc/apt/sources.list.d/ultradvorka.list
		echo "deb-src \
			[arch=$(dpkg --print-architecture) \
			signed-by=/etc/apt/trusted.gpg.d/ultradvorka-archive-keyring.gpg] \
			http://ppa.launchpad.net/ultradvorka/ppa/ubuntu \
			${DISTRO} main" |
			tee -a /etc/apt/sources.list.d/ultradvorka.list
	fi

	eval ${apt_update}
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

	# java
	update-java-alternatives --auto

	sudo -u ${user} -H -i bash -c "pushd ${home}/work/dotfiles/buildpkg/ && ./setup.sh && popd"

	sudo -u ${user} -H -i bash -c "vim"
}

main() {
	pre_process
	install_prerequisites
	add_repo
	fetch_all
	install_all
	post_process
}

main
