CONFIG_ARGS="--enable-optimized --enable-targets=x86,js --enable-libcpp --disable-jit --disable-threads --disable-pthreads --disable-assertions --enable-cxx11 --enable-bindings=no --disable-zlib"
if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters"
    exit 1
fi
# Override by setting EMSCRIPTEN environment variable
EMSCRIPTEN_ROOT=$(python -c 'import os; import imp; print imp.load_source("", os.path.expanduser("~/.emscripten")).EMSCRIPTEN_ROOT')
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
LLVMDIR=$( cd "$1" && pwd )
echo "Running from $SCRIPTDIR"
echo "Using emscripten in $EMSCRIPTEN_ROOT"
if [ -z "$LLVMDIR" ]; then
    echo "Specify a path to an llvm or fastcomp source tree"
    exit 1
fi
echo "llvm is in $LLVMDIR"
if [ -d "$LLVMDIR/emscripten-build" ]; then
    echo "Please sudo rm -rf $LLVMDIR/emscripten-build."
    exit 1
fi
echo "Building build tools ..."
mkdir -p $LLVMDIR/tool-build &&
cd $LLVMDIR/tool-build &&
../configure $CONFIG_ARGS &&
BUILD_DIRS_ONLY=1 make -j4 || exit 1

echo "Building Bitcode of llvm tools ..."
mkdir -p $LLVMDIR/emscripten-build &&
cd $LLVMDIR/emscripten-build &&
$EMSCRIPTEN_ROOT/emconfigure ../configure $CONFIG_ARGS --with-extra-options=-Wno-warn-absolute-paths || exit 2
#sed -e '/HAVE_ARC4RANDOM/ s?^?//?' -i .bak include/llvm/Config/config.h
mkdir -p Release/bin &&
cp ../tool-build/Release/bin/* Release/bin &&
chflags uchg Release/bin/* || exit 1
cp $SCRIPTDIR/stdio.h include &&
curl https://raw.githubusercontent.com/kripken/Relooper/master/ministring.h > include/ministring.h &&
$EMSCRIPTEN_ROOT/emmake make -i -j4 #&> /dev/null

echo "Copying tools to bitcode-for-js"
rm -rf $SCRIPTDIR/bitcode-for-js
mkdir -p $SCRIPTDIR/bitcode-for-js &&
find $LLVMDIR/emscripten-build/Release/bin -maxdepth 1 -not -perm -111 -not -name ".*" -type f -exec basename {} \;| xargs -I% cp $LLVMDIR/emscripten-build/Release/bin/% $SCRIPTDIR/bitcode-for-js/%.bc

