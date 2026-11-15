# Writing for readers and briefing agents

Facts kept from the plain-language, style-guide, cognitive-load and vendor sources used for the plan schema, so nobody searches the web for them again. Source IDs are in `sources.md`; each section says how deeply the source was read. Paraphrased, not quoted. Applied in `plan-format.md`.

## Contents
- Plain language (A25)
- Style guide (A26)
- ISO 24495-1 and federal guidelines (A27, A28)
- Cognitive load (B7)
- Briefing an agent (A12, A13)
- Chisle prose rules (D3)

## Plain language (A25)

Read in full: principles, writing, lists, tables. Read the first 2,600 characters only: clear-short, style. Not read: the design and test sections beyond lists and tables.

| Fact | Page |
| --- | --- |
| First rule: write for your audience, with the words they know. "Dumbing down" is a myth; match the reader's knowledge, expertise and interest. | principles |
| Open with a topic sentence, organize so readers know what to expect, summarize long documents up front, use tables and lists where they fit. | principles |
| Active voice shows who does what and removes doubt about responsibility. Passive sentences have a form of "to be" plus a past participle. Passive is acceptable when there is no actor. Do not confuse passive with past tense. | writing |
| Present tense is the simplest and strongest; conditional and future tenses make the reader work. Use other tenses only when accuracy needs them. | writing |
| Hidden verbs (nominalizations such as "conduct an analysis of") weaken and lengthen text. Use the verb ("analyze"). | writing |
| One idea per sentence. Long sentences with clauses and exceptions lose the point. Turn an "if" clause into its own sentence ("Suppose... In this case...") to keep the relation. | clear-short |
| Short paragraphs; the source recommends at most 150 words (the rest of that sentence was cut off in the fetch). | clear-short |
| Avoid noun strings: past three nouns in a row the string "becomes unbearable". Cut non-essential words or add prepositions and articles. | style |
| Watch prepositions; short forms exist ("can" for "is able to", "to" for "in order to"). | style |
| Abbreviations make the reader look back. Prefer a simple nickname (the committee, the Act); a nickname for the main topic needs no definition at first use unless there are many. | style |
| Lists show priority and order, help scanning, and suit items, conditions and exceptions. Number steps in a process. Always give a lead-in sentence, keep items parallel, do not overuse lists. | lists |
| Tables show relations hidden in dense text; most readers need only the cases that apply to them. | tables |

## Style guide (A26)

Read: highlights (full), procedures (first part only). The conditional-clauses page returned 404.

| Fact | Page |
| --- | --- |
| Second person, active voice, conversational but not frivolous, sentence-case headings. | highlights |
| Put conditions before instructions, not after. | highlights |
| Numbered lists for sequences, bulleted for other lists, description lists for pairs. | highlights |
| Introduce a procedure with a sentence that adds context beyond the heading; do not leave the intro as a partial sentence completed by the steps. | procedures |
| Steps are numbered; sub-steps use letters, then roman numerals. A single-step procedure may be a plain sentence. Mark optional steps "Optional:". | procedures |

## ISO 24495-1 and federal guidelines (A27, A28)

Search-result summaries only. The standard's text is paywalled and was not read.

- ISO 24495-1:2023 has four principles: relevant, findable, understandable, usable. A document is usable when its content is relevant, findable and understandable. They interact; only evaluation with readers shows whether a text works. Success is judged by reader use, not by readability formulas.
- Findable covers structure, headings that let readers predict what follows, and keeping supplementary information apart. Understandable covers familiar words, clear short sentences and paragraphs, cohesion and a respectful tone.
- The Federal Plain Language Guidelines (2011) list "write short sentences" and "keep subject, verb and object close together", "use active voice", and consistent terminology: use the same term for the same thing. A National Archives summary says to explain technical terms on first use. A state guide suggests under 20 words per sentence and under six sentences per paragraph; that is the state's advice, not a federal rule.

## Cognitive load (B7)

Secondary teaching summaries of Sweller's work; the primary papers were not retrieved.

- Worked example effect: learners given worked solutions learn more than learners left to solve the same problems; the benefit fades as expertise grows.
- Split-attention effect: when the reader must mentally combine separate sources (a diagram and its text), extraneous load rises. The remedy is to integrate the sources.
- Redundancy effect: material that only restates what another source already gives adds load and should be removed. It is not the same as split attention: information that must be combined should not be separated, and duplicated information should be cut.
- Caveat from the summaries: the theory is sometimes misread as saying all load is bad; load that builds understanding is useful.

## Briefing an agent (A12, A13)

Part-read from the live docs on 2026-11-05, for the passages below.

| Fact | Source |
| --- | --- |
| A specific prompt names the file, the symptom and what "fixed" looks like, and states a preference between two reasonable approaches. Pointing to an existing pattern file beats describing it. | A12 |
| For an unclear task, have the model interview the user until a written spec exists, then build from the spec in a fresh session; the spec is also the reviewer's reference. | A12 |
| Give a check to run (tests, build exit code, linter, diff against a fixture, screenshot) and ask for evidence: the command and its output. "All tests pass" alone says little. A reviewer that did not write the code is not swayed by its reasoning. | A12 |
| Before an unattended run, answer five questions: what done looks like, how it checks itself, what it may touch, what stops it, where the result goes and who signs off. | A12 |
| Claude reads requests conservatively; ask explicitly for more than the minimum. Newer models over-build, so state scope limits (no unrequested features, abstractions or defensive code). | A12, A13 |
| Key test: show the instructions to a colleague with no context; if they would be confused, the model will be. Provide steps as numbered lists when order or completeness matters. | A13 |
| Giving the reason behind an instruction lets the model generalize from it. | A13 |
| Long inputs (20k+ tokens): put the documents at the top and the query and instructions at the end; end-placed queries improved quality by up to 30 percent in the vendor's tests. | A13 |
| Ask the model to self-check against stated criteria before finishing. One recent model verifies unprompted, and carried-over verification instructions can cause over-verification. | A13 |
| Do not let tests define the solution: ask for a general solution, and to report incorrect or infeasible tests instead of working around them. Do not edit or remove tests. | A13 |
| Keep state in structured formats (JSON for statuses and test results), free text for progress notes, and git for history; a fresh context can rediscover state from the file system. | A13 |

## Chisle prose rules (D3)

Local files, read in full (plugin v3.8.1).

- Prose: drop filler, pleasantries and hedging; fragments allowed; technical terms, code and errors exact; causality as arrows. "Terse is not incomplete": keep every decisive fact.
- Structure costs tokens: answer at the question's level, with no headings, bullets, tables or recaps that were not asked for. This governs chat replies, not documents with a fixed schema.
- Auto-Clarity: write in full for security warnings, irreversible actions, order-sensitive steps, anything compression makes ambiguous, or a repeated question.
- The audit flags comments that restate code, padded docstrings, multi-paragraph explanations a sentence could carry, decorative tables and headings, and dead prose; it does not flag validation at trust boundaries, data-loss handling, security or accessibility, or comments that explain why.
