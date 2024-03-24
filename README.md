qpdfview
========

Unofficial build scripts and patches for [qpdfview](https://launchpad.net/qpdfview) document viewer for macOS. Binaries are provided for the following macOS versions:

* [Latest for Apple Silicon](https://github.com/vit9696/qpdfview/releases/latest) — macOS 14 or newer
* [Latest for Intel](https://github.com/vit9696/qpdfview/releases/latest) — macOS 12 or newer
* [0.5.0-r2153 for Intel](https://github.com/vit9696/qpdfview/releases/tag/r2153u71) — macOS 11 or newer
* [0.4.99-r2143 for Intel](https://github.com/vit9696/qpdfview/releases/tag/r2143u64) — macOS 10.15 or newer
* [0.4.99-r2126 for Intel](https://github.com/vit9696/qpdfview/releases/tag/r2126u40) — macOS 10.13 or newer

Changelogs can be found at [launchpad.net](https://bazaar.launchpad.net/~adamreichold/qpdfview/trunk/changes).
Unofficial Windows binaries can be found at [darealshinji/qpdfview](https://github.com/darealshinji/qpdfview).

## Known issues

- Copying Russian text in PDFs with CP1251-encoded data may return CP1250-interpreted data.
  As a workaround there is an extra menu option to do this.
- Poppler is preferred over mupdf when available.
  As a workaround one can delete `qpdfview.app/Contents/MacOS/libqpdfview_pdf.dylib`.

## Manual compilation with HomeBrew

- Be on macOS 10.13 or newer.
- Install [Xcode](https://developer.apple.com/xcode) and [HomeBrew](https://brew.sh).
- Add poppler-qt6 repo dependency
- Install the following formulae: `qt bzr mupdf-tools mujs lcms2 libspectre freetype harfbuzz poppler-qt6 djvulibre lcms2 imagemagick create-dmg`
- Install the following pips: `breezy launchpadlib`
- Run the following commands to export fitz paths:
    ```
    export FITZ_PLUGIN_INCLUDEPATH=$(brew --prefix mupdf-tools)/include
    export FITZ_PLUGIN_LINKPATH=$(brew --prefix mupdf-tools)/lib
    export FITZ_PLUGIN_LIBS="-lmupdf -lmupdf-third -L$(brew --prefix mujs)/lib -lmujs -L$(brew --prefix freetype)/lib -lfreetype -L$(brew --prefix harfbuzz)/lib -lharfbuzz -lz -L$(brew --prefix jpeg)/lib -ljpeg -L$(brew --prefix jbig2dec)/lib -ljbig2dec -L$(brew --prefix openjpeg)/lib -lopenjp2 -L$(brew --prefix lcms2)/lib -llcms2
    ```
- Execute `qpdfview.sh` from terminal.
