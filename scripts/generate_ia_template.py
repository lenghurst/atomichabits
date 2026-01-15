#!/usr/bin/env python3
"""
Generate IA template from existing task in Master Tracker.
Extracts context from reconciliation docs and creates structured markdown.

Usage: python scripts/generate_ia_template.py <task-id>
Example: python scripts/generate_ia_template.py A-06
"""
import sys
import re
from pathlib import Path


def extract_task_from_tracker(task_id):
    """Parse RESEARCH_QUESTIONS.md Master Tracker for task details."""
    tracker_path = Path("docs/CORE/RESEARCH_QUESTIONS.md")
    if not tracker_path.exists():
        print(f"❌ Master Tracker not found at {tracker_path}")
        sys.exit(1)

    tracker = tracker_path.read_text()

    # Match task line in Master Tracker table
    pattern = rf"\| {task_id} \| (.*?) \| (CRITICAL|HIGH|MEDIUM|LOW) \| (.*?) \| (.*?) \| (.*?) \| (.*?) \|"
    match = re.search(pattern, tracker)

    if not match:
        print(f"❌ Task {task_id} not found in Master Tracker")
        sys.exit(1)

    return {
        "id": task_id,
        "description": match.group(1).strip(),
        "priority": match.group(2).strip(),
        "status": match.group(3).strip(),
        "source": match.group(4).strip(),
        "component": match.group(5).strip(),
        "ai_model": match.group(6).strip(),
    }


def extract_context_from_reconciliation(source_rqs):
    """Find relevant reconciliation docs and extract context."""
    # Parse source RQs (e.g., "RQ-048a/b, RQ-014")
    rq_ids = re.findall(r"RQ-\d+[a-z]?", source_rqs)

    if not rq_ids:
        return "[TODO: Add context from research - no source RQs found]"

    # Search for reconciliation docs mentioning these RQs
    reconciliation_docs = list(Path("docs/CORE").glob("RECONCILIATION_*.md"))
    context = []

    for doc in reconciliation_docs:
        try:
            content = doc.read_text()
            if any(rq in content for rq in rq_ids):
                # Extract relevant sections (heuristic: first 500 chars after RQ mention)
                for rq in rq_ids:
                    idx = content.find(rq)
                    if idx != -1:
                        snippet = content[idx:idx+500].replace("\n", " ")
                        context.append(f"From {doc.name}: {snippet}...")
                        break  # Only one snippet per doc
        except Exception as e:
            continue

    return "\n\n".join(context[:3]) if context else "[TODO: Add context from research]"


def generate_ia_markdown(task):
    """Create structured IA markdown from task metadata."""
    context = extract_context_from_reconciliation(task['source'])

    # Clean description for filename
    filename_desc = task['description'].lower().replace(' ', '_').replace('`', '').replace('/', '_')

    template = f"""# Implementation Action {task['id']}: {task['description']}

**Priority:** {task['priority']}
**Status:** {task['status']}
**Source:** {task['source']}
**Component:** {task['component']}
**AI Model:** {task['ai_model']}
**Reconciliation Doc:** [TODO: Link to specific reconciliation doc section]

---

## Context

**Why this task exists:**

{context}

**Business value:** [TODO: Explain user/system impact]

---

## Acceptance Criteria (Given-When-Then)

**AC-1: [TODO: Primary Success Criterion]**
- **Given:** [TODO: Initial state/preconditions]
- **When:** [TODO: Action performed]
- **Then:** [TODO: Expected observable outcome]

**AC-2: [TODO: Additional Criterion]**
- **Given:** [TODO: Setup state]
- **When:** [TODO: Action]
- **Then:** [TODO: Result]

**AC-3: [TODO: Edge Case/Error Handling]**
- **Given:** [TODO: Error condition]
- **When:** [TODO: Action]
- **Then:** [TODO: Expected error behavior]

---

## Anti-Patterns (What NOT to Do)

❌ **WRONG:** [TODO: Common mistake description]
```[language]
// TODO: Bad code example showing anti-pattern
```

✅ **CORRECT:** [TODO: Proper approach]
```[language]
// TODO: Good code example showing correct pattern
```

❌ **WRONG:** [TODO: Another common mistake]
```[language]
// TODO: Another bad code example
```

✅ **CORRECT:** [TODO: Proper approach]
```[language]
// TODO: Another good code example
```

---

## Testing Requirements

### Unit Tests
- [ ] [TODO: Test case 1 - happy path]
- [ ] [TODO: Test case 2 - edge case]
- [ ] [TODO: Test case 3 - error handling]

### Integration Tests
- [ ] [TODO: Integration test 1 - component interaction]
- [ ] [TODO: Integration test 2 - dependency validation]

### End-to-End Tests
- [ ] [TODO: E2E scenario 1 - complete user flow]
- [ ] [TODO: E2E scenario 2 - error recovery flow]

---

## Implementation Checklist

### Phase 1: Prerequisites
- [ ] Read reconciliation doc: [TODO: Link to specific doc]
- [ ] Verify dependencies complete: [TODO: List blocking tasks]
- [ ] Review related CDs/PDs: [TODO: List relevant decisions]

### Phase 2: Implementation
- [ ] [TODO: Step 1 - setup/preparation]
- [ ] [TODO: Step 2 - core implementation]
- [ ] [TODO: Step 3 - validation]

### Phase 3: Testing
- [ ] Run unit tests: `[TODO: test command]`
- [ ] Run integration tests: `[TODO: test command]`
- [ ] Smoke test: [TODO: Manual verification steps]

### Phase 4: Verification
- [ ] Code review approved
- [ ] All tests passing
- [ ] Documentation updated (if needed)
- [ ] Update task status in IMPLEMENTATION_ACTIONS.md: {task['status']} → COMPLETE

---

## Definition of Done

1. ✅ All acceptance criteria pass
2. ✅ All tests green (unit, integration, e2e)
3. ✅ Code review approved (anti-patterns checked)
4. ✅ Documentation updated (if applicable)
5. ✅ Task status updated in IMPLEMENTATION_ACTIONS.md

---

## Metadata

**Estimated Effort:** [TODO: Time estimate based on complexity]
**Blockers:** [TODO: List dependencies that must complete first]
**Blocks:** [TODO: List tasks that depend on this one]

**Related Files:**
- [TODO: List files that will be created/modified]

**Related Decisions:**
- [TODO: List CDs/PDs that informed this task]
"""

    return template, filename_desc


def main():
    if len(sys.argv) != 2:
        print("Usage: python scripts/generate_ia_template.py <task-id>")
        print("Example: python scripts/generate_ia_template.py A-06")
        sys.exit(1)

    task_id = sys.argv[1].upper()

    # Extract task from Master Tracker
    task = extract_task_from_tracker(task_id)

    # Generate markdown content
    ia_content, filename_desc = generate_ia_markdown(task)

    # Write to file
    output_dir = Path("docs/CORE/implementation_actions")
    output_dir.mkdir(parents=True, exist_ok=True)

    output_file = output_dir / f"{task_id}_{filename_desc}.md"
    output_file.write_text(ia_content)

    print(f"✅ Created: {output_file}")
    print(f"📝 Next steps:")
    print(f"   1. Fill in [TODO] sections with details from reconciliation docs")
    print(f"   2. Add code examples for anti-patterns (❌ WRONG vs ✅ CORRECT)")
    print(f"   3. Define specific test cases based on acceptance criteria")
    print(f"   4. Review against DEEP_THINK_PROMPT_GUIDANCE.md quality standards")


if __name__ == "__main__":
    main()
