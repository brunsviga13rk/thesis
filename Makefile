
include .env

build:
	git submodule update --init --recursive
	typst compile "${TYPST_MAIN}" \
    	--root . \
    	--font-path template/fonts \
    	--pdf-standard a-2b \
    	"${TYPST_FILE_PATH}.${TYPST_FILE_TYPE}"

live: build
	typst watch "${TYPST_MAIN}" \
    	--root . \
    	--font-path template/fonts \
    	--pdf-standard a-2b \
    	"${TYPST_FILE_PATH}.${TYPST_FILE_TYPE}"

check:
	scripts/typstyle.sh --check "${TYPST_MAIN}"

format:
	scripts/typstyle.sh --format "${TYPST_MAIN}"

clean:
	rm "${TYPST_FILE_PATH}.${TYPST_FILE_TYPE}"
