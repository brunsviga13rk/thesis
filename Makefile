
include .env

build:
	git submodule update --init --recursive
	typst compile src/main.typ \
    	--root . \
    	--font-path template/fonts \
    	--pdf-standard a-2b \
    	"${TYPST_FILE_PATH}.${TYPST_FILE_TYPE}"

clean:
	rm "${TYPST_FILE_PATH}.${TYPST_FILE_TYPE}"
