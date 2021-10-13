#! /bin/zsh

# Local Variables:
# eval: (editorconfig-mode -1)
# End:

# start emacs server if no emacs server is running
startemacs() {
    if [ $(ps xuf | grep emacs | wc -l) -gt 1 ]; then
        echo "emacs server is already started."
    else
        emacs --daemon
    fi
}

# kill emacs server if emacs server is running
killemacs() {
    if [ $(ps xuf | grep emacs | wc -l) -le 1 ]; then
        echo "emacs server is already killed."
    else
        ps xuf | grep emacs | grep -v grep | awk '{print $2}' | xargs -I {} kill -9 {}
   fi
}

# open file in emacsclient mode
e() {
    if [ $# -eq 0 ]; then
        emacsclient -t --eval "(emacs-client-load-session)"
    elif [ $# -gt 1 ]; then
        echo "command 'e' requires only one input."
    elif [ -f $1 ]; then
        emacsclient -t --eval "(emacs-client-init-find-file \"$1\" -1)"
    else
        echo "$1 is not a file."
    fi
}

# open file with read only mode
ev() {
    if [ $# -eq 0 ]; then
        emacsclient -t --eval "(emacs-client-load-session)"
    elif [ $# -gt 1 ]; then
        echo "command 'ev' requires only one input."
    elif [ -f $1 ]; then
        emacsclient -t --eval "(emacs-client-init-find-file \"$1\" 1)"
    else
        echo "$1 is not a file."
    fi
}

# avoid unintentional removal
rm() {
    realpwd=$(realpath "${PWD}")
    recycle=$(realpath "${HOME}/.recycle")
    ### if we are already in ${recycle}, we execute the original command
    if [[ "${realpwd}" == "${recycle}" ]] || [[ "${realpwd}" == "${recycle}"/* ]]; then
        /bin/rm $*
        return 0
    fi

    for i in $*; do
        if [[ $i != -* ]]; then
            stamp=`date +%Y-%m-%d`
            mkdir -p ${recycle}/${stamp}
            ### avoid name conflict
            name=`basename $i`
            dstpath=${recycle}/${stamp}/${name}
            count=2
            while [ -e ${dstpath} ]; do
                dstpath=${recycle}/${stamp}/${name}.${count}
                count=$((count + 1))
            done
            mv $i ${dstpath}
            ### unlink if necessary
            if [ -d ${dstpath} ]; then
                if [ `find ${dstpath} -type l | wc -l` -gt 0 ]; then
                    find ${dstpath} -type l | xargs -n1 unlink
                fi
            fi
        fi
    done
}

conn() {
    ssh ainfinit@tunnel.ainfinit.com -p $1
}

connt1() {
    ssh ainfinit@t1.ainfinit.com -p $1
}

scpp() {
    if [ $(cat /etc/hostname) = hairong_gpu_78 ]; then
        echo "scp -P 60022 chenli@120.192.147.88:$(realpath $1) ."
        echo "scp chenli@10.0.0.78:$(realpath $1) ."
    elif [ $(cat /etc/hostname) = hiron ]; then
        echo "scp -P 60028 chenli@120.192.147.88:$(realpath $1) ."
        echo "scp chenli@10.0.0.77:$(realpath $1) ."
    elif [ $(cat /etc/hostname) = Data_Tower ]; then
        echo "scp -P 60025 chenli@120.192.147.88:$(realpath $1) ."
        echo "scp chenli@10.0.0.79:$(realpath $1) ."
    else
        echo "unknown machine."
    fi
}
