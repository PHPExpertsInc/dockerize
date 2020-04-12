#!/bin/env php
<?php
system('cp ./docker/docker-compose.base.yml ./docker-compose.yml');

installDockerEngines();

function installDockerEngines()
{
    $engines = chooseDockerEngines();

    if ($engines[0] === 'None') {
        return;
    }

    foreach ($engines as $engine) {
        installDockerEngine($engine, "engines/$engine");
    }

    printError('You must edit your docker-compose.yml file now.', 'Warning');
}

/**
 * @param string $engine
 * @param string $enginePath
 */
function installDockerEngine($engine, $enginePath)
{
    if (!is_dir($enginePath)) {
        printError("Cannot find '$enginePath' directory.");
        exit(1);
    }

    echo "Installing the $engine Docker engine...\n";
    if (is_dir("./$enginePath/bin")) {
        system("cp -v ./$enginePath/bin/* ./bin");
    }
    system("cat \"./$enginePath/docker-compose.stub.yml\" >> ./docker-compose.yml");
    system('echo >> ./docker-compose.yml');
}

function chooseDockerEngines($path = 'engines', $filtered = [])
{
    if (!is_dir($path)) {
        printError("Cannot find '$path' directory.");
        exit(1);
    }

    $engines = getDirs($path, false, $filtered);
    array_unshift($engines, 'None');
    $selection = '';
    $selectedChoices = [];
    while ($selection === '') {
        echo "Choose engine (e.g., '1 3' for both $engines[1] and $engines[3]):\n";
        foreach ($engines as $index => $engine) {
            echo "$index) $engine\n";
        }

        $selection = getUserInput();
        $selectedChoices = explode(' ', $selection);

        if (count($selectedChoices) > 1 && in_array(0, $selectedChoices)) {
            printError("'$engines[0]' must be selected by itself.");
            $selection = '';
        }

        $invalidChoices = array_diff($selectedChoices, array_keys($engines));

        if (!empty($invalidChoices)) {
            printError('Invalid choice(s): ' . implode(', ', $invalidChoices));
            $selection = '';
        }
    }

    $selectedEngines = array_values(array_intersect_key($engines, array_flip($selectedChoices)));

    return $selectedEngines;
}

function printError($error, $messageType = 'Error')
{
    echo "\nv v v v v v v v v v v v v v v v v v v v v v v\n";
    echo "--> $messageType: $error\n";
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
        throw new RuntimeException("$path does not exist.");
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

