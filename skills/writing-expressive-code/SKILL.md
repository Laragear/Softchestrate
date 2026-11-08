---
name: writing-expressive-code
description: "Names and structures class, module and API members in any language with a fixed verb vocabulary (make vs create, is and isNot, put vs add, parse vs from, save vs push, flagAs vs markAs, with and without, when and unless, run vs handle, fresh vs refresh), full doc comments, testable design, file organization and method size. Reads the file, its siblings and the project rules first; they outrank this guide. Use when writing, naming, reviewing or refactoring classes, methods, properties, exceptions, constants, files or namespaces, designing class APIs, builders or DTOs, or when the user mentions code style, naming conventions, clean code or readability, even for one method."
license: MIT
---

# Writing Expressive Code

Goal: low cognitive effort to read and write. Where a rule allows two readings, take the one the next reader, human or agent, understands faster.

This skill owns naming, doc comments and method size. Other skills and agents defer to it for those three.

Terms: **host** = language plus framework conventions (the framework wins on conflict). **sibling** = file in the same directory, namespace or package. **family** = code related by role or type (same parent, interface, trait, or name suffix like `*Repository`). **project rules** = written repository conventions: style guides, contributor docs, agent instruction files, linter and formatter config. **throw** = signal failure the host's way (exception, `Err`, error return).

## Sources and precedence

Highest wins; this guide fills the gaps. When sources at one level disagree, the next one down decides.

1. The user's prompt.
2. The file being edited.
3. Its siblings and family.
4. The project rules.
5. This guide.

Per task:

