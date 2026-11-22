---
name: writing-code-comments
description: "Decides when and how to write comments in source code. Covers doc comments for methods, properties and attributes written to ASD-STE100, and inline comments for verbose raw array, vector, string or regex manipulation. Use when the user asks to comment, document, add docblocks or explain code in comments, or when you write code that slices, indexes, reshapes or pattern-matches raw data. Not for README files, guides, docs pages, commit messages or changelogs."
license: MIT
---

# Writing code comments

Comment code where the code cannot say the thing on its own. Describe the contract of each public element, and explain the mechanics of dense low-level data handling. Leave everything else uncommented.

## Workflow

1. Read the code before writing a word. Every claim in a comment must come from code that exists: real names, real defaults, real exceptions. Never invent behavior. If a default or a rule is not visible in the code, ask or leave it out.
2. List the public elements in scope (methods, properties, attributes, constants, exported functions) and the blocks of verbose raw manipulation.
3. Apply the decision rules below to each element and block. Skip the ones that need nothing.
4. Write doc comments with the structure in [Doc comments](#doc-comments) and the sentence rules in `references/ste100.md`.
5. Write inline comments for the raw blocks with [Inline comments](#inline-comments).
6. Recheck: every sentence within the limits, every comment matches the code as it is now, no comment restates the code.

## When to comment

Comment:
- **Every public method, property and attribute.** A reader must know what it does without reading the body. Document the contract, not the implementation.
- **Non-obvious constraints.** Ordering rules, thread or request-lifetime limits, cache invalidation, workarounds for a named bug. Name the reason in one sentence.
- **Verbose raw data manipulation.** Index arithmetic, byte or bit offsets, manual array or vector reshaping, string slicing, regex patterns. Explain the input shape, the transformation and the output shape, see [Inline comments](#inline-comments).

Do not comment:
- What the code plainly says: `$count++; // increment the count`.
- Private or trivial members whose name and signature already explain them, unless the project's own convention requires docs for every member.
- Anything the signature, types or a named constant already state. Repeating the type in a comment adds a second place to go stale.
- Code history, authorship, ticket chatter or "used to" notes. Put those in version control.
- Commented-out code. Delete it.
- `TODO` or `FIXME` without the reason and the condition for removing it.

When the code is hard to explain in a comment, the code is the problem. Consider a rename or a helper before writing a paragraph.

## Doc comments

Use the language's own doc-comment form (PHPDoc, JSDoc, rustdoc, docstrings, and so on). Follow the form the project already uses. A doc comment has, in order:

1. **One summary sentence.** Third-person present, active voice: "Returns the cached value for the key." Do not start with "This method".
2. **Behavior the signature does not show.** Conditions, side effects, what happens on a miss or on empty input. One or two sentences, each on one fact.
3. **Parameters, only when their meaning is not in the name.** One line each, with the constraint: "The maximum age in seconds. Must be greater than zero."
4. **Return value.** State the cases: "Returns the user when found. Returns `null` otherwise."
5. **Exceptions or errors.** "Throws `InvalidArgumentException` when the key is empty."

Properties and attributes get one summary sentence and, when the value has a constraint or default in the code, one sentence for it: "The number of attempts before the lock. Defaults to `5`."

Every sentence follows [the ASD-STE100 rules](references/ste100.md). Keep each doc comment short. If a method needs more than about six sentences, the method is probably doing two jobs.

## Inline comments

Use inline comments only for blocks of verbose raw handling: loops over indexes, manual byte or bit work, string offsets, hand-built arrays or vectors, and regular expressions. Place one comment above the block, not on every line. It states:

- the **input** shape: what the raw data looks like, including length or width,
- the **transformation**, in one sentence per step,
- the **output** shape, and any invariant the code keeps.

For a regex, comment the pattern with what it matches and what each capture group returns, one group per line when there are several.

```php
// Input: a flat list of [key, value, key, value, ...] pairs with an even length.
// Output: an associative array. A key without a value maps to null.
// Step 1: split the list into chunks of two.
// Step 2: map each chunk to its key and value.
$pairs = array_chunk($flat, 2);
```

Inline comments follow the sentence rules too. Keep them to one to three sentences per block.

## Hard rules

These never bend:
- Every claim matches the code as written. If the code changes, the comment changes in the same edit.
- One fact per sentence, one topic per comment block.
- No comment repeats a name, a type or a value the code already shows.
- No emoji, no decorative separators, no banners.
- Use the project's existing comment language and style for everything else.

## Scope

This skill decides what gets commented and how the comment is shaped. It does not decide the prose of project documentation: READMEs, guides and changelogs belong to other skills or to the project's own conventions.
