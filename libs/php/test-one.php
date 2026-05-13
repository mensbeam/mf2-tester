<?php
error_reporting(E_ALL & ~E_DEPRECATED);
if(count($argv) < 3){
    echo "Usage: ". $argv[0]." <input_file> <base_url>\n";
    die();
}

require 'vendor/autoload.php';

$file = $argv[1];
$data = file_get_contents($file);
$base = $argv[2];

// Use "JSON mode" in the parser, which makes a distinction
//   between empty arrays and empty objects
$p = new Mf2\Parser($data, $base, true);
$output = $p->parse();

echo json_encode($output) . "\n";
