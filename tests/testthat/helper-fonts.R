# Can the current session draw Arial on a file device? This distinguishes a
# machine with the font registered, where the package default renders, from a
# bare build environment, where the rendering test is skipped. The PostScript
# and PDF font table is the same registry that the device consults, and
# extrafont::loadfonts(device = "pdf") populates it, so the lookup matches
# what rendering does without opening a device.
arial_renderable <- function() {
  "Arial" %in% names(grDevices::pdfFonts())
}
