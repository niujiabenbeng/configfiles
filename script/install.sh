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

install_emacs_from_source() {
    if [ -e ${TOOLS}/emacs ]; then
        echo "emacs has already been installed." && return 0
    fi

    URL="https://mirrors.ustc.edu.cn/gnu/emacs/emacs-27.2.tar.gz"
    NAME="emacs-27.2.tar.gz"
    MD5="6c7f1583d043fffff8dc892a1f8f7b83"
    download_file ${URL} ${NAME} ${MD5}

    TEMP=${NAME%.tar.gz}
    cd ${CACHE} && tar zxvf ${NAME} && cd ${TEMP}
    sudo apt install -y texinfo libx11-dev libxpm-dev libjpeg-dev
    sudo apt install -y libgif-dev libtiff-dev libgtk2.0-dev
    sudo apt install -y libxpm-dev libpng-dev libncurses-dev
    ./configure --with-gnutls=ifavailable --prefix=${TOOLS}/emacs
    make -j${THREADS} && make install
}

install_opencv_from_source() {
    if [ -e ${TOOLS}/opencv ]; then
        echo "opencv has already been installed." && return 0
    fi

    URL="https://github.com/opencv/opencv/archive/3.4.2.zip"
    NAME="opencv-3.4.2.zip"
    MD5="9e9ebe9c1fe98c468f6e53f5c3c49716"
    download_file ${URL} ${NAME} ${MD5}

    TEMP=${NAME%.zip}
    cd ${CACHE} && unzip ${NAME} && cd ${TEMP}
    sudo apt install -y libavcodec-dev libavdevice-dev libavfilter-dev \
        libavformat-dev libavresample-dev libavutil-dev libpostproc-dev \
        libswresample-dev libswscale-dev libgtk2.0-dev
    mkdir -p build && cd build
    cmake -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_INSTALL_PREFIX=${TOOLS}/opencv \
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

install_jpeg_turbo_from_source() {
    if [ -e ${TOOLS}/jpeg-turbo ]; then
        echo "jpeg-turbo has already been installed." && return 0
    fi

    URL="https://github.com/libjpeg-turbo/libjpeg-turbo/archive/2.0.0.tar.gz"
    NAME="libjpeg-turbo-2.0.0.tar.gz"
    MD5="e643c8cafdf5c40567fa11b2c0f4c20c"
    download_file ${URL} ${NAME} ${MD5}

    TEMP=${NAME%.tar.gz}
    cd ${CACHE} && tar zxvf ${NAME} && cd ${TEMP}
    sudo apt install -y nasm
    mkdir -p build && cd build
    cmake -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_INSTALL_PREFIX=${TOOLS}/jpeg-turbo \
          ..
    make -j${THREADS} && make install
}

install_protobuf_from_source() {
    if [ -e ${TOOLS}/protobuf ]; then
        echo "protobuf has already been installed." && return 0
    fi

    URL="https://github.com/protocolbuffers/protobuf/releases/download/v3.5.1/protobuf-cpp-3.5.1.tar.gz"
    NAME="protobuf-3.5.1.tar.gz"
    MD5="ca0d9b243e649d398a6b419acd35103a"
    download_file ${URL} ${NAME} ${MD5}

    TEMP=${NAME%.tar.gz}
    cd ${CACHE} && tar zxvf ${NAME} && cd ${TEMP}
    sudo apt install autoconf automake libtool curl make g++ unzip
    ./configure --prefix=${TOOLS}/protobuf
    make -j${THREADS} && make install
}

install_boost_from_source() {
    if [ -e ${TOOLS}/boost ]; then
        echo "boost has already been installed." && return 0
    fi

    URL="https://ayera.dl.sourceforge.net/project/boost/boost/1.59.0/boost_1_59_0.tar.gz"
    NAME="boost_1_59_0.tar.gz"
    MD5="51528a0e3b33d9e10aaa311d9eb451e3"
    download_file ${URL} ${NAME} ${MD5}

    TEMP=${NAME%.tar.gz}
    cd ${CACHE} && tar zxvf ${NAME} && cd ${TEMP}
    ./bootstrap.sh --prefix=${TOOLS}/boost
    ./b2 cxxflags=-fPIC cflags=-fPIC --build-dir=build -j${THREADS} variant=release install
}

install_ffmpeg_from_source() {
    if [ -e ${TOOLS}/ffmpeg ]; then
        echo "ffmpeg has already been installed." && return 0
    fi

    URL="https://ffmpeg.org/releases/ffmpeg-3.4.5.tar.bz2"
    NAME="ffmpeg-3.4.5.tar.bz2"
    MD5="1c608d4b8cf7f1f5e0dbe7a795ae7f5b"
    download_file ${URL} ${NAME} ${MD5}

    TEMP=${NAME%.tar.bz2}
    cd ${CACHE} && tar jxvf ${NAME} && cd ${TEMP}
    sudo apt install autoconf automake build-essential libtool libass-dev
    sudo apt install libfreetype6-dev libvorbis-dev texinfo zlib1g-dev
    sudo apt install nasm yasm libx264-dev libx265-dev libnuma-dev libvpx-dev
    sudo apt install libfdk-aac-dev libmp3lame-dev libopus-dev
    ### compile with shared & -fpic
    ./configure \
        --enable-shared \
        --extra-cflags="-fPIC" \
        --prefix=${TOOLS}/ffmpeg \
        --enable-gpl \
        --enable-libfdk-aac \
        --enable-libfreetype \
        --enable-libmp3lame \
        --enable-libopus \
        --enable-libvpx \
        --enable-libx264 \
        --enable-libx265 \
        --enable-nonfree
    make -j${THREADS} && make install
}

install_emacsd_from_source() {
    url=https://github.com/niujiabenben/prelude.git
    if [ -e ${HOME}/.emacs.d ]; then
        echo ".emacs.d has already been installed."
    else
        git clone ${url} ${HOME}/.emacs.d
    fi
}

install_ohmyzsh_from_source() {
    url=https://github.com/robbyrussell/oh-my-zsh.git
    if [ -e ${HOME}/.oh-my-zsh ]; then
        echo ".oh-my-zsh has already been installed."
    else
        git clone ${url} ${HOME}/.oh-my-zsh
    fi
}

install_from_source() {
    if [ "$1" == "emacs" ]; then
        install_emacs_from_source
    elif [ "$1" == "emacsd" ]; then
        install_emacsd_from_source
    elif [ "$1" == "ohmyzsh" ]; then
        install_ohmyzsh_from_source
    elif [ "$1" == "opencv" ]; then
        install_opencv_from_source
    elif [ "$1" == "jpeg_turbo" ]; then
        install_jpeg_turbo_from_source
    elif [ "$1" == "protobuf" ]; then
        install_protobuf_from_source
    elif [ "$1" == "boost" ]; then
        install_boost_from_source
    elif [ "$1" == "ffmpeg" ]; then
        install_ffmpeg_from_source
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
sudo apt install -y libpostproc-dev libswscale-dev

# step 3: install packages
install_from_source emacs
install_from_source emacsd
install_from_source ohmyzsh
# install_from_source opencv
# install_from_source jpeg_turbo
# install_from_source protobuf
# install_from_source boost
# install_from_source ffmpeg
