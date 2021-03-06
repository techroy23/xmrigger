#!/bin/bash

# Load vars
CMAKE_ARGS=""
C_COMPILER="gcc" #gcc is the default and usually fine
CONFIG_FILE=""
CUDA_TOOLKIT_DIR="c:/Program Files/NVIDIA GPU Computing Toolkit/CUDA/v11.0" #default - bless fwdslash
CXX_COMPILER="gcc" #gcc is the default and usually fine
MAKE_CORE_COUNT=1
MSVS2019_GCC_64_DIR="c:\xmrig-deps\msvc2019\x64" #default, may req escapes
MSVS2019_XMRIGDEPS_DIR="c:\xmrig-deps\msvc2019\x64" #default, may req escapes
MSYS_CMAKE_DIR="c:\Program Files\CMake\bin\cmake.exe" #default, may req escapes
MSYS_GCC_64_DIR="c:/xmrig-deps/gcc/x64" #default
OSX_OPENSSL_DIR="/usr/local/opt/openssl"
PACKAGE_MANAGER=""
SELECTED_C_COMPILER="gcc"
SELECTED_COMPILE_ARCH=""
SELECTED_COMPILE_OS=""
SELECTED_CXX_COMPILER="gcc"
SWAP_FILE_DIR_LINUX_GENERIC="/paging-xmrigger"
SWAP_FILE_SIZE="3G"
XMRIG_DIR="/opt"

# We need colours, colors if you desire freedom
RESTORE=$(echo -en '\033[0m')
RED=$(echo -en '\033[00;31m')
GREEN=$(echo -en '\033[00;32m')
YELLOW=$(echo -en '\033[00;33m')
BLUE=$(echo -en '\033[00;34m')
MAGENTA=$(echo -en '\033[00;35m')
PURPLE=$(echo -en '\033[00;35m')
CYAN=$(echo -en '\033[00;36m')
LIGHTGRAY=$(echo -en '\033[00;37m')
LRED=$(echo -en '\033[01;31m')
LGREEN=$(echo -en '\033[01;32m')
LYELLOW=$(echo -en '\033[01;33m')
LBLUE=$(echo -en '\033[01;34m')
LMAGENTA=$(echo -en '\033[01;35m')
LPURPLE=$(echo -en '\033[01;35m')
LCYAN=$(echo -en '\033[01;36m')
WHITE=$(echo -en '\033[01;37m')

function intro-text () {
  echo ""
  echo "${CYAN}+---------------------------------------------------------------+"
  echo "${PURPLE} ██╗  ██╗███╗   ███╗██████╗ ██╗ ██████╗  ██████╗ ███████╗██████╗ ${RESTORE}"
  echo "${PURPLE} ╚██╗██╔╝████╗ ████║██╔══██╗██║██╔════╝ ██╔════╝ ██╔════╝██╔══██╗${RESTORE}"
  echo "${PURPLE}  ╚███╔╝ ██╔████╔██║██████╔╝██║██║  ███╗██║  ███╗█████╗  ██████╔╝${RESTORE}"
  echo "${PURPLE}  ██╔██╗ ██║╚██╔╝██║██╔══██╗██║██║   ██║██║   ██║██╔══╝  ██╔══██╗${RESTORE}"
  echo "${PURPLE} ██╔╝ ██╗██║ ╚═╝ ██║██║  ██║██║╚██████╔╝╚██████╔╝███████╗██║  ██║${RESTORE}"
  echo "${PURPLE} ╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝ ╚═════╝  ╚═════╝ ╚══════╝╚═╝  ╚═╝${RESTORE}"
  echo "${CYAN}+---------------------------------------------------------------+"
  echo ""
}

