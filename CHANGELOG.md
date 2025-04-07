# Change Log

This is the change log for DelphiDabbler _gbg_.

All notable changes to this project are documented in this file. Releases are listed in reverse version number order.

## v0.5.0 - 2025-04-07

* Added support for using Kb, KiB, MB, MiB, GB and GiB symbols when specifying numbers of bytes on the command line [issue #17].
* Added new `-r` command line option for customising the size of repeated blocks of random data from the fixed value of 10MiB used in previous releases. Also provided a special value for the `-r` option that ensures that the output file contains purely random data, regardless of size [issue #7]. A maximum size of repeated random blocks is was set. This is larger in the 64 bit build than in the 32 bit build.
* Reduced the maximum output file size in the program's 32 bit build to 1GiB from 20GiB because of out of memory issues [issue #23]. This issue does not affect the 64 bit build.
* Updated help screen and Usage and Operation sections in `README.md` re the changes in this release.
* Changed to compile with Delphi 12.2
* Some refactoring.
* Fixed minor bug in `Deploy.bat` [issue #19].
* Fixed typo in `CHANGELOG.md` [issue #18].
* Minor corrections and edits in `README.md`.

## v0.4.0 - 2024-08-31

* Added new `-l` and `-L` command line options to inhibit the prompt when a file larger than 500Mb is requested [issue #11]. `-l` halts the program with an error if such a large file is requested while `-L` silently creates a file of any size.
* Added new `-o` and `-O` command line options to inhibit the file overwrite prompt from appearing when a file name already exists [issue #12]. `-o` halts the program with an error if a file with the same name exists while `-O` silently overwrites any existing file. 
* Changed to compile with Delphi 12.1 [issue #13].
* Documentated new options in `README.md` and made some other updates.

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
