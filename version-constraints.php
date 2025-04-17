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

/**
 * Utility class for working with Composer version constraints.
 *
 * Provides methods for validating constraints, checking if a version satisfies
 * a constraint (using the authoritative Composer library), and generating
 * example versions that match constraints.
 *
 * Copied with permission from phpexperts/composer-constraints-parser
 */
class ComposerConstraintsHelper
{
    /**
     * Check if a version satisfies a constraint.
     *
     * @param string $constraints Version constraint (can contain OR/AND operators)
     * @param string $version Version to check
     * @return bool True if the version satisfies the constraint
     */
    public function versionSatisfies($constraints, $version)
    {
        // Normalize version to have at least 3 parts
        $version = self::ensure2Dots($version);

        // Normalize constraint formatting
        $constraints = $this->normalizeConstraints($constraints);

        // Split constraint by OR operator (| or -)
        $orConstraints = preg_split('/[|-]/', $constraints);

        foreach ($orConstraints as $orConstraint) {
            $orConstraint = trim($orConstraint);

            // Split by AND operator (,)
            $andConstraints = preg_split('/[ ,]/', $orConstraint);
            $allAndSatisfied = true;

            foreach ($andConstraints as $singleConstraint) {
                if (!empty($singleConstraint) && !$this->satisfiesSingleConstraint($singleConstraint, $version)) {
                    $allAndSatisfied = false;
                    break;
                }
            }

            if ($allAndSatisfied) {
                return true; // If all AND conditions in this OR branch are satisfied, version is valid
            }
        }

        return false;
    }

    /**
     * Ensures a version string has at least 3 parts (major.minor.patch).
     *
     * @param string $version Version to normalize
     * @return string Normalized version with at least 3 parts
     */
    private static function ensure2Dots($version)
    {
        $versionParts = explode('.', $version);
        if (count($versionParts) < 3) {
            $version .= str_repeat('.0', 3 - count($versionParts));
        }

        return $version;
    }

    /**
     * Normalize constraint string formatting.
     *
     * @param string $constraints Constraints to normalize
     * @return string Normalized constraints
     */
    private function normalizeConstraints($constraints)
    {
        // Convert "* >" to ">" and other normalizations
        $constraints = preg_replace('/\* ?([><!]=?)\s*/', '$1', $constraints);
        $constraints = preg_replace('/^ ?([><!]=?)\s*/', '$1', $constraints);
        $constraints = str_replace('. *', '.*', $constraints);

        // Normalize spaces around commas and hyphens
        $constraints = str_replace([' ,', ', '], ',', $constraints);
        $constraints = str_replace([' -', '- '], '-', $constraints);

        return $constraints;
    }

    /**
     * Check if a version satisfies a single constraint.
     *
     * @param string $constraint Single constraint without AND/OR operators
     * @param string $version Version to check
     * @return bool True if the version satisfies the constraint
     */
    private function satisfiesSingleConstraint($constraint, $version)
    {
        // Edge cases
        if ($constraint === 'x' || $constraint === '*') {
            return true;
        }

        // Always pass dev/rc branches
        if ($this->strEndsWith($constraint, '-dev') || $this->strEndsWith($constraint, '-rc')) {
            return true;
        }

        // Strip v prefix
        $constraint = preg_replace('/([><=~^]+)?v/i', '$1', $constraint);
        $version = preg_replace('/v([0-9]+)/i', '$1', $version);

        // Normalize hyphen ranges (e.g., "1.0 - 2.0" to ">=1.0 <2.0")
        $constraint = self::normalizeHyphenRanges($constraint);

        // Format standardization
        $constraint = preg_replace('/([><!]=?)\s*/', '$1', $constraint);
        $constraint = preg_replace('/\* ?([><!]=?)\s*/', '$1', $constraint);
        $constraint = str_replace('. *', '.*', $constraint);

        // Handle trailing dot (e.g., "1.0.")
        // This effects 615 projects as of 2025-03-24.
        // @see rinsvent/data2dto
        if ($this->strEndsWith($constraint, '.')) {
            $constraint = substr($constraint, 0, -1);
        }

        // Replace .x with .*
        $constraint = str_ireplace('.x', '.*', $constraint);

        // Handle wildcards
        if (strpos($constraint, '*') !== false) {
            $pattern = str_replace('.', '\.', $constraint);
            $pattern = str_replace('*', '(\d+){1,2}', $pattern);
            return preg_match('/^' . $pattern . '/', $version) === 1;
        }

        // Handle caret (^) - allows changes that don't modify the left-most non-zero digit
        if ($this->strStartsWith($constraint, '^')) {
            return $this->handleCaretConstraint($constraint, $version);
        }

        // Handle tilde (~) - allows the specified precision of version
        if ($this->strStartsWith($constraint, '~')) {
            return $this->handleTildeConstraint($constraint, $version);
        }

        // Handle comparison operators (>, >=, <, <=, =)
        if (preg_match('/^([><=]+)(\d+(\.\d+)?(\.\d+)?)/', $constraint, $matches)) {
            $operator = $matches[1];
            $compareVersion = self::ensure2Dots($matches[2]);
            return version_compare($version, $compareVersion, $operator);
        }

        // Handle exact version
        if (preg_match('/^\d+(\.\d+)?(\.\d+)?$/', $constraint)) {
            $constraint = self::ensure2Dots($constraint);
            return version_compare($version, $constraint, '==');
        }

        return false; // Unknown constraint format
    }

