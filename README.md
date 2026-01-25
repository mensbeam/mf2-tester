# mf2-tester
bash scripts to test microformats parsers.

To run:

```sh
./setup.sh
./update.sh
./build.sh
```

The result is an HTML report at `results/index.html` with accompanying input and output files. Execution of `build.sh` will be faster if [GNU Parallel](https://www.gnu.org/software/parallel/) is installed on the system.

Currently the following libraries are exercised:

- Go: [microformats](https://pkg.go.dev/willnorris.com/go/microformats)
- JavaScript: [microformat-node](https://www.npmjs.com/package/microformat-node), [microformats-parser](https://www.npmjs.com/package/microformats-parser)
- Perl: [Web::Microformats2](https://metacpan.org/pod/Web::Microformats2)
- PHP: [php-mf2](https://packagist.org/packages/mf2/mf2), [mensbeam/microformats](https://packagist.org/packages/mensbeam/microformats)
- Python: [mf2py](https://pypi.org/project/mf2py/)
- Ruby: [microformats-ruby](https://rubygems.org/gems/microformats)
- Rust: [Microformats for Rust](https://crates.io/crates/microformats)

If the required software to exercise a library is not available it will be skipped.

## Adding a library

The infrastructure required to add a library consists of the following things:

- A directory under `languages/` which contains the following files:
    - `label`: contains a short human-readable name for the library, used in the table header of the report
    - `link`: contains the URL for the library, preferrably pointing to its entry in a programming language package registry
    - `tools`: contains a space-separated list of all the command-line tools required to install, update, and exercise the library
    - `version.sh`: a script which retrieves and prints the currently installed version of the library. It will be executed during report generation from the `deps/` directory
    - `test.sh`: a script which will set up and execute a test program; the requirements for this script are detailed below
    - A file with source code for a test program, the requirements for which are detailed below
- Entries in the the relevant repository registry files in the `deps/` directory for installing and updating the library
- Commands in `setup.sh` to install a pinned version of the library, if they don't already exist
- Commands in `update.sh` to update to the latest version of the library, if they don't already exist

### The test program

The test program need only read a single HTML file, process it for microformats, and then print [a standard Microformats 2 JSON structure](https://microformats.org/wiki/microformats2-parsing#parse_a_document_for_microformats) to standard output. The following things should be borne in mind when designing a test program:

- The working directory will be the `deps/` directory
- The formatting of the JSON output is unimportant; it will be normalized after execution
- The standard error stream of the program will be captured. If the program prints anything to standard error it is assumed to have failed to complete the test
- The program may use non-default library settings to disable experimenal features in order to pass the tests, but should not modify its input or output
- The base URL of most tests is `http://example.com/`, however the base URL of tests in the `microformats-v2-unit` directory is `http://example.test/`

### The `test.sh` script

The `test.sh` file is a Bash script whose responsibility it is to set up and execute the test program for a given library. At minimum the file must contain a `test_one` function with the commands necessary to execute the test program for a single test input file. The function receives three arguments:

1. The absolute path of the test file to process
2. The absolute path of the directory containing the `test.sh` script
3. The absolute path of the `deps/` directory

The script may also contain commands prior to the `test_one` function to e.g. compile the test program. The `test_one` function will then be executed once for each input file in the test suite.

The script is `source`d during execution of `build.sh`. During the script's execution the `$here` variable contains the absolute path to the directory containing the `test.sh` script, and the working directory is the `deps/` directory. Note that the `$here` variable is not available during execution of the `test_one` function; the same information is available from the `$2` argument within the function context, however.


## Dependency management

Because the tester interacts with libraries written in a large number of programming languages, it relies upon language-specific dependency managers to limit the complexity of setting up the build and/or execution environment for each language. Not all of these dependency managers are always easy to install, however, so some notes are included here to ease initial set-up.

### Go

All that is required for Go is the [Go compiler](https://go.dev/dl/). It is available from most system package managers.

### JavaScript

Distributions of [Node.js](https://nodejs.org/en/download) include the required `npm` dependency manager program. Node.js is available from most system package managers.

### Perl

The [Carton](https://metacpan.org/pod/Carton) dependency manager for Perl is available from most system package managers. If it is not packaged by your distributor, it may be installed with the more widely available CPAN package manager:

```sh
cpan Carton
```

### PHP

The [Composer](https://getcomposer.org/doc/00-intro.md#installation-linux-unix-macos) dependency manager for PHP is available from most system package managers. If it not packaged by your distributor the installer from the Composer Web site may be used as long as the PHP interpreter is installed.

### Python

While `pip` is the standard package for Python, managing dependencies with it locally can be complex and error-prone. We therefore rely on the [uv Python environment manager](https://docs.astral.sh/uv/#installation) instead. It is available from many system package managers, but if it is not packaged by your distributor the linked Web site offers many alternatives means of installation.

### Ruby

Ruby's [Bundler](https://bundler.io) dependency manager is usually installed alongside Ruby, or is available separately from many system package managers. Alternatively it can be installed as a Ruby gem:

```sh
gem install bundler
```

### Rust

The Cargo dependency manager is typically installed as part of a complete Rust programming environment. The recommended way of [setting up a Rust programming environment](https://rust-lang.org/tools/install/) is by using `rustup`, which is available from most system package managers.

