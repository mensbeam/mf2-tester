<?php

declare(strict_types=1);

$testsDir   = getenv('TESTS_DIR');
$resultsDir = getenv('RESULTS_DIR');
$versionOut = getenv('VERSION_FILE');

$errors = [];
if ($testsDir === false) {
    $errors[] = 'TESTS_DIR';
}
if ($resultsDir === false) {
    $errors[] = 'RESULTS_DIR';
}
if ($versionOut === false) {
    $errors[] = 'VERSION_FILE';
}
if ($errors) {
    foreach ($errors as $var) {
        fwrite(STDERR, "Error: environment variable $var is not set\n");
    }
    exit(1);
}

require __DIR__ . '/vendor/autoload.php';

$testsDir = rtrim($testsDir, '/');
$resultsDir = rtrim($resultsDir, '/');

$dir = new RecursiveDirectoryIterator($testsDir, RecursiveDirectoryIterator::SKIP_DOTS);
$iter = new RecursiveIteratorIterator($dir);

foreach ($iter as $file) {
    if ($file->getExtension() !== 'txt') {
        continue;
    }

    $fullPath  = $file->getPathname();
    $relativePath = substr($fullPath, strlen($testsDir) + 1);
    $baseName = substr($relativePath, 0, -4); // strip .txt
    $outJson = $resultsDir . '/' . $baseName . '.json';
    $outErr = $resultsDir . '/' . $baseName . '.err';
    $base = 'http://example.com/';
    if (strpos($fullPath, '/microformats-v2-unit/') !== false) {
        // This is a unit test; these use a different base URL
        $base = 'http://example.test';
    }

    @mkdir(dirname($outJson), 0777, true);

    try {
        $output = \MensBeam\Microformats::fromString(
            file_get_contents($fullPath),
            'text/html;charset=utf8',
            $base,
            [
                'dateNormalization' => false,
                'impliedTz'         => false,
                'lang'              => false,
                'thoroughTrim'      => false,
            ]
        );
        file_put_contents($outJson, \MensBeam\Microformats::toJson($output) . "\n");
    } catch (\Throwable $e) {
        file_put_contents($outErr, $e);
    }
}

$version = \Composer\InstalledVersions::getPrettyVersion('mensbeam/microformats') ?? 'unknown';
file_put_contents($versionOut, $version . "\n");