    /**
     * Handle caret (^) constraint matching.
     *
     * @param string $constraint Caret constraint (e.g., "^1.2.3")
     * @param string $version Version to check
     * @return bool True if the version satisfies the constraint
     */
    private function handleCaretConstraint($constraint, $version)
    {
        $baseVersion = substr($constraint, 1);
        $baseVersion = self::ensure2Dots($baseVersion);

        if (preg_match('/^0\.(\d+)/', $baseVersion, $matches)) {
            // Special case for 0.x: only allow changes in patch version
            $minor = (int)$matches[1];
            $nextMinor = "0." . ($minor + 1) . ".0";
            return version_compare($version, $baseVersion, '>=') &&
                version_compare($version, $nextMinor, '<');
        } elseif (preg_match('/^(\d+)/', $baseVersion, $matches)) {
            // Normal case: allow everything that doesn't change the major version
            $major = (int)$matches[0];
            $nextMajor = ($major + 1) . ".0.0";
            return version_compare($version, $baseVersion, '>=') &&
                version_compare($version, $nextMajor, '<');
        }

        return false;
    }

    /**
     * Handle tilde (~) constraint matching.
     *
     * @param string $constraint Tilde constraint (e.g., "~1.2.3")
     * @param string $version Version to check
     * @return bool True if the version satisfies the constraint
     */
    private function handleTildeConstraint($constraint, $version)
    {
        $baseVersion = substr($constraint, 1);
        $parts = explode('.', $baseVersion);
        $major = (int)($parts[0] ?? 0);
        $minor = (int)($parts[1] ?? 0);
        $nextMinor = "$major." . ($minor + 1) . ".0";
        $baseVersion = self::ensure2Dots($baseVersion);
        return version_compare($version, $baseVersion, '>=') &&
            version_compare($version, $nextMinor, '<');
    }

    /**
     * Converts hyphen ranges (e.g., "5 - 6") to standard comparison operators.
     *
     * @param string $constraint Constraint with potential hyphen ranges
     * @return string Normalized constraint
     */
    private static function normalizeHyphenRanges($constraint)
    {
        // Convert "X - Y" to ">=X <Y"
        return preg_replace_callback(
            '/(\d+(?:\.\d+)*)\s*-\s*(\d+(?:\.\d+)*)/',
            function ($matches) {
                $lower = self::ensure2Dots($matches[1]);
                $upper = self::ensure2Dots($matches[2]);
                return ">=$lower <$upper";
            },
            $constraint
        );
    }

    /**
     * Check if a string starts with a specific substring (PHP < 8.0 compatibility)
     *
     * @param string $haystack The string to search in
     * @param string $needle The substring to search for
     * @return bool Returns true if haystack starts with needle
     */
    private function strStartsWith($haystack, $needle)
    {
        return strpos($haystack, $needle) === 0;
    }

    /**
     * Check if a string ends with a specific substring (PHP < 8.0 compatibility)
     *
     * @param string $haystack The string to search in
     * @param string $needle The substring to search for
     * @return bool Returns true if haystack ends with needle
     */
    private function strEndsWith($haystack, $needle)
    {
        $length = strlen($needle);
        if ($length === 0) {
            return true;
        }
        return substr($haystack, -$length) === $needle;
    }
}

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
            if ((new ComposerConstraintsHelper())->versionSatisfies($phpConstraint, $version)) {
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

}

// Usage example
$composerJson = 'composer.json';
$extractor = new PhpVersionExtractor($composerJson);
echo $extractor->getPhpVersions();
