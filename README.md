# mf2-tester
bash scripts to test microformats parsers.

To run:

```sh
./do setup
./do update
./do build
```

The result is an HTML report at `results/index.html` with accompanying input and output files. Execution of `./do build` will be faster if [GNU Parallel](https://www.gnu.org/software/parallel/) is installed on the system.

Currently the following libraries are exercised:

- C#: [Microformats](https://www.nuget.org/packages/Microformats)
- Elixir: [microformats2](https://hex.pm/packages/microformats2)
- Go: [microformats](https://pkg.go.dev/willnorris.com/go/microformats)
- JavaScript: [microformat-node](https://www.npmjs.com/package/microformat-node), [microformats-parser](https://www.npmjs.com/package/microformats-parser)
- Perl: [Web::Microformats2](https://metacpan.org/pod/Web::Microformats2)
- PHP: [php-mf2](https://packagist.org/packages/mf2/mf2), [mensbeam/microformats](https://packagist.org/packages/mensbeam/microformats)
- Python: [mf2py](https://pypi.org/project/mf2py/)
- Ruby: [microformats-ruby](https://rubygems.org/gems/microformats), [MicroMicro](https://rubygems.org/gems/micromicro)
- Rust: [Microformats for Rust](https://crates.io/crates/microformats)

If the required software to exercise a library is not available it will be skipped.

## Libraries not included

A few other libraries are known to be available and were evaluated for inclusion, but were rejected for one reason or another. These are:

- [microformats2-parser for Haskell](https://hackage.haskell.org/package/microformats2-parser); I was unable to get a Haskell test program to compile
- [microformats for Racket](https://pkgs.racket-lang.org/package/microformats); Racket tooling does not seem to allow pinning dependency versions

Help with resolving these problems would be greatly appreciated.

## Adding a library

The infrastructure required to add a library consists of a directory under `libs/` which contains the following files:

    - `label`: contains a short human-readable name for the library, used in the table header of the report
    - `link`: contains the URL for the library, preferrably pointing to its entry in a programming language package registry
    - `tools`: contains a space-separated list of all the command-line tools required to install, update, and exercise the library
    - `actions`: an executable script which accepts multiple commands, detailed below
    - A file with source code for a test program, the requirements for which are detailed below
    - Any package registry files required to install and update the library
    - A `.gitignore` file if required
    - `Dockerfile` and `docker-compose.yaml` files to set up the library in a Docker container

### The `actions` script

The `actions` file is a Bash script whose responsibility it is to set up and execute the test program for a given library. It must respond to the following commands as its first argument:

- `setup`: retrieve pinned versions of the library and its dependencies and prepare the environment for compiling/executing the test program
- `update`: update the library and its dependencies and pins their new versions
- `compile`: compile the test program, if the language of the library requires ahead-of-time compilation (otherwise this command is optional)
- `test`: execute the test program; the second argument to the script will be the absolute path to the HTML input file
- `version`: print the currently installed version of the library

The script must be executable. Its working directory can be assumed to be the library's directory under the `libs` directory.

### The test program

The test program need only read a single HTML file, process it for microformats, and then print [a standard Microformats 2 JSON structure](https://microformats.org/wiki/microformats2-parsing#parse_a_document_for_microformats) to standard output. The following things should be borne in mind when designing a test program:

- The working directory will be the library's directory under the `libs` directory
- The formatting of the JSON output is unimportant; it will be normalized after execution
- The standard error stream of the program will be captured. If the program prints anything to standard error this will be made available along with the passing or failing output, if any
- The program may use non-default library settings to disable experimenal features in order to pass the tests, but should not modify its input or output
- The base URL of most tests is `http://example.com/`, however the base URL of tests in the `microformats-v2-unit` directory is `http://example.test/`

## Dependency management

Because the tester interacts with libraries written in a large number of programming languages, it relies upon language-specific dependency managers to limit the complexity of setting up the build and/or execution environment for each language. Not all of these dependency managers are always easy to install, however, so some notes are included here to ease initial set-up.

If any of the tools listed here are not available, alternatively a Docker container will be used instead, if [Docker](https://www.docker.com) and [Docker Compose](https://docs.docker.com/compose/) are installed.

### C# (.NET)

The `dotnet` program is usually provided by a package called `dotnet-host` from most system package managers. A .NET SDK and .NET Runtime are also required.

### Elixir

The `mix` build tool is included as part of a standard Elixir programming environment. It is available from most system package managers.

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

While `pip` is the standard package manager for Python, managing dependencies with it locally can be complex and error-prone. We therefore rely on the [uv Python environment manager](https://docs.astral.sh/uv/#installation) instead. It is available from many system package managers, but if it is not packaged by your distributor the linked Web site offers many alternatives means of installation.

### Ruby

Ruby's [Bundler](https://bundler.io) dependency manager is usually installed alongside Ruby, or is available separately from many system package managers. Alternatively it can be installed as a Ruby gem:

```sh
gem install bundler
```

### Rust

The Cargo dependency manager is typically installed as part of a complete Rust programming environment. The recommended way of [setting up a Rust programming environment](https://rust-lang.org/tools/install/) is by using `rustup`, which is available from most system package managers.
