qpdfview
========

Unofficial build scripts and patches for [qpdfview](https://launchpad.net/qpdfview) document viewer for macOS. Binaries provided for macOS 11 and newer. Windows binaries can be found at [darealshinji/qpdfview](https://github.com/darealshinji/qpdfview).

## Known issues

- Copying Russian text in PDFs with CP1251-encoded data may return CP1250-interpreted data.
  As a workaround there is an extra menu option to do this.
- Poppler is preferred over mupdf when available.
  As a workaround one can delete `qpdfview.app/Contents/MacOS/libqpdfview_pdf.dylib`.
- ARM Macs require Rosetta and code signing to run.

## Manual compilation with MacPorts

- Be on macOS 10.13 or newer.
- Install [Xcode](https://developer.apple.com/xcode) and [MacPorts](https://www.macports.org).
- Install the following ports: `breezy qt5 mupdf libspectre poppler-qt5 djvulibre imagemagick`
- Execute `qpdfview.sh` from terminal.

## Manual compilation with HomeBrew

- Be on macOS 10.13 or newer.
- Install [Xcode](https://developer.apple.com/xcode) and [HomeBrew](https://brew.sh).
- Add poppler-qt6 repo dependency
- Install the following formulae: `qt bzr mupdf-tools mujs lcms2 libspectre freetype harfbuzz poppler-qt6 djvulibre lcms2 imagemagick create-dmg`
- Run the following commands to export fitz paths:
    ```
    export FITZ_PLUGIN_INCLUDEPATH=$(brew --prefix mupdf-tools)/include
    export FITZ_PLUGIN_LINKPATH=$(brew --prefix mupdf-tools)/lib
    export FITZ_PLUGIN_LIBS="-lmupdf -lmupdf-third -L$(brew --prefix mujs)/lib -lmujs -L$(brew --prefix freetype)/lib -lfreetype -L$(brew --prefix harfbuzz)/lib -lharfbuzz -lz -L$(brew --prefix jpeg)/lib -ljpeg -L$(brew --prefix jbig2dec)/lib -ljbig2dec -L$(brew --prefix openjpeg)/lib -lopenjp2 -L$(brew --prefix lcms2)/lib -llcms2
    ```
- Execute `qpdfview.sh` from terminal.
