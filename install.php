#!/bin/env php
<?php

namespace PHPExperts\Dockerize;

installPHP();

installDockerEngines();

$DIR = __DIR__;
if (!is_dir('./docker')) {
    if (!mkdir('./docker')) {
        alert('Error: Could not create the ./docker directory. Installation aborted.');
        exit(4);
    }
}
system("cp -r $DIR/docker/web ./docker");

echo "\n";
alert('Next Steps: 1. You should edit your new .env.');
alert('Next Steps: 2. You should add ./bin to your $PATH.');
alert('Get Started: To launch the dockerized app, run: `docker-compose up -d`');

$funding = <<<TEXT
Did you find this project helpful?

Please consider a $5 donation.
  - Cashapp:  \$theocode
  - Patreon:  https://www.patreon.com/hopeseekr
  - Paypal:   hopeseekr@xmule.ws

TEXT;

echo $funding;

function installPHP()
{
    $dockerStub = file_get_contents(__DIR__ . '/docker/docker-compose.base.yml');
    $dockerImages = choosePHPVersions();
    $newDockerCompose = '';

    foreach ($dockerImages as $index => $PHP_IMAGE) {
        $PHP_VERSION = $index > 0 ? str_replace(['-debug', '.'], '', $PHP_IMAGE) : '';
        $PORT = $index === 0 ? '80' : "80{$PHP_VERSION}";

        $versionStub = <<<YAML
  web{$PHP_VERSION}:
    image: phpexperts/web:nginx-php{$PHP_IMAGE}
    volumes:
      - .:/var/www:delegated
      - ./docker/web:/etc/nginx/custom
    ports:
      - {$PORT}:80      
YAML;
        $newDockerCompose .= $versionStub . "\n\n";
    }

    $dockerStub = str_replace('{{PHP_STUB}}', $newDockerCompose, $dockerStub);
    file_put_contents('docker-compose.yml', $dockerStub);
}

function choosePHPVersions()
{
    $PHP_VERSIONS = array_reverse(['5.6', '7.0', '7.1', '7.2', '7.3', '7.4', '8.0', '8.1']);

    $selection = '';
    $selectedChoices = [];
    while ($selection === '') {
        echo "Choose PHP Versions (e.g., '1 3' for both $PHP_VERSIONS[0] and $PHP_VERSIONS[2]):\n";
        foreach ($PHP_VERSIONS as $index => $version) {
            ++$index;
            echo "$index) $version\n";
        }

        $selection = getUserInput();
        $selectedChoices = explode(' ', $selection);
        foreach ($selectedChoices as &$choice) {
            --$choice;
        }

        $invalidChoices = array_diff($selectedChoices, array_keys($PHP_VERSIONS));

        if (!empty($invalidChoices)) {
            alert('Error: Invalid choice(s): ' . implode(', ', $invalidChoices));
            $selection = '';
        }
    }

    $selectedVersions = array_values(array_intersect_key($PHP_VERSIONS, array_flip($selectedChoices)));

    $yesNo = '';
    while (!in_array($yesNo, ['y', 'n'])) {
        echo "\nDo you need Ioncube Decoder support? (y/N)\n";
        $yesNo = getUserInput();
        $yesNo = $yesNo === '' ? 'n' : $yesNo;
    }

    if ($yesNo === 'y') {
        foreach ($selectedVersions as &$version) {
            $version .= '-ioncube';
        }
echo "hmm";
        return $selectedVersions;
    }
    $yesNo = '';

    while (!in_array($yesNo, ['y', 'n'])) {
        echo "\nDo you need Xdebug support? (y/N)\n";
        $yesNo = getUserInput();
        $yesNo = $yesNo === '' ? 'n' : $yesNo;
    }

    if ($yesNo === 'y') {
        foreach ($selectedVersions as &$version) {
            $version .= '-debug';
        }
    }

    return $selectedVersions;
}

function installDockerEngines()
{
    $engines = chooseDockerEngines();

    if ($engines[0] === 'None') {
        return;
    }

    foreach ($engines as $engine) {
        installDockerEngine($engine, __DIR__ . "/engines/$engine");
    }

    system('cp .env.example .env');
}

