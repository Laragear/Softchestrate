# Language shapes and worked examples

Every source above the guide outranks every row below. Use a row only when no file you opened shows the form, and trace it as `guide: language-shapes, <language>`. For a language not listed, copy the shapes siblings use; with no siblings, map by analogy and trace it as `no source`.

## Contents
- Shapes by language
- Worked examples: negations, flags and marks, builders, full doc comments

## Shapes by language

| Language | Predicate and negation | Accessor | Deferral flag | Failure type | Callable | Doc comment |
| -------- | ---------------------- | -------- | ------------- | ------------ | -------- | ----------- |
| PHP | `isConnected()`, `isNotConnected()` | `getName()` | named argument `save: false` | `...Exception` | `__invoke()` | PHPDoc `/** */` |
| C# | property `IsConnected`, `IsNotConnected` | property `Name` | optional parameter `bool save = true` | `...Exception` | delegate | XML doc `///` |
| Kotlin | property `isConnected`, `isNotConnected` | property `name` | default parameter `save = true` | `...Exception` | `operator fun invoke()` | KDoc `/** */` |
| Python | property `is_connected`, `is_not_connected` | property `name` | keyword `persist=False` | `...Error` | `__call__` | docstring |
| Ruby | `connected?`, `not_connected?` | `name` | keyword `save: false` | `...Error` | `call` | YARD or RDoc `#` |
| TypeScript, JavaScript | `isConnected()`, `isNotConnected()` | `getName()` or `get name()` | options object `{ save: false }` | `...Error` | function value | TSDoc or JSDoc `/** */` |
| Go | `IsConnected()`, `IsNotConnected()` | `Name()` (Effective Go: `Get` is neither idiomatic nor necessary) | extra argument or functional option | follow the standard library (`PathError`) | function value | comment starting with the name |
| Rust | `is_connected()`, `is_not_connected()` (snake_case, per C-CASE) | `name()` (C-GETTER: no `get_` prefix) | options struct | `...Error` in verb-object-error order (C-WORD-ORDER), returned as `Err` | closure or `Fn` implementation | `///` with `# Errors` and `# Panics` sections (C-FAILURE) |

Rust verbs follow snake_case: `flag_as_not_extensive`, `mark_as_not_removed`, `with_geolocation`.

## Worked examples

### Negations

Negations pair up and read as prose.

<example>

```php
if ($server->isNotConnected() && $server->shouldNotReboot()) {
    return;
}
```

```python
if server.is_not_connected and server.should_not_reboot:
    return
```

```rust
if server.is_not_connected() && server.should_not_reboot() {
    return;
}
```

Avoid `isDisconnected()` (an invented alias for a negation) and raw checks such as `connection !== null`. When existing code already offers `isDisconnected()`, use it and trace the divergence.

</example>

### Flags and marks

Flags are binary and idempotent; marks leave evidence. The reverse of each inserts `Not`.

<example>

```php
$article->flagAsExtensive(save: false);     // binary state, persisted later in one write
$article->flagAsNotExtensive(save: false);  // reverse of the flag

$article->markAsRemoved(                    // when + who + why
    remover: $user,
    reason: 'Fake review written by AI',
    save: true,
);

$article->markAsNotRemoved(                 // a new record of when + who + why; history stays
    restorer: $user,
    reason: 'Review verified as genuine',
    save: true,
);
```

```python
article.flag_as_extensive(persist=False)
article.flag_as_not_extensive(persist=False)
article.mark_as_removed(remover=user, reason="Fake review written by AI", persist=True)
article.mark_as_not_removed(restorer=user, reason="Review verified as genuine", persist=True)
```

```ts
article.flagAsNotExtensive({ save: false });
article.markAsNotRemoved({ restorer: user, reason: "Review verified as genuine", save: true });
```

</example>

### Builders

A builder replaces a call that has grown placeholder arguments.

<example>

```php
// Before
$result = $video->transcode('/sample.mp4', 'low', null, ['geo'], true);

// After
$result = Transcode::video($video)
    ->quality('low')
    ->withGeolocation()
    ->to('/sample.mp4');
```

```rust
let result = Transcode::video(&video)
    .quality("low")
    .with_geolocation()
    .to("/sample.mp4")?;
```

</example>

### Full doc comments

A full doc comment is a multi-line block: summary, blank line, context, then every parameter, return and failure entry. A summary-only comment is incomplete. When another paragraph is needed, it belongs to the body, not the PHPDoc.

<example>

Incomplete:

```php
/** Retrieve the users from the filesystem. */
public function users(string $directory): array
```

Full:

```php
/**
 * Retrieve the users as instances from the filesystem.
 *
 * @param  string  $directory  Root folder that holds one file per user.
 * @return array<int, User>  Users in file-name order.
 *
 * @throws UnreadableDirectory  When the directory cannot be read.
 */
public function users(string $directory): array
{
    // Reads one file per user and skips files that fail to parse, so a single
    // corrupt file does not hide the rest.
}
```

```rust
/// Retrieve the users as instances from the filesystem.
///
/// # Errors
///
/// Returns `ReadUsersError` when `directory` cannot be read.
pub fn users(directory: &Path) -> Result<Vec<User>, ReadUsersError>
{
    /// Reads one file per user and skips files that fail to parse, so a single
    /// corrupt file does not hide the rest.
}
```

</example>
