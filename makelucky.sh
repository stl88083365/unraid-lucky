#!/bin/bash
# Create Slackware package
PLUGIN_NAME="lucky"
BASE_DIR="./lucky" # Changed to relative path
TMP_DIR="/tmp/${PLUGIN_NAME}_${RANDOM}"
VERSION="$(date +'%Y.%m.%d')"

mkdir -p "$TMP_DIR/$VERSION"
cd "$TMP_DIR/$VERSION" || exit 1
cp -Rf "$BASE_DIR/"* "$TMP_DIR/$VERSION/"
chmod +x "$TMP_DIR/$VERSION/etc/lucky/lucky"
mkdir "$TMP_DIR/$VERSION/install"
tee "$TMP_DIR/$VERSION/install/slack-desc" <<EOF
       |-----lucky------------------------------------------------------|
$PLUGIN_NAME: $PLUGIN_NAME Package contents:
$PLUGIN_NAME:
$PLUGIN_NAME: Source: https://github.com/gdy666/lucky
$PLUGIN_NAME:
$PLUGIN_NAME: Custom $PLUGIN_NAME package for Unraid by stl88083365
$PLUGIN_NAME:
EOF

# Create .tar.xz archive (renamed to .txz)
# Change directory to the temporary build directory to correctly tar its contents
(cd "$TMP_DIR/$VERSION" && tar -cvf "$TMP_DIR/unraid-$PLUGIN_NAME-$VERSION.tar" .)
xz -z "$TMP_DIR/unraid-$PLUGIN_NAME-$VERSION.tar"
mv "$TMP_DIR/unraid-$PLUGIN_NAME-$VERSION.tar.xz" "$TMP_DIR/unraid-$PLUGIN_NAME-$VERSION.txz"

md5sum "$TMP_DIR/unraid-$PLUGIN_NAME-$VERSION.txz" | awk '{print $1}' > "$TMP_DIR/unraid-$PLUGIN_NAME-$VERSION.txz.md5"
cp "$TMP_DIR/unraid-$PLUGIN_NAME-$VERSION.txz" "."
cp "$TMP_DIR/unraid-$PLUGIN_NAME-$VERSION.txz.md5" "."
rm -rf "$TMP_DIR"
