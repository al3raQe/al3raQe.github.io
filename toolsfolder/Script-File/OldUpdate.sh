rm -f Packages.bz2
rm -f Packages.gz
bzip2 -c9 Packages > Packages.bz2
gzip -c9 Packages > Packages.gz
git add debs Packages.bz2 depictions
git add debs Packages.gz depictions
git commit -m "update"
git push
