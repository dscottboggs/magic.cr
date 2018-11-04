#!/bin/sh
set -e

bind=lib/autobind/bin/autobind
incl="-I/usr/include -I/usr/include/file"
out_dir=src/libmagic
name="LibMagic"
module="Magic"

[ -d "$out_dir" ] || mkdir -p $out_dir

bind() {
    CFLAGS="-ferror-limit=-1" $bind $incl "--lib=$name" "--module=$module" "$1.h" > "$out_dir/`basename $1`-generated.cr"
}

bind magic
bind regex
bind file/file
