#!/usr/bin/env bash

function convert_format() {
    format="$1"

    echo "--- $format at $2 -------------------------------"

    rm -rf "$format"
    mkdir "$format"

    mogrify -path "./$format" -quality "$2" -format "$format" *.png

    for file in $format/*;
    do
        printf ",$(stat "$file" | grep -oP "Size: \K([0-9]+)")" >> result.csv
    done
}

touch result.csv

printf "compression,webp (normal),webp (albedo),webp (R/M),jpg (normal),jpg (albedo),jpg (R/M),png (normal),png (albedo),png (R/M)\n" >> result.csv

factors="10,20,30,40,50,60,70,80,90,100"
for quality in ${factors//,/ }
do
    printf "$quality%%" >> result.csv
    convert_format "webp" "$quality%"
    convert_format "jpg" "$quality%"
    convert_format "png" "$quality%"
    printf "\n" >> result.csv
done
