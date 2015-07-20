SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
LLVMDIR=$( cd "$1" && pwd )
echo "Running from $SCRIPTDIR"
if [ -z "$LLVMDIR" ]; then
    echo "Specify a path to an llvm or fastcomp source tree"
    exit 1
fi
echo "llvm is in $LLVMDIR"
echo "Building build tools"
cd $LLVMDIR
mkdir tool-build
cd tool-build
../configure --enable-optimized --enable-targets=x86,js --enable-libcpp --disable-jit --disable-threads --disable-pthreads --disable-assertions --enable-cxx11 &> /dev/null &&
BUILD_DIRS_ONLY=1 make -j4 &> /dev/null || exit 1
cd ..

echo "Building Bitcode of llvm tools"
mkdir emscripten-build
cd emscripten-build
emconfigure ../configure --enable-optimized --enable-targets=x86,js --enable-libcpp --disable-jit --disable-threads --disable-pthreads --disable-assertions --enable-bindings=no --disable-zlib &>/dev/null || exit 1
#sed -e '/HAVE_ARC4RANDOM/ s?^?//?' -i .bak include/llvm/Config/config.h
mkdir -p Release/bin &&
cp ../tool-build/Release/bin/* Release/bin &&
chflags uchg Release/bin/* || exit 1
cp $SCRIPTDIR/stdio.h include &&
curl https://raw.githubusercontent.com/kripken/Relooper/master/ministring.h > include/ministring.h &&
emmake make -i -j4 #&> /dev/null

echo "Copying tools to bitcode-for-js"
#rm -rf $SCRIPTDIR/bitcode-for-js
mkdir $SCRIPTDIR/bitcode-for-js
find $LLVMDIR/emscripten-build/Release/bin -maxdepth 1 -not -perm -111 -not -name ".*" -type f -exec basename {} \;| xargs -I% cp -v $LLVMDIR/emscripten-build/Release/bin/% $SCRIPTDIR/bitcode-for-js/%.bc
