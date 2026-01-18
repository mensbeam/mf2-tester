use std::io::{self, Write};
use url::Url;

fn main() {
    let base = Url::parse("http://example.com").unwrap();
    let document =
        microformats::from_reader(io::stdin().lock(), &base).unwrap();
    let json_string = serde_json::to_string_pretty(&document).unwrap();

    io::stdout().write(json_string.as_bytes()).unwrap();
}