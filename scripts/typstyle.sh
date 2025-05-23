#!/bin/bash

# Check and apply format using Typstyle
# =============================================================================
# Run with --format on an input file to recursively check the format of this
# file and all of its dependencies.
# Run with --check on an input file to recursively format the content of this
# file and all of its dependencies.
#
# Copied from: https://git.montehaselino.de/DHBW/dhbw-abb-typst-template/src/branch/main/run-fmt.sh
#
#!/bin/bash

function format() {
    # format file
    # typstyle --format $1

    if [ -z "$1" ]; then
        return
    fi

    local wd=$(dirname $(realpath "$1"))

    echo "processing file $1..."
    typstyle "$2" "$1" > /dev/null
    if [ $? -eq 1 ]; then
        echo "failed format validation: $1"
        exit 1
    fi

    local imports=$(rg "#import \"([a-z0-9/\-.]+\.typ)\"" -Nor '$1' "$1")

    # format all included files
    while IFS= read -r line; do
        if [ -z "$line" ]; then
            continue
        fi
        format "$wd/$line" "$2"
    done <<< "$imports"

    local includes=$(rg "#import \"([a-z0-9/\-.]+\.typ)\"" -Nor '$1' "$1")

    # format all included files
    while IFS= read -r line; do
        if [ -z "$line" ]; then
            continue
        fi
        format "$wd/$line" "$2"
    done <<< "$includes"
}

case $1 in
  "--format")
    format "$2" "--inplace"
    ;;
  "--check")
    format "$2" "--check"
    ;;
  *)
    echo "unknown option: $1"
    exit 1
    ;;
esac