function help-text () {
  echo ""
  echo "${CYAN}+------------------------------------------------------------+"
  echo "${CYAN}See below for the full list of flags available and their usage - all flag arguments are lowercase"
  echo "${LGREEN}-a ${LGREEN}-${LCYAN} Defines the CPU architecture, options available are:{$MAGENTA} arm7, arm8, x86, x64${RESTORE}"
  echo "${LGREEN}-c ${LGREEN}-${LCYAN} Sets the c compiler, defaults to gcc for wider system support{RESTORE}"
  echo "${LGREEN}-cxx ${LGREEN}-${LCYAN} Sets the cxx compiler, defaults to gcc for wider system support{RESTORE}"
  echo "${LGREEN}-o ${LGREEN}-${LCYAN} Defines the OS, options available are:{$MAGENTA}  alpine, arch, centos7, centos8, fedora, freebsd, manjaro, ubuntu, macos, win10-msys2 and win10-vs2019${RESTORE}"
  echo "${LGREEN}-s ${LGREEN}-${LCYAN} Defines the swap file directory if required - this is recommended for systems with <2G of memory as compiling usually will occupy more than 2G even without loading a desktop environment${RESTORE}"
  echo "${LGREEN}-S ${LGREEN}-${LCYAN} Sets the size of the swap file, only accepts ints (whole numbers, no decimal places){RESTORE}"
  echo "${CYAN}+---------------------------------------------------------------+"
  echo ""
}

#######################
# launch flag support #
#######################

while getopts a:c:conf:cxx:o:pb:ps:s:S:v: flag
do
    case "${flag}" in
        a) SELECTED_COMPILE_ARCH=${OPTARG};;
	c) SELECTED_C_COMPILER=${OPTARG};;
	conf) CONFIG_FILE=${OPTARG};;
	cxx) SELECTED_CXX_COMPILER=${OPTARG};;
        o) SELECTED_COMPILE_OS=${OPTARG};;
	pb) RUN_POST_RIG_BASIC=true;;
	ps) RUN_POST_RIG_SILENT=true;;
        s) SWAP_FILE_DIR_LINUX_GENERIC=${OPTARG};;
        S) SWAP_FILE_SIZE="${OPTARG}G";;
        v) CMAKE_ARGS="$CMAKE_ARGS -v";; # verbose cmake for troubleshooting
    esac
done

#################################################
# Configure swap file for low-mem Linux systems #
#################################################

function swapfile-generic () {
  # 3G default, generally not more than 2 is needed
  # typically 4G total memory is recommended for compilation to be successful
  # bear in mind that using swap is also a tad slower, compile time will suffer as a result if you have to dip into swap
  echo ""
  echo "${CYAN}+---------------------------------------------------------------+"
  echo "${LGREEN}# If you've set either the -s or -S flags a swapfile will now be created${RESTORE}"
  echo "${LGREEN}# If one of these flags is set but not the other, the default value will be used for the unset flag${RESTORE}"
  echo "${CYAN}+---------------------------------------------------------------+"
  echo "${LGREEN}# The defaults are 3G swap size, and the swap file location is /paging-xmrigger${RESTORE}"
  echo "${MAGENTA}# If these settings work for you, keep on truckin'${RESTORE}"
  echo "${CYAN}+---------------------------------------------------------------+"
  echo ""
  sudo fallocate -l 3G $SWAP_FILE_DIR_LINUX_GENERIC
  sudo chmod 600 $SWAP_FILE_DIR_LINUX_GENERIC
  sudo mkswap $SWAP_FILE_DIR_LINUX_GENERIC
  sudo swapon $SWAP_FILE_DIR_LINUX_GENERIC
  echo "${CYAN}+---------------------------------------------------------------+"
  echo ""
}

###############################
# Pre-requisite installations #
###############################

