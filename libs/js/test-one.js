const { mf2 } = require('microformats-parser');

var infile = process.argv[2];
var base = process.argv[3];

if (infile === undefined || base === undefined) {
  console.log("Usage: " + process.argv[1] + " <input_file> <base_url>");
  process.exit(1);
}

var fs = require("fs");

fs.readFile(infile, "utf8", function (err, data) {
    if (err) throw err;

    const parsed = mf2(data, {
        baseUrl: base,
    });
    console.log("%j", parsed);
});
