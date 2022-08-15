#!/bin/bash

SELF_DIR=$(dirname "$0")
pushd "$SELF_DIR" &>/dev/null
SELF_DIR="$(pwd)"
popd &>/dev/null

WORK_DIR="$(pwd)"
QPDFVIEW_BDIR="${WORK_DIR}/build"
QPDFVIEW_DIR="${WORK_DIR}/dist"
QPDFVIEW_APP="${QPDFVIEW_BDIR}/qpdfview.app"
QPDFVIEW_REV=2143
if [ "${QPDFVIEW_EDITION}" = "" ]; then
  QPDFVIEW_EDITION=1
fi

# Add Qt tools to PATH
export PATH="$PATH:/opt/local/libexec/qt5/bin"

check_depedencies() {
  echo "Checking dependencies..."
  for tool in bzr qmake make convert macdeployqt patch; do
    if [ "$(which ${tool})" = "" ]; then
      echo "${tool} is missing"
      exit 1
    fi
  done
}

obtain_sources() {
  echo "Obtaining sources..."
  if [ -d "${QPDFVIEW_DIR}" ]; then
    echo "Assuming done!"
    return
  fi

  bzr branch lp:qpdfview dist -r "${QPDFVIEW_REV}" || exit 1

  pushd "${QPDFVIEW_DIR}" &>/dev/null || exit 1

  for patch in "${SELF_DIR}/patches"/*.diff; do
    echo "Applying ${patch}"
    patch -p0 < "${patch}" || exit 1
  done

  popd &>/dev/null || exit 1
}

compile_bundle() {
  echo "Compiling bundle..."
  rm -rf "${QPDFVIEW_APP}" "${QPDFVIEW_BDIR}" || exit 1
  mkdir -p "${QPDFVIEW_BDIR}" || exit 1
  pushd "${QPDFVIEW_BDIR}" &>/dev/null || exit 1

  if [ "$FITZ_PLUGIN_INCLUDEPATH" = "" ]; then
    FITZ_PLUGIN_INCLUDEPATH=/opt/local/include
  fi

  if [ "$FITZ_PLUGIN_LINKPATH" = "" ]; then
    FITZ_PLUGIN_LINKPATH=/opt/local/lib
  fi

  if [ "$FITZ_PLUGIN_LIBS" = "" ]; then
    FITZ_PLUGIN_LIBS="-lmupdf -lfreetype -lharfbuzz -lz -ljpeg -ljbig2dec -lopenjp2"
  fi

  qmake APP_DIR_DATA_PATH=../Resources CONFIG+=with_fitz \
    FITZ_PLUGIN_INCLUDEPATH=${FITZ_PLUGIN_INCLUDEPATH} \
    FITZ_PLUGIN_LIBS="-L${FITZ_PLUGIN_LINKPATH} ${FITZ_PLUGIN_LIBS}" \
    "${QPDFVIEW_DIR}/qpdfview.pro" || exit 1
  make -j || exit 1
  popd &>/dev/null || exit 1
}

bundle_plugins() {
  echo "Bundling plugins..."
  rm -rf "${QPDFVIEW_APP}/Contents/MacOS"/*.dylib || exit 1
  cp "${QPDFVIEW_BDIR}"/*.dylib "${QPDFVIEW_APP}/Contents/MacOS" || exit 1
}

bundle_translations() {
  echo "Bundling translation files..."
  local tl_dir="${QPDFVIEW_APP}/Contents/Resources"
  for tl in "${QPDFVIEW_DIR}/translations"/*.ts; do
    tl_file=$(basename "${tl/.ts/.qm}")
    lconvert -i "${tl}" -o "${tl_dir}/${tl_file}" || exit 1
  done
}

bundle_help() {
  echo "Bundling help data..."
  local help_dir="${QPDFVIEW_APP}/Contents/Resources"
  cp -r "${QPDFVIEW_DIR}/help"/* "${help_dir}" || exit 1
}

bundle_icon() {
  echo "Bundling icon file..."
  local infile="${QPDFVIEW_DIR}/icons/qpdfview.svg"
  local outfile="${QPDFVIEW_DIR}/icons/qpdfview.icns"
  local dest="${outfile}.iconset"
  rm -rf "${dest}" "${outfile}" || exit 1
  mkdir "${dest}" || exit 1

  convert -background none -size '!16x16' "$infile" "$dest/icon_16x16.png" || exit 1
  convert -background none -size '!32x32' "$infile" "$dest/icon_16x16@2x.png" || exit 1
  cp "$dest/icon_16x16@2x.png" "$dest/icon_32x32.png" || exit 1
  convert -background none -size '!64x64' "$infile" "$dest/icon_32x32@2x.png" || exit 1
  convert -background none -size '!128x128' "$infile" "$dest/icon_128x128.png" || exit 1
  convert -background none -size '!256x256' "$infile" "$dest/icon_128x128@2x.png" || exit 1
  cp "$dest/icon_128x128@2x.png" "$dest/icon_256x256.png" || exit 1
  convert -background none -size '!512x512' "$infile" "$dest/icon_256x256@2x.png" || exit 1
  cp "$dest/icon_256x256@2x.png" "$dest/icon_512x512.png" || exit 1
  convert -background none -size '!1024x1024' "$infile" "$dest/icon_512x512@2x.png" || exit 1

  iconutil -c icns -o "${outfile}" "${dest}" || exit 1
  rm -rf "$dest"

  cp "${outfile}" "${QPDFVIEW_APP}/Contents/Resources/qpdfview.icns" || exit 1
  /usr/libexec/PlistBuddy -c 'Delete CFBundleIconFile' "${QPDFVIEW_APP}/Contents/Info.plist" &>/dev/null
  /usr/libexec/PlistBuddy -c 'Add CFBundleIconFile string qpdfview' "${QPDFVIEW_APP}/Contents/Info.plist" || exit 1
}

bundle_icon_premade() {
  echo "Bundling icon file..."
  cp "${SELF_DIR}/qpdfview.icns" "${QPDFVIEW_APP}/Contents/Resources/qpdfview.icns" || exit 1
  /usr/libexec/PlistBuddy -c 'Delete CFBundleIconFile' "${QPDFVIEW_APP}/Contents/Info.plist" &>/dev/null
  /usr/libexec/PlistBuddy -c 'Add CFBundleIconFile string qpdfview' "${QPDFVIEW_APP}/Contents/Info.plist" || exit 1
}

bundle_formats() {
  echo "Bundling finder formats..."
  /usr/libexec/PlistBuddy -c 'Delete CFBundleDocumentTypes' "${QPDFVIEW_APP}/Contents/Info.plist" &>/dev/null
  /usr/libexec/PlistBuddy -c "Merge ${SELF_DIR}/formats.plist" "${QPDFVIEW_APP}/Contents/Info.plist" || exit 1
}

bundle_fonts() {
  if [ "$FONTCONFIG_PATH" = "" ]; then
    if [ -f "/usr/local/etc/fonts/fonts.conf" ]; then
      FONTCONFIG_PATH=/usr/local/etc/fonts
    elif [ -f "/opt/local/etc/fonts/fonts.conf" ]; then
      FONTCONFIG_PATH=/opt/local/etc/fonts
    else
      echo "WARN: Unable to find fonts.conf"
      echo "Hint: Set FONTCONFIG_PATH variable!"
      return
    fi
  fi
  cp -r "$FONTCONFIG_PATH" "${QPDFVIEW_APP}/Contents/Resources/fonts" || exit 1
}

deploy_bundle() {
  echo "Deploying bundle..."
  /usr/libexec/PlistBuddy -c 'Delete CFBundleIdentifier' "${QPDFVIEW_APP}/Contents/Info.plist" &>/dev/null
  /usr/libexec/PlistBuddy -c 'Add CFBundleIdentifier string as.vit9696.qpdfview' "${QPDFVIEW_APP}/Contents/Info.plist" || exit 1
  macdeployqt "${QPDFVIEW_APP}" || exit 1
}

archive_bundle() {
  echo "Archiving bundle..."
  pushd "${QPDFVIEW_BDIR}" &>/dev/null || exit 1

  local version=$(cat "${QPDFVIEW_DIR}/qpdfview.pri" | grep APPLICATION_VERSION | sed 's/.*= //')
  local revision="r${QPDFVIEW_REV}u${QPDFVIEW_EDITION}"
  if [ -x "$DEPLOY_SCRIPT" ]; then
    local extension="dmg"
    local mime="application/octet-stream"
  else
    local extension="zip"
    local mime="application/zip"
  fi
  local name="qpdfview-${version}-${revision}.${extension}"

  if [ "$GITHUB_ENV" != "" ]; then
    echo "VERSION=${version}" >> "$GITHUB_ENV"
    echo "REVISION=${revision}" >> "$GITHUB_ENV"
    echo "FILENAME=${name}" >> "$GITHUB_ENV"
    echo "CONTENT_TYPE=${mime}" >> "$GITHUB_ENV"
  fi

  # codesign -s "Apple Developer" --deep qpdfview.app || exit 1
  if [ -x "$DEPLOY_SCRIPT" ]; then
    "$DEPLOY_SCRIPT" "${QPDFVIEW_BDIR}/qpdfview.app" "${WORK_DIR}/${name}" || exit 1
  else
    zip -qry ../"${name}" qpdfview.app || exit 1
  fi
  popd &>/dev/null || exit 1
}

check_depedencies
obtain_sources
compile_bundle
bundle_plugins
bundle_translations
bundle_help
bundle_icon_premade
bundle_formats
bundle_fonts
deploy_bundle
archive_bundle
