#!/bin/bash

BASE_DIR="./debs"
OUTPUT_FILE="Packages"
ARCHS=("arm" "arm64" "arm64e")

for ARCH in "${ARCHS[@]}"; do
    mkdir -p "$BASE_DIR/$ARCH"
done

for deb in ./*.deb; do
    [ -e "$deb" ] || continue

    dpkg-deb -x "$deb" temp_dir
    dpkg-deb -e "$deb" temp_dir/DEBIAN

    sed -i \
      -e '/^Recommended:/d' \
      -e 's/+debug//' \
      temp_dir/DEBIAN/control

    dpkg-deb --build temp_dir "$deb"
    rm -rf temp_dir

    name=$(dpkg-deb -f "$deb" Name | tr ' ' '.' | tr -d '[:space:]')
    version=$(dpkg-deb -f "$deb" Version | tr -d '[:space:]')
    arch=$(dpkg-deb -f "$deb" Architecture | sed 's/^iphoneos-//' | tr -d '[:space:]')
    new_name="${name}.${version}.${arch}.deb"
    new_path="$BASE_DIR/$arch/$new_name"
    [ ! -f "$new_path" ] && mv "$deb" "$new_path"
done

> "$OUTPUT_FILE"
for ARCH in "${ARCHS[@]}"; do
    ARCH_DIR="$BASE_DIR/$ARCH"
    [ -d "$ARCH_DIR" ] && apt-ftparchive packages "$ARCH_DIR" >> "$OUTPUT_FILE"
done

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
