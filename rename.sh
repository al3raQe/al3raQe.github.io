#!/bin/bash

DIRS=("./debs" "./debs/arm" "./debs/arm64" "./debs/arm64e")

for dir in "${DIRS[@]}"; do
    [ -d "$dir" ] || continue

    for file in "$dir"/*.deb; do
        [ -e "$file" ] || continue

        package_name=$(dpkg-deb -f "$file" Package | tr -d '[:space:]')
        version=$(dpkg-deb -f "$file" Version | tr -d '[:space:]')
        arch=$(dpkg-deb -f "$file" Architecture | tr -d '[:space:]')

        if [ -z "$package_name" ] || [ -z "$version" ] || [ -z "$arch" ]; then
            echo "Failed to extract package info from: $file"
            continue
        fi

        new_name="${package_name}_${version}_${arch}.deb"
        new_path="$dir/$new_name"

        if [ "$file" = "$new_path" ]; then
            echo "Already named: $new_name"
        elif [ -e "$new_path" ]; then
            echo "Skipping; target already exists: $new_path"
        else
            echo "Renaming: $(basename "$file") -> $new_name"
            mv "$file" "$new_path"
        fi
    done
done

echo "Renaming completed in debs and its three architecture directories."