# Pull pre-requisite packages for Alpine
function xmrigger-packages-alpine () {
  sudo apk add git make cmake libstdc++ gcc g++ libuv-dev openssl-dev hwloc-dev
}
# ARM systems generally do not require hwloc - doesn't harm to include, however
function xmrigger-packages-alpine-arm7 () {
  sudo apk add git make cmake libstdc++ gcc g++ libuv-dev openssl-dev hwloc-dev
}
# ARM systems generally do not require hwloc - doesn't harm to include, however
function xmrigger-packages-alpine-arm8 () {
  sudo apk add git make cmake libstdc++ gcc g++ libuv-dev openssl-dev hwloc-dev
}
# Pull pre-requisite packages for Centos7
function xmrigger-packages-centos7 () {
  sudo yum install -y epel-release
  sudo yum install -y git make cmake gcc gcc-c++ libstdc++-static libuv-static hwloc-devel openssl-devel
}
# Pull pre-requisite packages for Centos8
function xmrigger-packages-centos8 () {
  sudo dnf install -y epel-release
  sudo yum config-manager --set-enabled PowerTools
  sudo dnf install -y git make cmake gcc gcc-c++ libstdc++-static hwloc-devel openssl-devel automake libtool autoconf
}
# Pull pre-requisite packages for Fedora
function xmrigger-packages-fedora () {
  sudo dnf install -y git make cmake gcc gcc-c++ libstdc++-static libuv-static hwloc-devel openssl-devel
}
# Pull pre-requisite packages for FreeBSD
function xmrigger-packages-freebsd () {
  pkg install git cmake libuv openssl hwloc
}
# Pull pre-requisite packages for MacOS
function xmrigger-packages-macos () {
  brew install cmake libuv openssl hwloc
}
# Pull pre-requisite packages for Ubuntu
function xmrigger-packages-ubuntu () { 
  sudo apt-get install -y git build-essential cmake libuv1-dev libssl-dev libhwloc-dev 
}
# Pull pre-requisite packages for Windows using msys2 - VS19 installs skip this step
function xmrigger-packages-windows-msys2 () {
  pacman -S mingw-w64-x86_64-gcc git make
}

#####################
# compiler installs #
#####################

function edg-install-ubuntu () {
  sudo apt-get install software-properties-common
  sudo add-apt-repository ppa:rosecompiler/rose-development # Replace rose-development with rose-stable for release version
  sudo apt-get install rose
  #sudo apt-get install rose-tools # Optional: Installs ROSE tools in addition to ROSE Core
}

function edg-install-centos7 () {
  echo "
  [rose-develop]
  name = rose-rpm-repo
  baseurl = http://rosecompiler.org/uploads/repos/rhel/7/develop
  gpgcheck = 0
  enabled = 1

  [rose-dependencies]
  name = rose-dependencies-rpm-repo
  baseurl = http://rosecompiler.org/uploads/repos/rhel/7/dependencies
  gpgcheck = 0
  enabled = 1
  " > /etc/yum.repos.d/rose.repo
  yum update
  yum install rose -y
}

function edg-install-centos7 () {
  echo "
  [rose-develop]
  name = rose-rpm-repo
  baseurl = http://rosecompiler.org/uploads/repos/rhel/7/develop
  gpgcheck = 0
  enabled = 1
  " > /etc/yum.repos.d/rose.repo
  yum update
  yum install rose -y
}

function gcc-install-hp-ux () {
	swinstall autoconf bison db flex gawk gdbm gettext libiconv m4 make perl sed tcltk termcap texinfo wget zip zlib
	cd /tmp && wget http://hpux.connect.org.uk/hppd/cgi-bin/search?package=&term=/gcc- && cd gcc
	# needs fleshing out, is an obscure system that I'll get back to later
}

function gcc-install-macos () {
	# brew is a prerequisite - doesn't have to be but it's easier and cleaner this way
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
	brew install gcc
}
### Optional rose test build:
#git clone https://github.com/LLNL/backstroke.git
#cd backstroke
#make
#sudo make install
#make check

### clang compatibility for Ubuntu
# 12.04 - clang
# 14.04 - clang: 3.3, 3.4, 3.5
# 16.04 - clang: 3.5, 3.6, 3.7, 3.8, 6.0 - noting that some users report greater success with 3.8
# 17.04 - clang: 6.0
# 18.04 - clang: 6.0

### gcc compatibility for Ubuntu
# 18.04 - gcc-6, gcc-7, gcc-9

### gcc + clang for Ubuntu 16.04
# apt-add-repository "deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial-6.0 main"
# apt-get install -y clang-6.0 lld-6.0
#
### gcc + clang for Ubuntu 17.04
# apt-add-repository "deb http://apt.llvm.org/artful/ llvm-toolchain-artful-6.0 main"
# apt-get install -y clang-6.0 lld-6.0
### gcc + clang for Ubuntu 18.04
# apt-add-repository "deb http://apt.llvm.org/bionic/ llvm-toolchain-bionic-6.0 main"
# apt-get install -y clang-6.0 lld-6.0

