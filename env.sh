#Detect the path to the top of the repo from which we are calling the script
export REPOROOT=$( cd $(dirname "$0"); pwd -P)

#Add our scripts to the path
if [ -z ${OLD_PATH+x} ]; then
    export OLD_PATH=$PATH;
else
    export PATH=$OLD_PATH;
fi
export PATH="$REPOROOT/tools/scripts:$PATH"

#Specify the path f the rtl and testbenches
export RTLROOT="$REPOROOT/src"
export TBROOT="$REPOROOT/tb"

#Pull docker image if necessary
export DOCKERTAG="jsola/verilator:latest"
if [[ "$(docker images -q $DOCKERTAG 2> /dev/null)" == "" ]]; then
    docker pull $DOCKERTAG
fi

