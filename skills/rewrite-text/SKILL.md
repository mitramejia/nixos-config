---
name: "rewrite-text"
description: "Rewrites and edits nonfiction prose of any length, from a single sentence or paragraph to a full article, for clarity, brevity and a human voice, applying principles from William Zinsser's On Writing Well. Use when the user asks to tighten, simplify, de-jargon, polish, edit or improve text."
---

# Rewriting Text

Goal: make the text clear to a busy reader who knows nothing of the subject, while keeping the author's meaning and voice. Clear writing comes from clear thinking, so find the point before changing words.

## Scale the process to the length

| Input | Process | Output |
|---|---|---|
| One sentence or phrase | Apply the sentence-level principles. No checklist. | The rewrite, plus at most one line on what changed. Offer 2 or 3 variants only if the sentence has a real choice (tone, emphasis). |
| Paragraph or short message (up to about 300 words) | Steps 1, 3, 4 and 5 below, done quickly in your head. | The rewrite, then a 1 to 3 line change note. |
| Multi-paragraph piece or full draft | The full checklist. | The rewrite, then a 2 to 5 line change note with any flags. |

Don't apply whole-piece rules to a fragment. A paragraph taken from a longer work has no lead or ending to fix, and its point may live elsewhere; edit it for clarity and economy, and keep its role in the surrounding text. If the user pastes a fragment, never invent context. If the fragment can't be made clear without knowing what comes before or after, say what you assumed.

## Workflow

```
Rewrite progress:
- [ ] 1. State the point and the reader in one sentence each
- [ ] 2. Fix the unities: person, tense, tone (whole drafts)
- [ ] 3. Mark clutter: words, phrases, sentences doing no work
- [ ] 4. Rewrite with the principles below
- [ ] 5. Verify: facts unchanged, no new claims, read for rhythm
- [ ] 6. Cut a second time
- [ ] 7. Deliver the rewrite plus a short change note
```

1. **Point and reader.** If the point is unclear, say so in the change note and name the likeliest readings. Ask the user only if the answer would change the rewrite.
2. **Unities.** Keep the original person (I/you/third), tense and tone unless they shift mid-piece; then pick the dominant one and fix the rest.
5. **Verify.** Compare against the original: every fact, number, name, quote and claim must survive. Don't add opinions, details or flourishes the author didn't write.
6. **Second cut.** One pass almost never finds all the clutter.

## Principles

Sentence and word level (apply to any length):

**Cut clutter.** Every word must do new work. Delete words that repeat their neighbor ("smile happily," "tall skyscraper"), announcements ("it should be pointed out that"), qualifiers (a bit, sort of, rather, quite, very, arguably), needless prepositions on verbs ("free up"), and sentences that restate the previous one. Wordy drafts typically lose 20 to 50 percent; a tight sentence may lose nothing.

**Short words, plain phrases.** *utilize* → use, *assistance* → help, *numerous* → many, *due to the fact that* → because, *at this point in time* → now, *for the purpose of* → for. Replace jargon and fad words (prioritize, interface, impact as a verb, ongoing, paradigm) with the ordinary word.

**People doing things.** Prefer active verbs and a named actor. Turn abstract-noun sentences ("the reaction is incredulous laughter") into people acting ("most people laugh in disbelief"). Unstack noun chains and turn nominalizations back into verbs. Use passive only when the actor is unknown or irrelevant.

**Fewer modifiers.** Keep an adjective or adverb only if the noun or verb doesn't already carry its meaning. Choose the exact verb instead. Don't hedge a claim the author clearly means; keep real uncertainty, stated once.

**Sound like a person.** Use contractions where natural, first person where the genre allows, and nothing the author wouldn't say aloud. Replace clichés and journalese with a plain, specific statement. Keep the author's humor, quirks and opinions; remove only what is generic.

**Sentence shape.** Split tangled sentences; a sentence doing two jobs should be two. Put the important word at the end. Vary lengths; a short sentence after a long one lands hard. Open direction changes with *but, yet, still, instead*. Use exclamation points almost never and semicolons sparingly.

Paragraph level (use for paragraphs and longer):

- Supply any logical link the author left in their head, and make sure each sentence follows from the last.
- End a paragraph with a sentence that pulls the reader forward.
- Keep paragraphs short but not fragmentary.
- When explaining, assume the reader knows nothing; give steps in the order the reader needs them.

Whole-piece level (full drafts only):

- **One point.** The piece should leave the reader with one idea. Cut tangents that don't serve it.
- **Lead.** The first sentence must earn the second: open with a concrete detail, surprise or the reader's stake. Cut throat-clearing paragraphs and stale openers (visitor from Mars, "what do X and Y have in common?").
- **Ending.** Stop when the point is made. Delete recap closers ("In sum..."). A last line with a touch of surprise is best.

## Calibrate to genre

| Genre | Approach |
|---|---|
| Business, technical, academic | Cut hard; plain words, people as subjects, point first. Keep needed technical terms. |
| Email, chat message | Lead with the ask or answer; keep it short and warm. |
| Essay, memoir, op-ed, personal | Protect voice; cut lightly; keep humor and concrete detail. |
| News, reports | Stay neutral and keep attributions; don't add "I." |
| Fiction, poetry, dialogue, legal or contract text | Edit lightly and say so; don't change wording where form or precision is the point. |

If the text is already clear and lean, say so and change little.

## Guardrails

- Never change meaning, stance, facts, figures, names or quotations.
- Don't over-compress into telegraphic text; brevity serves the reader, it isn't the goal.
- If the problem is thinking (missing logic, contradictions, no point), flag it instead of smoothing it over.
- Honor any length or format the user specifies.
- Keep the original's format (headings, lists, links) and don't add a heading, intro or sign-off the author didn't write.

## Output

1. The rewritten text, ready to paste.
2. A change note sized to the input (see the table above): what changed and why, plus any flags (unclear point, claim the author should check).

If the user asks only for feedback, list the problems with the offending phrases and a fix for each, then offer the rewrite.

## Examples

**Sentence**
Input: At this point in time we are experiencing a bit of a delay due to the fact that the shipment was held up.
Output: The shipment is late because it was held up.

**Paragraph**
Input: It is important to note that the implementation of the new scheduling system has been undertaken in an effort to facilitate improved coordination among team members. Numerous individuals have indicated that they were quite satisfied with the changes.
Output: We introduced the new scheduling system to help the team coordinate. Many people say they like it.

**Voice preserved**
Input: Honestly I was sort of dreading the trip, rather unsure whether Dad, who is quite stubborn, would even come.
Output: I dreaded the trip. Would Dad, stubborn as ever, even come?