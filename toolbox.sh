#!/usr/bin/env sh

gdb="/bin/gdb" # For using a gdb build such as the cathook one (The one included)
libname="libEGL_nvidia.so" # Pretend to be gamemode, change this to another lib that may be in /maps (if already using real gamemode, I'd suggest using libMangoHud.so)
csgo_pid=$(pidof csgo_linux64)

# Set to true to compile with clang. (if changing to true, make sure to delete the build directory from gcc)
export USE_CLANG="false"

if [[ $EUID -eq 0 ]]; then
    echo "You cannot run this as root."
    exit 1
fi

sudo rm -rf /tmp/dumps
sudo mkdir -p --mode=000 /tmp/dumps

function load {
    echo "Loading cheat..."
    echo 2 | sudo tee /proc/sys/kernel/yama/ptrace_scope > /dev/null
    sudo cp ./build/libOsiris.so /usr/lib/$libname
    gdbOut=$(
      sudo $gdb -n -q -batch \
      -ex "set auto-load safe-path /usr/lib/" \
      -ex "attach $csgo_pid" \
      -ex "set \$dlopen = (void*(*)(char*, int)) dlopen" \
      -ex "call \$dlopen(\"/usr/lib/$libname\", 1)" \
      -ex "detach" \
      -ex "quit" 2> /dev/null
    )
    lastLine="${gdbOut##*$'\n'}"
    if [[ "$lastLine" != "\$1 = (void *) 0x0" ]]; then
      echo "Successfully injected!"
    else
      echo "Injection failed, make sure you have compiled."
    fi
}

function load_debug {
    echo "Loading cheat..."
    echo 2 | sudo tee /proc/sys/kernel/yama/ptrace_scope
    sudo cp ./build_debug/libOsiris.so /usr/lib/$libname
    sudo $gdb -n -q -batch \
        -ex "set auto-load safe-path /usr/lib:/usr/lib/" \
        -ex "attach $csgo_pid" \
        -ex "set \$dlopen = (void*(*)(char*, int)) dlopen" \
        -ex "call \$dlopen(\"/usr/lib/$libname\", 1)" \
        -ex "detach" \
        -ex "quit"
    sudo $gdb -p "$csgo_pid"
    echo "Successfully loaded!"
}

function build {
    echo "Building cheat..."
    mkdir -p build
    cd build
    cmake -D CMAKE_BUILD_TYPE=Release ..
    make -j $(nproc --all)
    cd ..
}

function build_debug {
    echo "Building cheat..."
    mkdir -p build_debug
    cd build_debug
    cmake -D CMAKE_BUILD_TYPE=Debug ..
    make -j $(nproc --all)
    cd ..
}

function pull {
    git pull
}

while [[ $# -gt 0 ]]
do
keys="$1"
case $keys in
    -l|--load)
        load
        shift
        ;;
    -ld|--load_debug)
        load_debug
        shift
        ;;
    -b|--build)
        build
        shift
        ;;
    -bd|--build_debug)
        build_debug
        shift
        ;;
    -p|--pull)
        pull
        shift
        ;;
    -h|--help)
        echo "
 help
Toolbox script for osiris (gamesneeze the beste lincuck cheat 2021)
=======================================================================
| Argument             | Description                                  |
| -------------------- | -------------------------------------------- |
| -l (--load)          | Load/inject the cheat via gdb.               |
| -ld (--load_debug)   | Load/inject the cheat and debug via gdb.     |
| -b (--build)         | Build to the build/ dir.                     |
| -bd (--build_debug)  | Build to the build/ dir as debug.            |
| -p (--pull)          | Update the cheat.                            |
| -h (--help)          | Show help.                                   |
=======================================================================
All args are executed in the order they are written in, for
example, \"-p -b -l\" would update the cheat, build it, and
then load it back into csgo.
"
        exit
        ;;
    *)
        echo "Unknown arg $1, use -h for help"
        exit
        ;;
esac
done
