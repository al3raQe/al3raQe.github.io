#!/usr/bin/env bash

cd $(dirname "$0")
dpkg-scanpackages -m ./debs > Packages
DEBS_DIR="./debs/"
PACKAGES_FILE="Packages"
PACKAGES_OLD="Packages.old"
TEMP_NEW="temp_new"

if [ -f "$PACKAGES_FILE" ]; then
    cp "$PACKAGES_FILE" "$PACKAGES_OLD"
else
    touch "$PACKAGES_OLD"
fi

apt-ftparchive packages "$DEBS_DIR" > "$TEMP_NEW"
mv "$TEMP_NEW" "$PACKAGES_FILE"

awk '/Filename:/ {print $2}' "$PACKAGES_OLD" > old_debs_list
awk '/Filename:/ {print $2}' "$PACKAGES_FILE" > new_debs_list

echo "info extracted: MD5sum,Size,SHA1,SHA256,SHA512✅
"
while read -r new_deb; do
    if ! grep -Fxq "$new_deb" old_debs_list; then
        echo "Filename: $new_deb added ✅"
    fi
done < new_debs_list

rm "$PACKAGES_OLD" old_debs_list new_debs_list
echo "✅"

PACKAGES_FILE="./Packages"
TEMP_FILE="./Packages_temp"
DEFAULT_ICON="Icon: https://al3raqe.github.io/photo/al3raQe.png"

if [ ! -f "$PACKAGES_FILE" ]; then
    echo "Error: Packages file not found."
    exit 1
fi

awk -v default_icon="$DEFAULT_ICON" '
BEGIN { RS=""; FS="\n" }
{
    has_icon = 0
    new_package = ""

    for (i=1; i<=NF; i++) {
        if ($i ~ /^Icon:/) {
            has_icon = 1
        }
        new_package = new_package $i "\n"
    }

    if (!has_icon) {
        new_package = new_package default_icon "\n"
    }

    print new_package
}
' "$PACKAGES_FILE" > "$TEMP_FILE"

mv "$TEMP_FILE" "$PACKAGES_FILE"

echo "Icons added where missing ✅"

bzip2 -c Packages > Packages.bz2
gzip -c Packages > Packages.gz
xz -c Packages > Packages.xz
zstd -c Packages > Packages.zst

git add --all
git commit -m "Update"
git push
