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

        case "$arch" in
            iphoneos-arm|arm) target_arch="arm" ;;
            iphoneos-arm64|arm64) target_arch="arm64" ;;
            iphoneos-arm64e|arm64e) target_arch="arm64e" ;;
            *)
                echo "Skipping unsupported architecture '$arch': $file"
                continue
                ;;
        esac

        target_dir="./debs/$target_arch"
        mkdir -p "$target_dir"
        new_name="${package_name}_${version}_${arch}.deb"
        new_path="$target_dir/$new_name"

        if [ "$file" = "$new_path" ]; then
            echo "Already named and in the correct folder: $new_name"
        elif [ -e "$new_path" ]; then
            echo "Skipping; target already exists: $new_path"
        else
            echo "Moving and renaming: $(basename "$file") -> $new_path"
            mv -- "$file" "$new_path"
        fi
    done
done

echo "Renaming and architecture-folder correction completed."