### llvm for debian stretch 9
#deb http://apt.llvm.org/stretch/ llvm-toolchain-stretch main
#deb-src http://apt.llvm.org/stretch/ llvm-toolchain-stretch main
# 10 
#deb http://apt.llvm.org/stretch/ llvm-toolchain-stretch-10 main
#deb-src http://apt.llvm.org/stretch/ llvm-toolchain-stretch-10 main
# 11 
#deb http://apt.llvm.org/stretch/ llvm-toolchain-stretch-11 main
#deb-src http://apt.llvm.org/stretch/ llvm-toolchain-stretch-11 main

### llvm for debian buster 10
#deb http://apt.llvm.org/buster/ llvm-toolchain-buster main
#deb-src http://apt.llvm.org/buster/ llvm-toolchain-buster main
# 10 
#deb http://apt.llvm.org/buster/ llvm-toolchain-buster-10 main
#deb-src http://apt.llvm.org/buster/ llvm-toolchain-buster-10 main
# 11 
#deb http://apt.llvm.org/buster/ llvm-toolchain-buster-11 main
#deb-src http://apt.llvm.org/buster/ llvm-toolchain-buster-11 main

### llvm for Ubuntu 16.04 xenial
#deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial main
#deb-src http://apt.llvm.org/xenial/ llvm-toolchain-xenial main
# 10
#deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial-10 main
#deb-src http://apt.llvm.org/xenial/ llvm-toolchain-xenial-10 main
# 11
#deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial-11 main
#deb-src http://apt.llvm.org/xenial/ llvm-toolchain-xenial-11 main

## llvm for ubuntu 18.04 bionic LTS
# i386 not available
#deb http://apt.llvm.org/bionic/ llvm-toolchain-bionic main
#deb-src http://apt.llvm.org/bionic/ llvm-toolchain-bionic main
# 10
#deb http://apt.llvm.org/bionic/ llvm-toolchain-bionic-10 main
#deb-src http://apt.llvm.org/bionic/ llvm-toolchain-bionic-10 main
# 11
#deb http://apt.llvm.org/bionic/ llvm-toolchain-bionic-11 main
#deb-src http://apt.llvm.org/bionic/ llvm-toolchain-bionic-11 main

### llvm for ubuntu 20.04 lts
# i386 not available
#deb http://apt.llvm.org/focal/ llvm-toolchain-focal main
#deb-src http://apt.llvm.org/focal/ llvm-toolchain-focal main
# 10
#deb http://apt.llvm.org/focal/ llvm-toolchain-focal-10 main
#deb-src http://apt.llvm.org/focal/ llvm-toolchain-focal-10 main
# 11
#deb http://apt.llvm.org/focal/ llvm-toolchain-focal-11 main
#deb-src http://apt.llvm.org/focal/ llvm-toolchain-focal-11 main

### llvm for ubuntu 20.10 groovy
# i386 not available
#deb http://apt.llvm.org/groovy/ llvm-toolchain-groovy main
#deb-src http://apt.llvm.org/groovy/ llvm-toolchain-groovy main
# 10
#deb http://apt.llvm.org/groovy/ llvm-toolchain-groovy-10 main
#deb-src http://apt.llvm.org/groovy/ llvm-toolchain-groovy-10 main
# 11
#deb http://apt.llvm.org/groovy/ llvm-toolchain-groovy-11 main
#deb-src http://apt.llvm.org/groovy/ llvm-toolchain-groovy-11 main

### llvm for ubuntu 21.04 Hirsute
# i386 not available
#deb http://apt.llvm.org/hirsute/ llvm-toolchain-hirsute main
#deb-src http://apt.llvm.org/hirsute/ llvm-toolchain-hirsute main
# 10
#deb http://apt.llvm.org/hirsute/ llvm-toolchain-hirsute-10 main
#deb-src http://apt.llvm.org/hirsute/ llvm-toolchain-hirsute-10 main
# 11
#deb http://apt.llvm.org/hirsute/ llvm-toolchain-hirsute-11 main
#deb-src http://apt.llvm.org/hirsute/ llvm-toolchain-hirsute-11 main

### recommended default llvm packages
# clang-format clang-tidy clang-tools clang clangd libc++-dev libc++1 libc++abi-dev libc++abi1 libclang-dev libclang1 liblldb-dev libllvm-ocaml-dev libomp-dev libomp5 lld lldb llvm-dev llvm-runtime llvm python-clang

####################
# Clone XMRig repo #
####################

