#!/bin/bash

# Set variables
APP_NAME="Auroracoin-Qt"
BINARY_NAME="auroracoin-qt"
APP_DIR="${APP_NAME}.AppDir"
ICON_NAME="auroracoin"
ICON_FILE="${ICON_NAME}.png"
APPIMAGE_TOOL="linuxdeploy-x86_64.AppImage"

# Check for binary
if [ ! -f "/usr/local/bin/$BINARY_NAME" ]; then
  echo "Error: $BINARY_NAME not found in /usr/local/bin/"
  exit 1
fi

# Check for AppImage tool
if [ ! -f "./$APPIMAGE_TOOL" ]; then
  echo "Downloading linuxdeploy..."
  wget https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/$APPIMAGE_TOOL
  chmod +x $APPIMAGE_TOOL
fi

# Clean previous build
rm -rf $APP_DIR Auroracoin-Qt-*.AppImage

# Create AppDir structure
mkdir -p $APP_DIR/usr/bin
cp /usr/local/bin/$BINARY_NAME $APP_DIR/usr/bin/

# Create .desktop file
cat <<EOF > $APP_DIR/$BINARY_NAME.desktop
[Desktop Entry]
Name=$APP_NAME
Exec=$BINARY_NAME
Icon=$ICON_NAME
Type=Application
Categories=Finance;
EOF

# Add placeholder icon (or replace with real one!)
if [ ! -f $ICON_FILE ]; then
  echo "Creating placeholder icon..."
  convert -size 256x256 xc:lightblue -gravity center -pointsize 24 -annotate 0 "$APP_NAME" $ICON_FILE
fi
cp $ICON_FILE $APP_DIR/$ICON_FILE

# Bundle dependencies and create AppImage
./$APPIMAGE_TOOL --appdir $APP_DIR --output appimage

# Rename output file
OUTPUT_FILE=$(ls *.AppImage | grep $APP_NAME | head -n1)
if [ -f "$OUTPUT_FILE" ]; then
  NEW_NAME="${APP_NAME}-$(date +%Y%m%d)-x86_64.AppImage"
  mv "$OUTPUT_FILE" "$NEW_NAME"
  echo "✅ AppImage created: $NEW_NAME"
else
  echo "❌ AppImage build failed."
fi
