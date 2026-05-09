<?php
error_reporting(E_ALL & ~E_DEPRECATED);
if(count($argv) < 2){
    echo "Usage: ". $argv[0]." <inputfile>\n";
    die();
}

require 'vendor/autoload.php';

$file = $argv[1];
$data = file_get_contents($file);
$base = 'http://example.com/';
if (strpos($file, "/microformats-v2-unit/") !== false) {
    // This is a unit test; these use a different base URL
    $base = 'http://example.test';
}

// Use "JSON mode" in the parser, which makes a distinction
//   between empty arrays and empty objects
$p = new Mf2\Parser($data, $base, true);
$output = $p->parse();

echo json_encode($output) . "\n";