# Clone XMRig repo - Linux generic - clean dir
function xmr-clone-repo-clean () { 
  cd $XMRIG_DIR
  rm -rf $XMRIG_DIR/xmrig/ # nukes any broken/existing installations
  git clone https://github.com/xmrig/xmrig.git
  mkdir xmrig/build && cd xmrig/build
}

# Clone XMRig repo - Linux generic - no clean
function xmr-clone-repo () { 
  cd $XMRIG_DIR && git clone https://github.com/xmrig/xmrig 
}

###########################
# OS-specific cmake flags #
###########################

# Injecting os-specific flags for cmake
function config-cmake-alpine () { 
  CMAKE_ARGS=$CMAKE_ARGS
}
function config-cmake-centos7 () { 
  CMAKE_ARGS=$CMAKE_ARGS
}
function config-cmake-centos8 () { 
  CMAKE_ARGS=$CMAKE_ARGS
}
function config-cmake-fedora () { 
  CMAKE_ARGS=$CMAKE_ARGS
}
function config-cmake-freebsd () { 
  CMAKE_ARGS=$CMAKE_ARGS
}
function config-cmake-macos () { 
  CMAKE_ARGS=$CMAKE_ARGS"-DOPENSSL_ROOT_DIR=OSX_OPENSSL_DIR" 
}
function config-cmake-ubuntu () { 
  # Below looks to cause issues if invoked by default on an arm-variant CPU arch
  # CMAKE_ARGS=$CMAKE_ARGS' -DCMAKE_SYSTEM_NAME=Linux' 
  echo "Bash hates empty functions - holding the fort until this works again"
}
function config-cmake-windows-msys2 () { 
  CMAKE_ARGS=$CMAKE_ARGS"-G Visual Studio 16 2019 -A x64 -DXMRIG_DEPS='$MSYS_GCC_64_DIR'" 
}
function config-cmake-windows-vs2019 () { 
  CMAKE_ARGS=$CMAKE_ARGS' -G "Visual Studio 16 2019" -A x64 -DXMRIG_DEPS="$MSVS2019_XMRIGDEPS_DIR"' 
}
function config-cmake-windows-vs2019-cuda-support () { 
  CMAKE_ARGS=$CMAKE_ARGS' -G "Visual Studio 16 2019" -A x64 -DCUDA_TOOLKIT_ROOT_DIR="$CUDA_TOOLKIT_DIR"' 
}

#############################
# Arch-specific cmake flags #
#############################

# Injecting cpu-arch arguments for cmake
function config-cmake-arm8 () { 
  CMAKE_ARGS=$CMAKE_ARGS' -DCMAKE_SYSTEM_PROCESSOR=arm -DWITH_RANDOMX=OFF -DARM_TARGET=8' #randomx currently causes compile issues on ARM systems, bug fix pending from official xmrig repo
}
function config-cmake-arm7 () { 
  CMAKE_ARGS=$CMAKE_ARGS' -DCMAKE_SYSTEM_PROCESSOR=arm -DWITH_RANDOMX=OFF -DARM_TARGET=7' #randomx currently causes compile issues on ARM systems, bug fix pending from official xmrig repo
}
function config-cmake-x86 () {
  CMAKE_ARGS=$CMAKE_ARGS' -DCMAKE_BUILD_TYPE=release32'
}
function config-cmake-x64 () {
  CMAKE_ARGS=$CMAKE_ARGS' -DCMAKE_GENERATOR_PLATFORM=x64'
}

# Will produce a 32-bit binary out for OSX
function config-cmake-osx-i386 () { 
  CMAKE_ARGS=$CMAKE_ARGS' -DCMAKE_OSX_ARCHITECTURES=i386' 
}

# Will produce a 64-bit binary out for OSX
function config-cmake-osx-64 () { 
  CMAKE_ARGS=$CMAKE_ARGS' -DCMAKE_OSX_ARCHITECTURES=x86_64' 
}

# Will produce a 96-bit universal binary out for OSX
function config-cmake-osx-96 () { 
  CMAKE_ARGS=$CMAKE_ARGS' -DCMAKE_OSX_ARCHITECTURES=x86_64;i386' 
}

#########################################
# setting compilers for cmake execution #
#########################################

