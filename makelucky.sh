#!/bin/bash
# Create Slackware package
PLUGIN_NAME="lucky"
BASE_DIR="/mnt/c/lucky"
TMP_DIR="/tmp/${PLUGIN_NAME}_${RANDOM}"
VERSION="$(date +'%Y.%m.%d')"
# 删除旧的打包文件(如果存在)
if [ -f "$BASE_DIR/unraid-$PLUGIN_NAME.txz" ]; then
    rm -f "$BASE_DIR/unraid-$PLUGIN_NAME.txz"
fi
if [ -f "$BASE_DIR/unraid-$PLUGIN_NAME.txz.md5" ]; then
    rm -f "$BASE_DIR/unraid-$PLUGIN_NAME.txz.md5" 
fi

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
$PLUGIN_NAME:
$PLUGIN_NAME: Custom $PLUGIN_NAME package for Unraid by stl88083365
$PLUGIN_NAME:
EOF

makepkg -l n -c n "$TMP_DIR/unraid-$PLUGIN_NAME.txz"
md5sum "$TMP_DIR/unraid-$PLUGIN_NAME.txz" | awk '{print $1}' > "$TMP_DIR/unraid-$PLUGIN_NAME.txz.md5"
cp "$TMP_DIR/unraid-$PLUGIN_NAME.txz" "$BASE_DIR/"
cp "$TMP_DIR/unraid-$PLUGIN_NAME.txz.md5" "$BASE_DIR/"
rm -rf "$TMP_DIR"
