#! /bin/bash

curr_dir=$(dirname $(realpath $0))
proj_dir=$(dirname ${curr_dir})

setup_config() {
    src_dir=$1
    dst_dir=$2
    src_name=$3
    dst_name=$3
    if [[ ${dst_name} =~ ^dot\..* ]]; then
        dst_name=${dst_name:3};
    fi

    src_path=${src_dir}/${src_name}
    dst_path=${dst_dir}/${dst_name}
    if [ -L ${dst_path} ]; then
        unlink ${dst_path}
    fi
    if [ -f ${dst_path} ]; then
        echo "file exists: ${dst_path}"
    else
        ln -s ${src_path} ${dst_path}
    fi
}

# setup dot files
setup_config ${proj_dir}/config ${HOME} dot.bashrc
setup_config ${proj_dir}/config ${HOME} dot.condarc
setup_config ${proj_dir}/config ${HOME} dot.git-credentials
setup_config ${proj_dir}/config ${HOME} dot.gitconfig
setup_config ${proj_dir}/config ${HOME} dot.zshrc

# setup oh-my-zsh
ohmyzsh_src=${proj_dir}/config/oh-my-zsh
ohmyzsh_dst=${HOME}/.oh-my-zsh/custom
setup_config ${ohmyzsh_src} ${ohmyzsh_dst} functions.zsh
setup_config ${ohmyzsh_src} ${ohmyzsh_dst} settings.zsh
setup_config ${ohmyzsh_src} ${ohmyzsh_dst} inputrc.zsh
setup_config ${ohmyzsh_src} ${ohmyzsh_dst}/themes personal.zsh-theme
