# Gemini Audio Sourcing Prompt — Task H-13

> **Purpose:** Source royalty-free audio files for psyOS app
> **Created:** 13 January 2026
> **Target:** Gemini with code execution / web browsing capability

---

## PROMPT (Copy Below This Line)

---

You are an Audio Asset Researcher for a mobile app called "The Pact" (psyOS). Your task is to find and provide download links for 6 royalty-free sound effects.

## Context

The app has ceremonial UI moments that require audio feedback:
- **Ratification Ritual:** User signs a "treaty" with their identity facets (like a wax seal ceremony)
- **Habit Completion:** Rewarding but not gamified feedback
- **Recovery State:** Calming transition after missed habits
- **Council Chamber:** Background ambience for AI dialogue sessions

## Current State

The app has 0-byte placeholder files:
```
assets/sounds/
├── sign.mp3      (0 bytes - placeholder)
├── complete.mp3  (0 bytes - placeholder)
├── recover.mp3   (0 bytes - placeholder)
```

## Required Sound Effects

### 1. `sign.mp3` — Ratification Seal Sound
| Attribute | Requirement |
|-----------|-------------|
| **Concept** | Wax seal stamp / notary stamp / treaty signing |
| **Tone** | Ceremonial, weighty, final, authoritative |
| **Duration** | 1-2 seconds |
| **Search Terms** | "wax seal stamp sound effect", "notary stamp sound", "official stamp sfx" |
| **Anti-Pattern** | NOT a click, NOT a beep, NOT digital |

### 2. `complete.mp3` — Habit Completion Chime
| Attribute | Requirement |
|-----------|-------------|
| **Concept** | Achievement unlock / gentle success chime |
| **Tone** | Rewarding, satisfying, NOT arcade/gamified |
| **Duration** | 1-3 seconds |
| **Search Terms** | "achievement sound effect gentle", "soft success chime", "completion tone" |
| **Anti-Pattern** | NOT 8-bit, NOT coins/bling, NOT aggressive fanfare |

### 3. `recover.mp3` — Recovery Transition Bell
| Attribute | Requirement |
|-----------|-------------|
| **Concept** | Singing bowl / meditation bell / gentle gong |
| **Tone** | Calming, restorative, forgiving |
| **Duration** | 2-4 seconds |
| **Search Terms** | "singing bowl single strike", "meditation bell", "tibetan bowl sound" |
| **Anti-Pattern** | NOT alarm, NOT urgent, NOT repetitive |

### 4. `clockwork.mp3` — Countdown Ticking (NEW)
| Attribute | Requirement |
|-----------|-------------|
| **Concept** | Pocket watch ticking / clockwork mechanism |
| **Tone** | Mechanical, anticipatory, ceremonial |
| **Duration** | 3-5 seconds (loopable preferred) |
| **Search Terms** | "pocket watch ticking", "clockwork mechanism sound", "antique clock tick" |
| **Anti-Pattern** | NOT digital timer, NOT alarm clock |

### 5. `thud.mp3` — Seal Impact Sound (NEW)
| Attribute | Requirement |
|-----------|-------------|
| **Concept** | Heavy stamp impact / gavel strike / seal press |
| **Tone** | Authoritative, conclusive, physical weight |
| **Duration** | <1 second |
| **Search Terms** | "heavy stamp thud", "gavel impact", "seal press sound" |
| **Anti-Pattern** | NOT hollow, NOT metallic clang |

### 6. `ambience.mp3` — Council Chamber Background (NEW)
| Attribute | Requirement |
|-----------|-------------|
| **Concept** | Dark ambient / contemplative space / council room |
| **Tone** | Low, atmospheric, non-intrusive |
| **Duration** | 30-60 seconds (loopable) |
| **Search Terms** | "dark ambient loop", "council chamber ambience", "contemplative background" |
| **Anti-Pattern** | NOT music with melody, NOT nature sounds, NOT distracting |

## Sourcing Requirements

### Trusted Sources (Prioritize)
1. **Freesound.org** — CC0 / CC-BY licensed sounds
2. **Pixabay.com/sound-effects** — Royalty-free, no attribution required
3. **Zapsplat.com** — Free with attribution
4. **Mixkit.co** — Free for commercial use
5. **YouTube Audio Library** — Royalty-free (via YouTube Studio)

### License Requirements
- **MUST be:** CC0, CC-BY, or "Royalty-free for commercial use"
- **MUST NOT be:** NC (Non-Commercial), ND (No Derivatives), or paid-only
- **Attribution:** Note if attribution is required

### Technical Requirements
| Spec | Requirement |
|------|-------------|
| Format | MP3 preferred, WAV acceptable |
| Bitrate | 128-192 kbps (not higher — mobile app) |
| File Size | <500KB per effect (<2MB for ambience) |
| Sample Rate | 44.1kHz or 48kHz |

## Output Format

For EACH of the 6 sounds, provide:

```markdown
### [Filename]

**Source:** [Website name]
**URL:** [Direct link to sound]
**License:** [CC0 / CC-BY / Royalty-free]
**Attribution Required:** [Yes/No — if yes, provide text]
**Duration:** [X seconds]
**File Size:** [X KB]
**Why Selected:** [1 sentence on why this matches requirements]
**Download Command:** [If applicable, e.g., curl or wget command]
```

## Verification Checklist

Before finalizing each selection:
- [ ] License explicitly allows commercial use
- [ ] Sound matches the "Tone" requirement
- [ ] Duration is within specified range
- [ ] File size is reasonable for mobile
- [ ] NOT an anti-pattern sound type

## Example Good Output

```markdown
### sign.mp3

**Source:** Freesound.org
**URL:** https://freesound.org/people/example/sounds/123456/
**License:** CC0 (Public Domain)
**Attribution Required:** No
**Duration:** 1.4 seconds
**File Size:** 45 KB
**Why Selected:** Heavy wax seal stamp with satisfying thud, ceremonial quality
**Download Command:**
curl -o sign.mp3 "https://freesound.org/data/previews/123/123456_1234567-lq.mp3"
```

## Fallback Strategy

If you cannot find a perfect match:
1. Note the closest alternative found
2. Explain what's missing vs requirements
3. Suggest search refinement terms

---

## END OF PROMPT

---

## Usage Notes for Human

1. **Copy everything between the delimiter lines** into Gemini
2. **Enable web browsing** if available in your Gemini interface
3. **Review licenses carefully** before downloading
4. **Test sounds** before replacing placeholders
5. **Update AI_HANDOVER.md** when complete

## After Sourcing

Replace placeholder files:
```bash
# From project root
cp ~/Downloads/sign.mp3 assets/sounds/sign.mp3
cp ~/Downloads/complete.mp3 assets/sounds/complete.mp3
cp ~/Downloads/recover.mp3 assets/sounds/recover.mp3
cp ~/Downloads/clockwork.mp3 assets/sounds/clockwork.mp3
cp ~/Downloads/thud.mp3 assets/sounds/thud.mp3
cp ~/Downloads/ambience.mp3 assets/sounds/ambience.mp3

# Verify non-zero
ls -la assets/sounds/
```
