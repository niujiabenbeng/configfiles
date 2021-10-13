#! /bin/bash

cd $(dirname $0)

THREADS=16
ROOT=${PWD}
CACHE=${ROOT}/.cache
TOOLS=${HOME}/Documents/tools
mkdir -p ${ROOT} ${CACHE} ${TOOLS}

download_file() {
    URL=$1
    MD5=$3
    FILE=${CACHE}/$2
    if [ ! -e $FILE ]; then
        wget -O ${FILE} ${URL}
    fi
    echo "$MD5 ${FILE}" | md5sum -c --status
    if [ $? -ne 0 ]; then
        echo "Failed to check md5sum: ${FILE}" && exit
    fi
}

install_from_source_emacs() {
    if [ -e ${TOOLS}/emacs ]; then
        echo "emacs has already been installed." && return 0
    fi

    URL="https://ainfinit-basic.oss-cn-beijing.aliyuncs.com/3rdparty/source/emacs-27.2.tar.gz"
    NAME="emacs-27.2.tar.gz"
    MD5="6c7f1583d043fffff8dc892a1f8f7b83"
    download_file ${URL} ${NAME} ${MD5}

    TEMP=${NAME%.tar.gz}
    cd ${CACHE} && tar zxf ${NAME} && cd ${TEMP}
    sudo apt install -y texinfo libx11-dev libxpm-dev libjpeg-dev
    sudo apt install -y libgif-dev libtiff-dev libgtk2.0-dev
    sudo apt install -y libxpm-dev libpng-dev libncurses-dev
    ./configure --with-gnutls=ifavailable --prefix=${TOOLS}/emacs
    make -j${THREADS} && make install
}

install_from_source_jpeg_turbo() {
    if [ -e ${TOOLS}/jpeg-turbo ]; then
        echo "jpeg-turbo has already been installed." && return 0
    fi

    URL="https://ainfinit-basic.oss-cn-beijing.aliyuncs.com/3rdparty/source/libjpeg-turbo-2.1.1.tar.gz"
    NAME="libjpeg-turbo-2.1.1.tar.gz"
    MD5="167d52e2348b6f1af33c70f63197edd8"
    download_file ${URL} ${NAME} ${MD5}

    TEMP=${NAME%.tar.gz}
    cd ${CACHE} && tar zxf ${NAME} && cd ${TEMP}
    sudo apt install -y nasm
    mkdir -p build && cd build
    cmake -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
          -DCMAKE_INSTALL_PREFIX=${TOOLS}/jpeg-turbo \
          ..
    make -j${THREADS} && make install
}

install_from_source_opencv() {
    if [ -e ${TOOLS}/opencv ]; then
        echo "opencv has already been installed." && return 0
    fi

    if [ ! -e ${TOOLS}/jpeg-turbo ]; then
        echo "opencv should be built with jpeg-turbo." && return 0
    fi

    URL="https://ainfinit-basic.oss-cn-beijing.aliyuncs.com/3rdparty/source/opencv-3.4.2.tar.gz"
    NAME="opencv-3.4.2.tar.gz"
    MD5="6994297929398dd6ac86857e2c938076"
    download_file ${URL} ${NAME} ${MD5}

    TEMP=${NAME%.tar.gz}
    cd ${CACHE} && tar zxf ${NAME} && cd ${TEMP}
    sudo apt install -y libswresample-dev libswscale-dev libgtk2.0-dev
    mkdir -p build && cd build
    cmake -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
          -DCMAKE_INSTALL_PREFIX=${TOOLS}/opencv \
          -DWITH_JPEG=ON \
          -DBUILD_JPEG=OFF \
          -DJPEG_INCLUDE_DIR=${TOOLS}/jpeg-turbo/include \
          -DJPEG_LIBRARY=${TOOLS}/jpeg-turbo/lib/libjpeg.a \
          -DBUILD_JAVA=OFF \
          -DBUILD_PACKAGE=OFF \
          -DBUILD_PERF_TESTS=OFF \
          -DBUILD_TESTS=OFF \
          -DBUILD_opencv_apps=OFF \
          -DBUILD_opencv_dnn=OFF \
          -DBUILD_opencv_java_bindings_gen=OFF \
          -DBUILD_opencv_python2=OFF \
          -DBUILD_opencv_python_bindings_generator=OFF \
          -DOPENCV_DNN_OPENCL=OFF \
          -DWITH_CUFFT=OFF \
          ..
    make -j${THREADS} && make install
}

install_from_source_protobuf() {
    if [ -e ${TOOLS}/protobuf ]; then
        echo "protobuf has already been installed." && return 0
    fi

    URL="https://ainfinit-basic.oss-cn-beijing.aliyuncs.com/3rdparty/source/protobuf-cpp-3.5.1.tar.gz"
    NAME="protobuf-3.5.1.tar.gz"
    MD5="ca0d9b243e649d398a6b419acd35103a"
    download_file ${URL} ${NAME} ${MD5}

    TEMP=${NAME%.tar.gz}
    cd ${CACHE} && tar zxf ${NAME} && cd ${TEMP}
    sudo apt install autoconf automake libtool curl make g++ unzip
    ./configure --prefix=${TOOLS}/protobuf
    make -j${THREADS} && make install
}

