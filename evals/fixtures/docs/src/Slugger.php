<?php

namespace Acme;

class Slugger
{
    public const DEFAULT_SEPARATOR = '-';

    /** Turn a title into a URL slug. */
    public function slugify(string $title, string $separator = self::DEFAULT_SEPARATOR): string
    {
        $slug = strtolower(trim(preg_replace('/[^A-Za-z0-9]+/', $separator, $title), $separator));

        return $slug;
    }

    /** Limit a slug to a maximum length without cutting the last word. */
    public function limit(string $slug, int $max = 50): string
    {
        return strlen($slug) <= $max ? $slug : substr($slug, 0, strrpos(substr($slug, 0, $max), self::DEFAULT_SEPARATOR));
    }
}
