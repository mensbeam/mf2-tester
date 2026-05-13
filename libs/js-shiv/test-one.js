var Microformats = require('microformat-node')

var infile = process.argv[2];
var base = process.argv[3];

if (infile === undefined || base === undefined) {
  console.log("Usage: " + process.argv[1] + " <input_file> <base_url>");
  process.exit(1);
}

var fs = require("fs");

fs.readFile(infile, "utf8", function (err, data) {
    if (err) throw err;
    var Microformats = require('microformat-node'),
    options = {
        html: data,
        baseUrl: base,
        textFormat: "whitespacetrimmed",
        dateFormat: "auto",
    };

    Microformats.get(options, function(err, outdata){
        console.log("%j", outdata)
        // do something with data
    });
});
