var Microformats = require('microformat-node')

var infile = process.argv[2];

if (infile === undefined) {
  console.log("Usage: " + process.argv[1] + " <inputfile>");
  process.exit(1);
}

var base = 'http://example.com/';
if (infile.indexOf("vendor/mf2/tests/tests/microformats-v2-unit/") === 0) {
    // This is a unit test; these use a different base URL
    base = 'http://example.test';
}

var fs = require("fs");

fs.readFile(infile, "utf8", function (err, data) {
    if (err) throw err;
     var Microformats = require('microformat-node'),
        options = {};

    options.html = data
    options.baseUrl = base
    Microformats.get(options, function(err, outdata){
        console.log("%j", outdata)
        // do something with data
    });
});

