# Change Log

This is the change log for DelphiDabbler _gbg_.

All notable changes to this project are documented in this file. Releases are listed in reverse version number order.

## v0.3.0 - 2023-06-06

* Added new `-V` (or `/V`) command line option to display version information and compile date [issue #8]. Added code to extract version number from version information resource.
* Modified `ProductVersion` version information string to make more suitable for display by `-V` command.
* Updated `README.md` _Usage_ section with details of changes per v0.2.0 [issue #9] and v0.3.0.
* Fixed release process broken by errors in Delphi project file [issue #10].
* Documentated new `-V` option in `README.md`.

## v0.2.0 - 2023-06-06

* Added new `-a` and `-A` (or `/a` and `/A`) command line options to generate files containing ASCII characters. `-A` generates random ASCII character codes in range 0 to 127 while `-a` generates random printable ASCII character codes in range 32..126 [issue #1].
* Fixed potential bug when creating zero length files [issue #2].
* Updated usage output re new options.
* Some refactoring of code.
* Documentated new options in `README.md`.

## v0.1.0 - 2023-04-16

* Original release.