function chooseDockerEngines($path = null, $filtered = [])
{
    $path = $path !== null ? $path :  __DIR__ . '/engines';
    if (!is_dir($path)) {
        alert("Error: Cannot find '$path' directory.");
        exit(1);
    }

    $engines = getDirs($path, false, $filtered);
    array_unshift($engines, 'None');
    $selection = '';
    $selectedChoices = [];
    while ($selection === '') {
        echo "Choose engines (e.g., '1 3' for both $engines[1] and $engines[3]):\n";
        foreach ($engines as $index => $engine) {
            echo "$index) $engine\n";
        }

        $selection = getUserInput();
        $selectedChoices = explode(' ', $selection);

        if (count($selectedChoices) > 1 && in_array(0, $selectedChoices)) {
            alert("Error: '$engines[0]' must be selected by itself.");
            $selection = '';
        }

        $invalidChoices = array_diff($selectedChoices, array_keys($engines));

        if (!empty($invalidChoices)) {
            alert('Error: Invalid choice(s): ' . implode(', ', $invalidChoices));
            $selection = '';
        }
    }

    $selectedEngines = array_values(array_intersect_key($engines, array_flip($selectedChoices)));

    return $selectedEngines;
}

/**
 * @param string $engine
 * @param string $enginePath
 */
function installDockerEngine($engine, $enginePath)
{
    if (!is_dir($enginePath)) {
        alert("Error: Cannot find '$enginePath' directory.");
        exit(1);
    }

    echo "Installing the $engine Docker engine...\n";
    if (is_dir("$enginePath/bin")) {
        if (!is_dir('./bin')) {
            if (!mkdir('./bin')) {
                alert('Error: Could not create the ./bin directory. Installation aborted.');
                exit(2);
            }
        }
        system("cp $enginePath/bin/* ./bin");
    }
    system("cat \"$enginePath/docker-compose.stub.yml\" >> ./docker-compose.yml");
    system('echo >> ./docker-compose.yml');

    if (file_exists("$enginePath/.env.stub")) {
        overwriteOrAppendFile("$enginePath/.env.stub", '.env.example');
    }

}

function alert($message)
{
    echo "v v v v v v v v v v v v v v v v v v v v v v v\n";
    echo "--> $message\n";
    echo "^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^\n\n";

}

function getUserInput()
{
    return trim(fgets(STDIN));
}

/**
 * Copyright © 2020 Theodore R. Smith <https://www.phpexperts.pro/>
 * License: MIT
 *
 * @see https://stackoverflow.com/a/61168906/430062
 *
 * @param string $path
 * @param bool   $recursive Default: false
 * @param array  $filtered  Default: [., ..]
 * @return array
 */
function getDirs($path, $recursive = false, array $filtered = [])
{
    if (!is_dir($path)) {
        alert("Error: $path does not exist.");
        exit(1);
    }

    $filtered = array_merge(array('.', '..'), $filtered);

    $dirs = array();
    $d = dir($path);
    while (($entry = $d->read()) !== false) {
        if (is_dir("$path/$entry") && !in_array($entry, $filtered)) {
            $dirs[] = $entry;

            if ($recursive) {
                $newDirs = getDirs("$path/$entry");
                foreach ($newDirs as $newDir) {
                    $dirs[] = "$entry/$newDir";
                }
            }
        }
    }

    sort($dirs);

    return $dirs;
}

function overwriteOrAppendFile($srcFile, $destFile, $resetFirstRun = false)
{
    static $firstRun = true;
    if ($resetFirstRun) {
        $firstRun = true;
    }

    if (!file_exists($srcFile)) {
        alert("Error: Cannot find '$srcFile'.");

        exit(3);
    }

    if (!file_exists($destFile)) {
        $srcFile = escapeshellarg($srcFile);
        $destFile = escapeshellarg($destFile);
        system("echo '#### Block Added by phpexperts/dockerize ####' >> $destFile");
        system("cp $srcFile $destFile");
        $firstRun = false;

        return;
    }

    $selection = null;
    $shouldAppend = !$firstRun;
    while ($firstRun && !in_array($selection, [1, 2])) {
        echo "Append or overwrite $destFile? (1: Append, 2: Overwrite) ";
        $selection = getUserInput();
        $shouldAppend = $selection === '1' ? true : false;
    }

    if (!$shouldAppend) {
        $srcFile = escapeshellarg($srcFile);
        $destFile = escapeshellarg($destFile);
        system("cp $srcFile $destFile");
        $shouldAppend = true;
        $firstRun = false;

        return;
    }

    $srcFile = escapeshellarg($srcFile);
    $destFile = escapeshellarg($destFile);
    system("echo >> $destFile");
    system("echo '#### Block Added by phpexperts/dockerize ####' >> $destFile");
    system("cat $srcFile >> $destFile");
    system("echo '#### End Block ####' >> $destFile");

    $firstRun = false;
}
