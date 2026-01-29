const { mf2 } = require('microformats-parser')

var infile = process.argv[2];

if (infile === undefined) {
  console.log("Usage: " + process.argv[1] + " <inputfile>");
  process.exit(1);
}

var base = 'http://example.com/';
if (infile.indexOf("/microformats-v2-unit/") > -1) {
    // This is a unit test; these use a different base URL
    base = 'http://example.test';
}

var fs = require("fs");

fs.readFile(infile, "utf8", function (err, data) {
    if (err) throw err;

    const parsed = mf2(data, {
        baseUrl: base,
    });
    console.log("%j", parsed);
});