install_from_source_boost() {
    if [ -e ${TOOLS}/boost ]; then
        echo "boost has already been installed." && return 0
    fi

    URL="https://ainfinit-basic.oss-cn-beijing.aliyuncs.com/3rdparty/source/boost_1_59_0.tar.gz"
    NAME="boost_1_59_0.tar.gz"
    MD5="51528a0e3b33d9e10aaa311d9eb451e3"
    download_file ${URL} ${NAME} ${MD5}

    TEMP=${NAME%.tar.gz}
    cd ${CACHE} && tar zxf ${NAME} && cd ${TEMP}
    ./bootstrap.sh --prefix=${TOOLS}/boost
    ./b2 cxxflags=-fPIC cflags=-fPIC --build-dir=build -j${THREADS} variant=release install
}

install_from_source_oss() {
    if [ -e ${TOOLS}/aliyun ]; then
        echo "oss has already been installed." && return 0
    fi

    URL="https://ainfinit-basic.oss-cn-beijing.aliyuncs.com/3rdparty/source/aliyun-oss-cpp-sdk-1.9.0.tar.gz"
    NAME="aliyun-oss-cpp-sdk-1.9.0.tar.gz"
    MD5="fad795d796a2dd22eb91b0eb76a68498"
    download_file ${URL} ${NAME} ${MD5}

    TEMP=${NAME%.tar.gz}
    cd ${CACHE} && tar zxf ${NAME} && cd ${TEMP}
    sudo apt install -y libcurl4-openssl-dev libssl-dev

    mkdir -p build && cd build
    cmake -DBUILD_SHARED_LIBS=ON \
          -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
          -DCMAKE_INSTALL_PREFIX=${TOOLS}/aliyun \
          -DTARGET_OUTPUT_NAME_PREFIX=oss- ..
    make -j${THREADS} && make install
}

install_from_source_date() {
    if [ -e ${TOOLS}/date ]; then
        echo "date has already been installed." && return 0
    fi

    URL="https://ainfinit-basic.oss-cn-beijing.aliyuncs.com/3rdparty/source/date-3.0.0.tar.gz"
    NAME="date-3.0.0.tar.gz"
    MD5="c76681532f87644c59c19938961bc85c"
    download_file ${URL} ${NAME} ${MD5}

    TEMP=${NAME%.tar.gz}
    cd ${CACHE} && tar zxf ${NAME} && cd ${TEMP}

    mkdir -p build && cd build
    cmake -DBUILD_TZ_LIB=ON \
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
        -DCMAKE_INSTALL_PREFIX=${TOOLS}/date ..
    make -j${THREADS} && make install
}

install_from_source_gtest() {
    if [ -e /usr/local/lib/libgtest.a ]; then
       echo "gtest has already been installed." && return 0
    fi

    URL="https://ainfinit-basic.oss-cn-beijing.aliyuncs.com/3rdparty/source/googletest-release-1.8.1.tar.gz"
    NAME="googletest-release-1.8.1.tar.gz"
    MD5="2e6fbeb6a91310a16efe181886c59596"
    download_file ${URL} ${NAME} ${MD5}

    TEMP=${NAME%.tar.gz}
    cd ${CACHE} && tar zxf ${NAME} && cd ${TEMP}

    mkdir -p build && cd build
    cmake .. && make -j${THREADS} && sudo make install
}

install_from_source_emacsd() {
    url=https://github.com/niujiabenbeng/prelude.git
    if [ -e ${HOME}/.emacs.d ]; then
        echo ".emacs.d has already been installed."
    else
        git clone ${url} ${HOME}/.emacs.d
    fi
}

install_from_source_ohmyzsh() {
    url=https://github.com/robbyrussell/oh-my-zsh.git
    if [ -e ${HOME}/.oh-my-zsh ]; then
        echo ".oh-my-zsh has already been installed."
    else
        git clone ${url} ${HOME}/.oh-my-zsh
    fi
}

################################################################################
################################################################################
################################################################################

# step 1: install tools
sudo apt update
sudo apt install -y build-essential
sudo apt install -y automake autoconf pkg-config
sudo apt install -y git wget curl cmake zsh cmake-curses-gui openssh-server

# step 2: install deps
sudo apt install -y libgoogle-glog-dev libgflags-dev
sudo apt install -y libjsoncpp-dev libcurl4-openssl-dev libfreetype6-dev
sudo apt install -y libavcodec-dev libavdevice-dev libavfilter-dev
sudo apt install -y libavformat-dev libavresample-dev libavutil-dev
sudo apt install -y libpostproc-dev libswscale-dev libopenblas-dev

# step 3: install packages
# install_from_source_jpeg_turbo
# install_from_source_opencv
# install_from_source_protobuf
# install_from_source_boost
# install_from_source_oss
# install_from_source_date
# install_from_source_gtest

# optional: configure environment
install_from_source_emacs
install_from_source_emacsd
install_from_source_ohmyzsh
