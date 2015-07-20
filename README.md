# make-llvm-bitcode-for-javascript
helper script that compiles llvm tools (llvm-as, llvm-dis, opt, etc.) to llvm Bitcode for later transformation into JavaScript by emscripten

## Why?

This enables you to use llvm in the browser!

## Prerequisites

You need to have emscripten installed.

## Usage

1. download or clone an llvm source tree.

        git clone git@github.com:kripken/emscripten-fastcomp.git kripken-fastcomp
   
2. run ./make-bitcode-for-javascript and provide the path to the llvm source tree

        ./make-bitcode-for-javascript.sh ../kripken-fastcomp
    
3. Wait!

4. Find .bc files in ./bitcode-for-js

```
➜  make-llvm-bitcode-for-javascript git:(master) ls bitcode-for-js
bugpoint.bc            llvm-diff.bc           llvm-objdump.bc        opt.bc
llc.bc                 llvm-dis.bc            llvm-pdbdump.bc        pnacl-abicheck.bc
lli-child-target.bc    llvm-dsymutil.bc       llvm-profdata.bc       pnacl-bcanalyzer.bc
lli.bc                 llvm-dwarfdump.bc      llvm-readobj.bc        pnacl-bccompress.bc
llvm-ar.bc             llvm-extract.bc        llvm-rtdyld.bc         pnacl-bcdis.bc
llvm-as.bc             llvm-link.bc           llvm-size.bc           pnacl-freeze.bc
llvm-bcanalyzer.bc     llvm-lto.bc            llvm-stress.bc         pnacl-llc.bc
llvm-c-test.bc         llvm-mc.bc             llvm-symbolizer.bc     pnacl-thaw.bc
llvm-cov.bc            llvm-mcmarkup.bc       macho-dump.bc          verify-uselistorder.bc
llvm-cxxdump.bc        llvm-nm.bc             obj2yaml.bc            yaml2obj.bc
```

5. Compile to JavaScipt.
    
    For example:
        
        emcc -Oz -v --llvm-lto 3 llvm-as.bc -o llvm-as.js
