export REPOROOT="$( cd "$(dirname "$0")"; pwd -P)"

if [ -z ${OLD_PATH+x} ]; then
    export OLD_PATH=$PATH;
else
    export PATH=$OLD_PATH;
fi

export PATH="$REPOROOT/tools/scripts:$PATH"
export RTLROOT="$REPOROOT/src"
export TBROOT="$REPOROOT/tb"
export DOCKERTAG="jsola/verilator:latest"
if [[ "$(docker images -q $DOCKERTAG 2> /dev/null)" == "" ]]; then
    docker pull $DOCKERTAG
fi

#alias verilator='docker run -w $REPOROOT -v $REPOROOT:$REPOROOT --name=tmp_container --rm $DOCKERTAG bash verilator'
alias cleanup='rm -rf $REPOROOT/obj_dir'
