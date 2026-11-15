# Laragear voice: style reference

The technical-writing voice of the Laragear READMEs (CacheQuery, Turnstile, TwoFactor, by DarkGhostHunter). The hard rules in `SKILL.md` (punctuation bans, paragraph length, backticks, section endings) apply on top of this page and are not repeated here.

## Persona

A pragmatic solo maintainer talking to a fellow Laravel developer, with one goal: the reader productive in minutes. Trust the reader ("You may...", "You're free to...") and give opinionated guardrails only where a mistake hurts (lockouts, security, caching bugs). The English is clear and functional, with the slight non-native texture of a Spanish-speaking developer. Never ornate.

## Syntax

- Simple declaratives for facts: "This library wraps...", "The middleware will...". A trailing clause for consequences: "...which will avoid conflicts with other cached keys".
- A standalone ultra-short punch line when it earns it: "That's it."
- Rhythm: explain in one or two sentences, show a code block, then move on with "Alternatively..." or "You may also...".
- Parentheticals sparingly, for asides like "(or a group of routes)".
- The only question device is a plain heading like "How does it work?". No transitions that add no information.

## Diction

- "May" for options ("You may disable this..."), "can" as the secondary.
- Imperatives for safety: "ensure", "remember", "make sure", "use X instead".
- Capitalize domain nouns like proper terms: Challenge, Shared Secret, Recovery Codes, Widget, Request, Authenticator app, Container, Facade.
- Plain, slightly colloquial verbs: "fire up Composer", "hammered", "go full manual", "stop bots", "double-check".
- Stock connectors: "By default,", "Once done,", "For example,", "Alternatively,", "Finally,", "Of course,", "Instead,".
- No corporate buzzwords, no slang beyond mild idiom.

## Tone

- Second person ("you"), with an occasional inclusive "we" in examples.
- Confident and unceremonious. Occasional playful lines are fine ("blatantly copy-and-paste this code"), at most one dry quip per document.
- Candid about limits: flag "not recommended" or "may be undesirable" and give the reason in one clause. Matter-of-fact about security, no drama.
- Never apologize, hedge at length or lecture. Warn briefly and move on.
- Never explain what the Laravel developer already knows; explain only what the documented package adds.
- No first-person anecdotes beyond "allows me to keep this package free". No passive academic register; prefer "You may..." and "The method returns...".

## Fingerprints

- **Admonition ladder.** GitHub callouts `Tip` (helpful extra), `Note` (caveat), `Important` (must-read), `Warning` (failure modes), each 1 to 3 sentences, right after the relevant code or paragraph.
- **Bold and italics.** Bold the words that carry risk or contrast (**same**, **never**, **ensure**); italicize single contrasting words (*any*, *cache*, *throw*).
- **Code first.** Every snippet starts with its `use` statements. Routes use `Route::post('comment', ...)` and the "comment" scenario recurs. Code comments are short fragments ("// ...", "// Skip if the user is authenticated.").
- **Placeholders.** `// ...` for omitted logic, `...` for omitted values.
- **Stock phrases.** "Fire up Composer and require this package", "That's it.", "by default", "great if you only have a few...", "mostly enough when...".
- **Audience asides.** Name adjacent tools in a list: "scaffolding packages like Laravel UI, Breeze, Fortify, JetStream, Inertia or Livewire, to name some".
- **Warning by consequence.** State risk as a plain consequence: "...he may be locked out forever...".
- **Env/config pairs.** The config array, then the `.env` equivalent: `TURNSTILE_SITE_KEY=...`.
- **Cross-links.** In-page anchors generously: "[by default](#form-key)". RFCs and vendor docs are linked inline; no other external citations.
- Numbered lists only for sequential setup steps; no nested bullet hierarchies.

## Idiosyncrasies

Sprinkle 1 or 2 per page, never in code:
- Missing subject or article: "Is not suggested to use the middleware on GET methods", "Once the challenge is retrieved, is saved into the Application Container."
- Gendered default for the user: "he must sync...", "ask him to print them".
- Slightly off preposition or form: "the number of codes... is configurable", "less secure", "to easy your development pain".
- Mild casing variance in headings and terms. Do not manufacture typos.

## Worked example

Note the "You may use" opening, the `use` statements, the consequence sentence, the admonition close, the anchor link and the single idiosyncrasy in the last sentence.

````markdown
## Usage

You may use the `throttle` middleware on any route that may be hammered by bots.

```php
use App\Http\Controllers\CommentController;
use Illuminate\Support\Facades\Route;

Route::post('comment', [CommentController::class, 'store'])
    ->middleware('throttle:comment');
```

By default, users may send 5 requests per minute, which is mostly enough when a human is writing a comment. You may also change the limit in the [configuration file](#configuration).

> [!WARNING]
> Ensure the limit is not too low, or the user may be locked out of the action for a full minute.

Alternatively, you may go full manual and call the `Limiter::tooManyAttempts()` method yourself. Is not suggested to throttle GET routes, since these are cached most of the time.
````
