# gbg

A Windows command line program to create a file of a given size, filled with ***g***ar***b***a***g***e.

## Usage

    gbg <filepath> <size> [<options>]
    gbg -V
    gbg

where

* `<filepath>` is the path of the file to be created. If a full path is not provided then the file is created relative to the current directory.

* `<size>` is the size of the file to be created. The maximum supported file size differs between the 32 and 64 bit versions of the program:
    
    * 64 bit: maximum file size is 20GiB
    * 32 bit: maximum file size is 1GiB

    Specifying a file size of zero causes an empty file to be created.

    Sizes can be entered in any of the formats described in the [Number Formats](#number-formats) section below.

* `<options>` can be zero or more of:

    * `-a` -- Generate random printable ASCII characters with code in range 32 to 126. Do not use with `-A`.

    * `-A` -- Generate random ASCII characters, including control codes, in range 0 to 127. Do not use with `-a`.

    * `-l` -- Program stops with an error if the requested output file size exceeds 500Mb. Do not use with `-L`.

    * `-L` -- Program silently creates a file of any requested size providing there is sufficient disk space. Do not use with `-l`.

    * `-o` -- Program stops with an error if the output file already exists. Do not use with `-O`.

    * `-O` -- Program silently overwrites any file with the same name as the output file. Do not use with `-o`.

    * `-r:<number>` -- Sets the number of bytes of random data written before the data repeats. `<number>` can be entered in any of the formats described in the [Number Formats](#number-formats) section below. Setting `<number>` to zero is equivalent to the `-r:all` parameter - see below.

        The maximum number of bytes that can be passed as `<number>` differs between the 32 and 64 bit versions of the program:
    
        * 64 bit: maximum value is 2GiB - 9 bytes
        * 32 bit: maximum file size is 1GiB

        If this option is not provided then a default value of 10Mib is used by both the 32 and 64 bit versions of the program.

        Do not use with `-r:all`.

    * `-r:all` -- Sequences of random data never repeat. Do not use with `r:<number>`.

* `-V` on its own causes the program to display version information and exit

* Running `gbg` with no parameters causes the program to display usage information and exit.

Note that `-` can be replaced by `/` in options. E.g. `-a` can be specified as `/a`.

### Number Formats

Wherever a number of bytes must be specified on the command line, numbers in the following formats can be entered:

* The number of bytes as a decimal number

* A decimal number followed by one of the following IEC recognised symbol:

    | IEC symbol | Name     | Number of bytes |
    |------------|----------|----------------:|
    | kB         | kilobyte |           1,000 |
    | KiB        | kibibyte |           1,024 |
    | MB         | megabyte |       1,000,000 |
    | MiB        | mebibyte |       1,048,576 |
    | GB         | gigabyte |   1,000,000,000 |
    | GiB        | gibibyte |   1,073,741,824 |

Decimal numbers can optionally include thousands separators, which much be correct for current locale.

For example, in the en-GB locale, 4MiB can be expressed as:

    * 4194304
    * 4,194,304
    * 4MiB

## Operation

By default files up to 10MiB in size are generated with random bytes. Files larger than 10MiB have the first 10MiB bytes generated randomly, but then that same 10MiB pattern is repeated as many times as necessary. If the requested file size is zero then an empty file is created. The size of the repeating pattern can be changed using the `-r:<number>` command line option (see above). For example to repeat a random 100 byte pattern use `-r:100`. The whole file can be filled with a non-repeating pattern of bytes if the `-r:all` command line option is used (see above).

By default, if a file size of more than 500,000,000 bytes (500Mb) is entered then the user is asked to confirm the size. This behaviour can be overridden by specifying either the `-l` or `-L` options (see above).

If the given file already exists the user is asked to confirm that the file can be overwritten. This behaviour can be overridden by specifying either the `-o` or `-O` options (see above).

## Installing & Uninstalling

_gbg_ can be downloaded from the project's [Releases page](https://github.com/delphidabbler/gbg/releases) on GitHub. The download for each release is named `gbg-exe-<version>.zip`, where `<version>` represents the release version number. 

The zip file contains:

* `GBG.exe` - 64 bit version of the program. _Always_ use this version on 64 bit operating systems.
* `GBG32.exe` - 32 bit version of program. _Only_ use on 32 bit operating systems.
* `README.txt` - a read-me file that links to installation information.

There is no installation program. Simply copy `GBG.xe` or `GBG32.exe` to any folder on your computer and run it from there. _gbg_ will happily run from USB or SD drives.

To uninstall simply delete the `.exe` file from wherever you copied it to.

:information_source: The program does not alter your Windows installation. It creates no registry entries and does not create any configuration files.

## Source Code

Full source code is available from the [delphidabbler/gbg](https://github.com/delphidabbler/gbg) project on GitHub.

## Contributing

Contributions are welcome.

The GitFlow methodology is used. Please fork the repository above then create a feature branch off the `develop` branch. When you have made your changes please rebase you branch onto `develop` then submit a [pull request](https://github.com/delphidabbler/gbg/pulls) on GitHub.

> :no_entry: Pull requests that have been branched from `main` will be rejected.

## Compiling

_gbg_ is compiled using Delphi 12.1. Delphi 11 may work, but has not been tested.

The program can be compiled from the Delphi IDE as 32 bit or 64 bit Windows targets and as either Debug or Release builds. Just choose the appropriate target platform and build configuration in the IDE before building.

The build chain requires DelphiDabbler [Version Information Editor](https://delphidabbler.com/software/vied) ~> v2.15.0 to be installed and for its installation path to be stored in the `VIEDROOT` environment variable. This environment variable can be set in the Delphi _Tools | Options_ dialogue box in the _IDE | Environment Variables_ section: use the _User System Overrides_ section to set `VIEDROOT`.

Releases are built by calling `Deploy.bat`. See the comments in the file for usage information and details of dependencies. The script will compile the 32 and 64 bit release targets and generate a read-me file before finally creating a zip file containing them all.

## Bugs and Feature requests

To suggest new features or report bugs use the _gbg_ [Issues page](https://github.com/delphidabbler/gbg/issues) on GitHub.

## License

_gbg_ is MIT licensed. See `LICENSE.md`.

## Change Log

Changes in each release are documentation in `CHANGELOG.md`.