1. **Survey.** Open the edited file, its nearest siblings and family, and the project rules (repository root, contributor docs). Read them in parallel yourself, no subagents. Stop once two files agree on the convention you need. Skip only when the task writes no code.
2. **Find helpers first.** Before writing a helper, utility or new verb, search for it by name and by synonym in project and framework helper locations (Helpers, Support, Tools, Composables, Utils or the host's equivalent, often deep in a namespace; framework source is in the dependencies directory). Use the first match.
3. **Decide** each naming or style choice from the highest source that covers it.
4. **Write.** Use the dictionary's semantics for a verb and the form existing code uses for it. Change only what the task asks; leave other lines in their style. A rename updates the member's test and mock call sites in the same change; assertions stay.
5. **Trace.** Close with one line per non-trivial decision (a dictionary name, a deviation, or a convention copied): `decision ← source`. A source is a guide section (`guide: State, flagAsNot`) or a location in a file you opened (`path/File.ext:41`, sibling, project rules). With no source: `no source: chose X`. Cite only conventions you saw in a file you opened.

When existing code or the host already owns a verb with different semantics (Eloquent `push()` saves locally, JavaScript `Array.push` appends, Django `update_or_create()` upserts), call and extend it as its owner intends. Use the dictionary's stricter meaning only for verbs nothing owns, and state any divergence in the trace.

<example>
Input: in `Server.ts`, "skip the reboot when the server is disconnected"; the file already has `isDisconnected()` at line 41.
Output: `if (this.isDisconnected()) return;` and no new method.
Trace: `isDisconnected ← Server.ts:41; guide: Booleans prefers isNotConnected(), existing file wins`.
</example>

## Standing constraints

Testable and mockable beats every other rule here.
- Collaborators and effects (clock, filesystem, network, database, randomness) arrive from outside through a constructor or parameter, typed as an interface, trait, protocol or function type.
- `save`, `push`, `execute`, `run` and `refresh` are the seams a test fakes. `make()` and `is...()` stay free of I/O so tests build and assert without setup.
- If a rule would hide a seam a test double needs (sealed or private member, hidden dependency), the seam wins; trace it.
- No reflection or runtime introspection (`method_exists`, `getattr`, member names built from strings) to decide behavior. It signals a class with several responsibilities and defeats mocking: branch through interfaces, polymorphism or a dispatch table, and split the class. Declarative metadata the framework reads (attributes, annotations, decorators) is fine; call the framework's public API, not its internals.

## Verb dictionary

Semantics are fixed, form is flexible: render each verb the way existing code does (`is_not_connected` in Python). With no example in any file, read `references/language-shapes.md`.

Receivers: entities expose `is...`, `get...`, `set...` and mutate in place. Builders and request objects expose `with...` and `include...` and return the configured object or a copy, following the language's immutability idiom. Jobs expose `run()` and keep `handle()` steps internal.

Flagging, marking and touching accept an optional trailing flag that defers persistence so callers batch changes into one write. Spelling: a named parameter (`save: false`, `persist=False`); a trailing boolean where there are no named parameters; an options object only where siblings use one.

### Construction and persistence

| Method | Use it to | Contract |
| --- | --- | --- |
| `make()` | Build in memory | Never persists or transforms; may apply defaults. Plain construction is fine without defaults |
| `create()` | Build and persist | A record exists in the database or file system after the call |
| `createOrUpdate()` | Update if present, else create | Use the host's own name when it ships one (`updateOrCreate()`, `update_or_create()`, `upsert()`), no alias |
| `update()` | Persist changes to an already-persisted object | Never creates; throws (e.g. `UpdatingNonExistingResource`) if never persisted. Upserts use `createOrUpdate()` |
| `parse()` | Build from any value | Best effort; throws when it cannot |
| `from{Scalar}()` | Build from one typed value | `fromJson()`, `fromArray()`, `fromInt()`; type errors come from the parameter type |

### Booleans and checks

| Method | Use it to | Contract |
| --- | --- | --- |
| `is(other)` | Same record? | Compares ids, labels or names, not every property; accepts an object or its id |
| `is{State}()` | Yes/no on own state | `isPublished()`; no arguments; prefers a stored field or timestamp over recomputing |
| `isNot...()` | Negate `is...()` | The explicit pair `isNotConnected()`; a synonym like `isDisconnected()` hides the pairing |
| `isValid()` / `isNotValid()` | Check validity, keep the flow | Returns a boolean |
| `validate()` | Check validity, stop the flow | Throws when invalid. `assert()` is for test environments only |
| `can()` / `cannot()` | Authorize the current user | "Can this user update the article?" |
| `should()` / `shouldNot()` | Decide from the object's own state | "Should this article reach the front page?" Never about the user |

### Collections and data

| Method | Use it to | Contract |
| --- | --- | --- |
| `get...()` | Read stored data | Only the key as argument, no side effects, typed return. Follow the host's accessor idiom (property in C#, Kotlin, Python; plain noun in Go and Rust) |
| `put(key, value)` | Store at a key, replacing | |
| `add(key, value)` | Store at a key, keeping any existing | |
| `set...()` | Replace the object's whole data | `set()` takes no key; `setRole(role)` when the value must be a particular type |
| `with()` / `without()` | Add or remove data, side-effect free | Builders: configure fluently (`withBasicAuth()`). Request and query objects: ask for related data back (`withMetadata('created_at')`); sending uses `include...()` |
| `toggle()` | Flip a boolean | Returns the new value; only when history does not matter |

### State and timestamps

| Method | Use it to | Contract |
| --- | --- | --- |
| `touch(property)` | Set a timestamp | `touch('updated_at')`; for access and audit trails; accepts the deferral flag |
| `flagAs...()` | Record a binary state | Idempotent. Name the positive state (`flagAsExtensive()`); reverse with `flagAsNot...()` |
| `markAs...()` | Record a state with evidence | Stores when, who and why: `markAsRemoved(remover, reason)`. Not idempotent. Reverse with `markAsNot...()`, which records its own when, who and why |

Every negation inserts `Not` into the positive name and keeps the prefix (`isNot`, `shouldNot`, `flagAsNot`, `markAsNot`): one rule predicts them all, pairs sort together, and `markAsNot...` appends evidence where an `un` prefix suggests erasing it.

### Flow control and fallbacks

| Method | Use it to | Contract |
| --- | --- | --- |
| `...or()` suffix | Offer a fallback or failure path | `fetchOr(fallback)` returns a default; `fetchOrThrow('message')` throws with context. Replaces if/else chains |
| `when()` / `unless()` | Execute conditionally | `if...` and `ifNot...` are language constructs, not method names |

### Processes and external realms

| Method | Use it to | Contract |
| --- | --- | --- |
| `run()` | Start the object's own process | User-facing; throws on failure; no arguments unless strictly needed |
| `handle()` | Perform one internal step | Invoked by other classes with arguments outside the developer's control; not user-facing |
| `execute()` | Run shell commands or external processes | |
| `fresh()` | New instance mirroring the source | For comparing against the source of truth |
| `refresh()` | Restore internal state in place | Re-fetches from the external source |
| `retrieve(fields)` | Refresh part of the state | For huge resources; failing fetches take the or-suffix |
| `save()` | Persist to the local realm | Database, file, cache |
| `push()` | Persist to an external realm | REST API, network, FTP; your own API (host-owned `push()` follows precedence above) |
| `include...()` | Set values sent with a request | `includeHeader('X-ENV', 'Testing')`; the retrieval counterpart is `with...()` |

### Coining new verbs

If the table lacks a verb and the helper search found none, coin one with the same discipline: one verb, one meaning, an explicit negation pair, an explicit fallback pair, the same coinage across the project (`remember()`, `retry()`, `paginate()`).

## Builders replace long parameter lists

In code you write or change, when a call site passes `null` or placeholders, or the fourth parameter needs the signature to decipher, build a dedicated builder with fluent `with...()` methods and one final verb: `Transcode.video(video).quality("low").withGeolocation().to("/sample.mp4")`. Leave existing signatures alone unless the task asks.

## Naming, structure, bodies, documentation

Apply to code you write or change; leave untouched code as it is.

Naming
- Name classes after the domain concept (`Article`, `DatabaseBackup`); a builder may take its action's name (`Transcode`).
- Name exceptions after the broken rule (`UpdatingNonExistingResource`, not `DatabaseProblem`), using the host's suffix and word order.
- Name variables and properties for their content: `banned_users_yesterday`, not `users` or `items`.

Structure
- Every directory and namespace has one domain and every file traces to it; a single file may sit directly in its domain. Files sharing a sub-domain (`http_client.c`, `response_parser.c`) become their own sub-directory.
- One responsibility per file; a line that does not serve it belongs elsewhere.

Method bodies
- One responsibility per method. More than 10 executable lines, nested loops, more than 3 indentation levels or more than 3 intents is a cue to check for mixed responsibilities; extract when it does. Flat dispatch tables and data declarations stay as they are. A split must leave the caller reading as a short outline, not a trail of tiny helpers.
- Open a body that manipulates arrays, hashes, strings or binary data (raw math, regexes, serialization, bit operations) with a three-line comment: what happens, why this way, end result. Add no other inline comments; rename or split instead.

Documentation
- Every method you write gets a full doc comment: a multi-line block with a summary line, a blank line, the context a caller needs, then every parameter, return and failure entry the host's doc form provides. A summary-only comment is incomplete.
- The summary says what the method does in context, under 100 characters, never the name restated. Bad: "Get the users". Good: "Retrieve the users as instances from the filesystem".
- Parameter and return entries describe meaning, not type; state a type only where the signature cannot (generics, collection shapes). Document properties, constants and enum cases with why they exist or what they represent.
- Test cases, generated code and members that inherit docs through the language are exempt.
- Examples are in `references/language-shapes.md`.

## Optional polish

Apply when it fits the surrounding code and costs little; never as a reason to touch code outside the task.
- Make a class callable when it is one action and siblings do the same (`__invoke()`, `__call__`, `call`, a function value).
- For serialized work use the framework's pipeline or middleware; otherwise the language's own composition (pipe operator, iterator chaining) if siblings use it. Framework over language.
- Use the host's `when()` / `unless()` helper when it exists.

## Review

When reviewing a diff, compare it with siblings, then project rules, then this guide, and report `mismatch with sibling <file>`, `project rule <file>` or `guide: <section>`. When the surrounding code consistently follows another convention, add at most a note, not a defect.

## References

Read `references/language-shapes.md` when a verb needs a form no opened file shows, or for worked examples (negations, flags and marks, builders, full doc comments).
