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

$output = \MensBeam\Microformats::fromString($data, "text/html;charset=utf8", $base, [
    'dateNormalization' => false,
    'impliedTz' => false,
    'lang' => false,
    'thoroughTrim' => false,
]);

echo \MensBeam\Microformats::toJson($output) . "\n";
