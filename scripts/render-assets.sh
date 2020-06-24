#! /bin/bash

detect_inkscape_version() {
    echo "render-assets: checking inkscape version"
    INKSCAPE_VERSION="$(inkscape --version |& head -n1 | cut -d\  -f2)"
    INKSCAPE_VERSION_MAJOR="$(cut -d. -f1 <<< "$INKSCAPE_VERSION")"
    INKSCAPE_VERSION_MINOR="$(cut -d. -f2 <<< "$INKSCAPE_VERSION")"
    INKSCAPE_VERSION_PATCH="$(cut -d. -f3 <<< "$INKSCAPE_VERSION")"

    if [[ "$INKSCAPE_VERSION_MAJOR" -gt 1 ]]; then
        echo "render-assets: detected unsupported inkscape version ($INKSCAPE_VERSION)"
        echo "render-assets: attempting to use flags for 1.x"
        INKSCAPE_FLAVOUR=1.x
    elif [[ "$INKSCAPE_VERSION_MAJOR" -eq 1 ]]; then
        echo "render-assets: detected inkscape version 1.x ($INKSCAPE_VERSION)"
        INKSCAPE_FLAVOUR=1.x
    elif [[ "$INKSCAPE_VERSION_MAJOR" -eq 0 && "$INKSCAPE_VERSION_MINOR" -gt 90 ]]; then
        echo "render-assets: detected inkscape version 0.9x ($INKSCAPE_VERSION)"
        INKSCAPE_FLAVOUR=0.9x
    else
        echo "render-assets: detected unsupported inkscape version ($INKSCAPE_VERSION)"
        echo "render-assets: attempting to use flags for 0.9x"
        INKSCAPE_FLAVOUR=0.9x
    fi
}

inkscape_render() {
    FILE="$1"
    shift

    case "$INKSCAPE_FLAVOUR" in
        1.x) inkscape --export-type=png --export-filename="$FILE" "$@";;
        0.9x) inkscape --export-png="$FILE" "$@";;
        *) echo "render-assets.sh: unknown inkscape flavour '$INKSCAPE_FLAVOUR'";;
    esac
}


SRC_FILE="src/assets/all-assets.svg"
ASSETS_DIR="src/assets"
INDEX="src/assets/all-assets.txt"

detect_inkscape_version

for i in `cat $INDEX`
do 
if [ -f $ASSETS_DIR/$i.png ]; then
    echo $ASSETS_DIR/$i.png exists.
else
    echo Rendering $ASSETS_DIR/$i.png
    inkscape_render "$ASSETS_DIR/$i.png" \
              --export-id=$i \
              --export-id-only \
              $SRC_FILE >/dev/null #\
    # && optipng -o7 --quiet $ASSETS_DIR/$i.png 
fi
if [ -f $ASSETS_DIR/$i@2.png ]; then
    echo $ASSETS_DIR/$i@2.png exists.
else
    echo Rendering $ASSETS_DIR/$i@2.png
    inkscape_render "$ASSETS_DIR/$i@2.png" \
              --export-id=$i \
              --export-dpi=180 \
              --export-id-only \
              $SRC_FILE >/dev/null #\
    # && optipng -o7 --quiet $ASSETS_DIR/$i@2.png 
fi
done
exit 0
