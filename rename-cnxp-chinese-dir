#!/bin/sh

# satu subdir chinese dan di dalamnya ada beberapa file chinese. kita ingin
# ambil yang dari subdir tersebut dan buang chinesenya.

websafe_filenames.pl *
cd *
rm *.txt *.url
websafe_filenames.pl *
remove-release-crud-from-filename *
remove-cnxp-crud-from-filename *
mv * ..
cd ..
rmdir *

# bonus, yang extensionnya huruf besar seperti a.JPG
perlrename -e's/\.(\w+)$/".".lc($1)/e' *.*

# bonus, yang extensionnya foo.ext.1, foo.ext.2, ... -> foo.1.ext, foo.2.ext, ...
perlrename -e's/\.([A-Za-z]+)\.(\d+)$/.$2.$1/' *.*[0-9]