function set-cmake-c-compiler () {
  CMAKE_ARGS=$CMAKE_ARGS' -DCMAKE_C_COMPILER=$SELECTED_C_COMPILER'
}

function set-cmake-cxx-compiler () {
  CMAKE_ARGS=$CMAKE_ARGS' -DCMAKE_CXX_COMPILER=$SELECTED_CXX_COMPILER'
}

##########################
# Cmake execution - pray #
##########################

# Execute cmake and pray
function execute-cmake-generic () { 
  #something broke here, breakpoint
  echo "cmake .. $CMAKE_ARGS"
  cmake .. $CMAKE_ARGS 
}

# Execute cmake for VS2019
function execute-cmake-vs2019 () { 
  cmake --build . --config Release 
}

##################
# make functions #
##################

# Execute make with generic nproc arg - for Alpine, Arch, Centos7, Centos8, Debian, Fedora, Manjaro, Ubuntu Windows /w MSYS2
function execute-make-generic () {
  MAKE_CORE_COUNT=$(nproc)
  make -j$MAKE_CORE_COUNT
}

# Execute make with make with generic sysctl -n hw.ncpu - for FreeBSD
function execute-make-hw-ncpu-variants () {
  MAKE_CORE_COUNT=$(sysctl -n hw.ncpu)
  make -j$MAKE_CORE_COUNT
}

# Execute make with make with generic sysctl -n hw.logicalcpu - for MacOS
function execute-make-hw-logical-cpu-variants () {
  MAKE_CORE_COUNT=$(sysctl -n hw.logicalcpu)
  make -j$MAKE_CORE_COUNT
}

function set-package-manager () {
	if [[ $SELECTED_COMPILE_OS=="alpine" ]]
  then
    PACKAGE_MANAGER="apk"
  elif [[ $SELECTED_COMPILE_OS=="arch" ]] || [[ $SELECTED_COMPILE_OS=="manjaro" ]] || [[ $SELECTED_COMPILE_OS=="windows-msys2" ]]
  then
    PACKAGE_MANAGER="pacman"
  elif [[ $SELECTED_COMPILE_OS=="centos6" ]] || [[ $SELECTED_COMPILE_OS=="centos7" ]] || [[ $SELECTED_COMPILE_OS=="centos8" ]]
  then
    PACKAGE_MANAGER="yum"
  elif [[ $SELECTED_COMPILE_OS=="fedora" ]]
  then
    PACKAGE_MANAGER="dnf"
  elif [[ $SELECTED_COMPILE_OS=="freebsd" ]]
  then
    PACKAGE_MANAGER="pkg"
  elif [[ $SELECTED_COMPILE_OS=="macos" ]]
  then
    PACKAGE_MANAGER="brew"
  elif [[ $SELECTED_COMPILE_OS=="ubuntu" ]]
  then
    PACKAGE_MANAGER="apt-get"
  fi
}

#####################################
# copy config.json into working dir #
#####################################

function configure-profile () {
  cp $CONFIG_FILE $XMRIG_DIR/xmrig/build/ 
  echo ""
  echo "# config file loaded from $CONFIG_FILE" #
  echo ""
} # this function doesn't actually create a json file, it just copies it to where it needs to go

######################
# compiler functions #
######################

function set-c-compiler () {
  CMAKE_ARGS=$CMAKE_ARGS' -DCMAKE_C_COMPILER=$C_COMPILER'
}

function set-cxx-compiler () {
  CMAKE_ARGS=$CMAKE_ARGS' -DCMAKE_CXX_COMPILER=$CXX_COMPILER'
}

###############################################################################
# Main program function - put functs here so that the computer goes beep boop #
###############################################################################

function main () {
  intro-text
  help-text
  set-package-manager
  config-cmake-$SELECTED_COMPILE_ARCH
  config-cmake-$SELECTED_COMPILE_OS
  set-cmake-c-compiler
  set-cmake-cxx-compiler
  if [[ $save =~ s ]] || [[ $save =~ S ]]
  then
	swapfile-generic
  else
  configure-profile
  if [[ $save =~ pb ]]
  then
    post-rig.sh -bs #basic start
  elif [[ $save =~ ps ]]
  then
    post-rig.sh -ss #silent start - starts in a detatched screen, has dependency on screen
  fi
  fi
}

main
