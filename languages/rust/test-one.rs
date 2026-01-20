use std::io::{self, Write};

fn main() {
    let argv: Vec<String> = std::env::args().collect();
    let file = &argv[2];

    let mut base_str = "http://example.com";
    if file.contains("/microformats-v2-unit/") {
        // This is a unit test; these use a different base URL
        base_str = "http://example.test";
    }
    let base = url::Url::parse(base_str).unwrap();

    let data = std::fs::read_to_string(file).expect("Could not read file");
    let document =
        microformats::from_html(&data, &base).unwrap();
    let json_string = serde_json::to_string_pretty(&document).unwrap();

    io::stdout().write(json_string.as_bytes()).unwrap();
}