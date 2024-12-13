<?php

/**
 * This file is part of Dockerize, a PHP Experts, Inc., Project.
 *
 * Copyright © 2024 PHP Experts, Inc.
 * Author: Theodore R. Smith <theodore@phpexperts.pro>
 *   GPG Fingerprint: 4BF8 2613 1C34 87AC D28F  2AD8 EB24 A91D D612 5690
 *   https://www.phpexperts.pro/
 *   https://github.com/PHPExpertsInc/dockerize
 *
 * This file is licensed under the MIT License.
 */

class PhpVersionExtractor
{
    private $allVersions = ['5.6', '7.0', '7.1', '7.2', '7.3', '7.4', '8.0', '8.1', '8.2', '8.3', '8.4'];
    private $composerJson;
    public $versionConstraint;

    public function __construct($composerJson)
    {
        $this->composerJson = $composerJson;
    }

    public function getPhpVersionConstraint()
    {
        if ($this->versionConstraint === null) {
            $this->getPhpVersions();
        }

        return $this->versionConstraint;
    }

    public function getPhpVersions()
    {
        $phpConstraint = $this->extractPhpConstraint();
        $this->versionConstraint = $phpConstraint;

        if (is_null($phpConstraint)) {
            return implode(' ', $this->allVersions);
        }

        $selectedVersions = [];

        foreach ($this->allVersions as $version) {
            if ($this->versionSatisfies($version, $phpConstraint)) {
                $selectedVersions[] = $version;
            }
        }

        return implode(' ', $selectedVersions);
    }

    private function extractPhpConstraint()
    {
        if (!is_readable($this->composerJson)) {
            return null;
        }

        $data = json_decode(file_get_contents($this->composerJson), true);

        if (isset($data['require']) && isset($data['require']['php'])) {
            return $data['require']['php'];
        }

        return null;
    }

    private function versionSatisfies($version, $constraints)
    {
        $constraints = str_replace(' ', '', $constraints);
        $constraints = explode(',', $constraints);

        foreach ($constraints as $constraint) {
            if (preg_match('/^(>=|<=|>|<|=|~|\^)?(\d+\.\d+)/', $constraint, $matches)) {
                $operator = isset($matches[1]) ? $matches[1] : '=';
                $constraintVersion = $matches[2];

                if (!$this->compareVersion($version, $operator, $constraintVersion)) {
                    return false;
                }
            }
        }

        return true;
    }

    private function compareVersion($version, $operator, $constraintVersion)
    {
        switch ($operator) {
            case '>=':
                return version_compare($version, $constraintVersion, '>=');
            case '<=':
                return version_compare($version, $constraintVersion, '<=');
            case '>':
                return version_compare($version, $constraintVersion, '>');
            case '<':
                return version_compare($version, $constraintVersion, '<');
            case '~':
            case '^':
                return version_compare($version, $constraintVersion, '>=') && version_compare($version, $this->getUpperVersionLimit($constraintVersion, $operator), '<');
            case '=':
            default:
                return version_compare($version, $constraintVersion, '==');
        }
    }

    private function getUpperVersionLimit($version, $operator)
    {
        list($major, $minor) = explode('.', $version);
        if ($operator === '^') {
            return ($major + 1) . '.0';
        } elseif ($operator === '~') {
            return $major . '.' . ($minor + 1);
        }

        return $version;
    }
}

// Usage example
$composerJson = 'composer.json';
$extractor = new PhpVersionExtractor($composerJson);
echo $extractor->getPhpVersions();
