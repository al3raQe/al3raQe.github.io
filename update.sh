#!/bin/sh apt-ftparchive packages ./debs/ > ./Packages; #sed -i -e '/^SHA/d'
./Packages; bzip2 -c9k ./Packages > ./Packages.bz2; printf "Origin: al3raQe's
Repo\nLabel: al3raQe\nSuite: stable\nVersion: 1.0\nCodename:
al3raQe\nArchitecture: iphoneos-arm\nComponents: main\nDescription:
al3raQe's Tweaks\nMD5Sum:\n "$(cat ./Packages | md5sum | cut -d ' ' -f 1)"
"$(stat ./Packages --printf="%s")" Packages\n "$(cat ./Packages.bz2 | md5sum |
cut -d ' ' -f 1)" "$(stat ./Packages.bz2 --printf="%s")" Packages.bz2\n"
>Release; ls ./debs/ -t | grep '.deb' | perl -e 'use JSON; @in=grep(s/\n$//,
<>); $count=0; foreach $fileNow (@in) { $fileNow = "./debs/$fileNow"; $size
= -s $fileNow; $debInfo = `dpkg -f $fileNow`; $section = `echo "$debInfo" | grep
"Section: " | cut -c 10- | tr -d "\n\r"`; $name= `echo "$debInfo" | grep "Name:
" | cut -c 7- | tr -d "\n\r"`; $version= `echo "$debInfo" | grep "Version: " |
cut -c 10- | tr -d "\n\r"`; $package= `echo "$debInfo" | grep "Package: " | cut
-c 10- | tr -d "\n\r"`; $time= `date -r $fileNow +%s | tr -d "\n\r"`;
@in[$count] = {section=>$section, package=>$package, version=>$version,
size=>$size+0, time=>$time+0, name=>$name}; $count++; } print
encode_json(\@in)."\n";' > all.packages; exit 0;
