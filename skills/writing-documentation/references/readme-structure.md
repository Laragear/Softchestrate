# README skeleton (package READMEs)

Follow this order when writing a package README from scratch. The section pattern below also guides restructuring an existing one.

1. `# Title`, then the badge row.
2. A one-sentence tagline, plain and benefit-first, sometimes with a mild joke ("Yes, only one.").
3. A small code teaser, 3–10 lines, showing the package's best moment.
4. An optional `Tip` or `Important` admonition for an adjacent product.
5. `## Become a sponsor`: a banner image, then a short plea: "Your support allows me to keep this package free, up-to-date and maintainable. Alternatively, you can **spread the word...**". Include it when the project accepts sponsorship, otherwise omit it and keep the order.
6. `## Requirements`, a 2-item list: PHP version and Laravel version ("or later").
7. `## Installation`: one sentence, then a single `composer require` block. The sentence is usually "Fire up Composer and require this package".
8. `## How does it work?`: 1–3 short paragraphs of mechanism.
9. `## Usage` (or `## Setup`), then feature sections, then `## Configuration`: the publish command first, then the full config array, then one `###` section per key.
10. Closing boilerplate, in this order:
    - `## Laravel Octane compatibility`: four "no singletons/static properties..." bullets, then the sentence "There should be no problems...".
    - `## Security`: how to contact the maintainer about vulnerabilities.
    - `# License`: MIT "at time of publishing", plus the Laravel trademark line.

## Section pattern

Every feature section follows the same shape:

1. **Open** with a one-sentence statement of what the feature is or does, often starting with "You may use...", "The `x` method..." or "By default...".
2. **Develop** with a code block, then a sentence on its behavior or consequence, then variants introduced by "Alternatively," or "You may also".
3. **Close** with an admonition (`Tip`, `Note`, `Important`, `Warning`) or a cross-link. Not a summary sentence. Sections end abruptly once the information is delivered.

## Headings

`##` for features, `###` for sub-features, `####` for variants. Noun phrases or gerunds: "Forgetting cached results", "Validating with Rule". Title or sentence case, with mild inconsistency.

## Reference tables

Use them for fluent method lists (`Method | Description`). The description column holds short sentence fragments ending in periods.

## Configuration sections

Repeat this pattern: the `vendor:publish` command, a `return [...]` snippet with the full config array, then one `###` per key holding 1–3 sentences on what it controls and the sensible default. Where the key reads from the environment, show the `.env` equivalent right after the snippet.

## Top of README, for reference

````markdown
# Cache Query

<!-- badge row: packagist version, packagist downloads, license, tests, ... -->

Cache the results of your database queries with a single method. Yes, only one.

```php
$users = User::where('is_admin', true)->cache()->get();
```
````
