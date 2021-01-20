qpdfview
========

Unofficial build scripts and patches for [qpdfview](https://launchpad.net/qpdfview) document viewer for macOS. Windows binaries can be found at [darealshinji/qpdfview](https://github.com/darealshinji/qpdfview).

## Known issues

- Copying Russian text in PDFs with CP1251-encoded data may return CP1250-interpreted data.
  As a workaround there is an extra menu option to do this.
- Poppler is preferred over mupdf when available.
  As a workaround one can delete `qpdfview.app/Contents/MacOS/libqpdfview_pdf.dylib`.
- Presentation view may not work as expected.

## Compilation requirements

- Be on macOS 10.13 or newer.
- Install [Xcode](https://developer.apple.com/xcode) and [MacPorts](https://www.macports.org).
- Install the following ports: `bzr qt5 mupdf libspectre poppler-qt5 djvulibre imagemagick`
- Execute `qpdfview.sh` from terminal.
