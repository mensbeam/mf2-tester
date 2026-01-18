use std::io::{self, Write};

// FIXME: Allow specifying a base url on the command line.
// FIXME: Allow specifying the inbound URL to parse.
// FIXME: Read HTML from stdin.
fn main() {
    let document =
        microformats::from_reader(io::stdin(), "http://example.com".parse().unwrap()).unwrap();
    let json_string = serde_json::to_string_pretty(&document).unwrap();

    io::stdout().write(json_string.as_bytes()).unwrap();
}