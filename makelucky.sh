#!/bin/bash
# Create Slackware package

echo "--- Starting makelucky.sh debug ---"
echo "Current working directory: $(pwd)"

PLUGIN_NAME="lucky"
BASE_DIR="./lucky" # Changed to relative path
TMP_DIR="/tmp/${PLUGIN_NAME}_${RANDOM}"
VERSION="$(date +'%Y.%m.%d')"

echo "PLUGIN_NAME: $PLUGIN_NAME"
echo "BASE_DIR: $BASE_DIR"
echo "TMP_DIR: $TMP_DIR"
echo "VERSION: $VERSION"

echo "Listing contents of BASE_DIR ($BASE_DIR):"
ls -R "$BASE_DIR"

mkdir -p "$TMP_DIR/$VERSION"
echo "Created temporary directory: $TMP_DIR/$VERSION"

cd "$TMP_DIR/$VERSION" || { echo "Error: Failed to change directory to $TMP_DIR/$VERSION"; exit 1; }
echo "Changed current directory to: $(pwd)"

echo "Copying files from $BASE_DIR to $TMP_DIR/$VERSION/"
cp -Rf "$GITHUB_WORKSPACE/$BASE_DIR/"* "./"
echo "Files copied. Listing contents of current directory after copy:"
ls -R "."

chmod +x "./etc/lucky/lucky"
echo "Set execute permission on lucky binary."

mkdir "./install"
tee "./install/slack-desc" <<EOF
       |-----lucky------------------------------------------------------|
$PLUGIN_NAME: $PLUGIN_NAME Package contents:
$PLUGIN_NAME:
$PLUGIN_NAME: Source: https://github.com/gdy666/lucky
$PLUGIN_NAME:
$PLUGIN_NAME: Custom $PLUGIN_NAME package for Unraid by stl88083365
$PLUGIN_NAME:
EOF
echo "slack-desc created."

# Create .tar.xz archive (renamed to .txz)
# Change directory to the temporary build directory to correctly tar its contents
echo "Creating tar archive from current directory..."
echo "Current directory for tar: $(pwd)"
ls -l
tar -cvf "$TMP_DIR/unraid-$PLUGIN_NAME-$VERSION.tar" .
echo "Tar archive created. Listing:"
ls -l "$TMP_DIR/unraid-$PLUGIN_NAME-$VERSION.tar"

echo "Compressing tar archive to .txz..."
xz -z "$TMP_DIR/unraid-$PLUGIN_NAME-$VERSION.tar"
echo "Compression complete. Listing:"
ls -l "$TMP_DIR/unraid-$PLUGIN_NAME-$VERSION.tar.xz"

mv "$TMP_DIR/unraid-$PLUGIN_NAME-$VERSION.tar.xz" "$TMP_DIR/unraid-$PLUGIN_NAME-$VERSION.txz"
echo "Renamed to .txz. Listing:"
ls -l "$TMP_DIR/unraid-$PLUGIN_NAME-$VERSION.txz"

md5sum "$TMP_DIR/unraid-$PLUGIN_NAME-$VERSION.txz" | awk '{print $1}' > "$TMP_DIR/unraid-$PLUGIN_NAME-$VERSION.txz.md5"
echo "MD5 sum created. Listing:"
ls -l "$TMP_DIR/unraid-$PLUGIN_NAME-$VERSION.txz.md5"

echo "Copying generated files to $GITHUB_WORKSPACE/dist/"
cp "$TMP_DIR/unraid-$PLUGIN_NAME-$VERSION.txz" "$GITHUB_WORKSPACE/dist/"
cp "$TMP_DIR/unraid-$PLUGIN_NAME-$VERSION.txz.md5" "$GITHUB_WORKSPACE/dist/"
echo "Files copied to dist/. Listing dist/ contents:"
ls -l "$GITHUB_WORKSPACE/dist/"

rm -rf "$TMP_DIR"
echo "Cleaned up temporary directory."
echo "--- makelucky.sh debug complete ---"
