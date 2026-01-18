# mf2-tester
bash scripts to test microformats parsers.

To run:

```sh
./setup.sh
./update.sh
./build.sh
```

Results are published at https://dissolve.github.io/mf2-tester/

Currently the following libraries are exercised:

- Go: [microformats](https://pkg.go.dev/willnorris.com/go/microformats)
- JavaScript: [microformat-node](https://www.npmjs.com/package/microformat-node), [microformats-parser](https://www.npmjs.com/package/microformats-parser)
- PHP: [php-mf2](https://packagist.org/packages/mf2/mf2)
- Python: [mf2py](https://pypi.org/project/mf2py/)
- Ruby: [microformats-ruby](https://rubygems.org/gems/microformats)
- Rust: [Microformats for Rust](https://crates.io/crates/microformats)