qpdfview
========

Unofficial build scripts and patches for [qpdfview](https://launchpad.net/qpdfview) document viewer for macOS. Binaries provided for macOS 10.15 and newer. Windows binaries can be found at [darealshinji/qpdfview](https://github.com/darealshinji/qpdfview).

## Known issues

- Copying Russian text in PDFs with CP1251-encoded data may return CP1250-interpreted data.
  As a workaround there is an extra menu option to do this.
- Poppler is preferred over mupdf when available.
  As a workaround one can delete `qpdfview.app/Contents/MacOS/libqpdfview_pdf.dylib`.
- ARM Macs require Rosetta and code signing to run.

## Manual compilation with MacPorts

- Be on macOS 10.13 or newer.
- Install [Xcode](https://developer.apple.com/xcode) and [MacPorts](https://www.macports.org).
- Install the following ports: `bzr qt5 mupdf libspectre poppler-qt5 djvulibre imagemagick`
- Execute `qpdfview.sh` from terminal.

## Manual compilation with HomeBrew

- Be on macOS 10.13 or newer.
- Install [Xcode](https://developer.apple.com/xcode) and [HomeBrew](https://brew.sh).
- Add poppler-qt6 repo dependency
- Install the following ports: `bzr qt mupdf-tools libspectre poppler-qt6 djvulibre imagemagick`
- Run the following commands to export fitz paths:
    ```
    export FITZ_PLUGIN_INCLUDEPATH=$(brew --prefix mupdf-tools)/include
    export FITZ_PLUGIN_LINKPATH=$(brew --prefix mupdf-tools)/lib
    export FITZ_PLUGIN_LIBS="-lmupdf -lz"
    ```
- Execute `qpdfview.sh` from terminal.
