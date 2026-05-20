# Cognitive Complexity (Sonar's metric)

> โหลดเมื่อต้องคำนวณ complexity ของ function/method

---

## ทำไมไม่ใช้ Cyclomatic Complexity?

Cyclomatic complexity นับ branch — แต่ไม่สะท้อน "ความอ่านยาก" จริง:
- `switch` 10 cases = cyclomatic 10 (อ่านง่าย เรียง flat)
- 4 nested `if` = cyclomatic 4 (อ่านยากกว่ามาก)

**Cognitive complexity แก้ปัญหานี้** โดยเพิ่มน้ำหนัก **nested** + **logical chain**

---

## กฎคำนวณ (3 rules)

### Rule 1: Increment (+1)

แต่ละโครงสร้างควบคุม flow:
- `if` / `else if` / `else` (else nesting แค่ +0)
- `switch` (ทั้งบล็อก +1, ไม่นับแต่ละ case)
- `for` / `while` / `do-while`
- `catch`
- `&&` / `||` chain (เพิ่ม +1 ต่อ operator ใหม่ใน chain)
- `?:` (ternary) → +1
- recursive call → +1

### Rule 2: Nesting Increment (+nesting_level)

ถ้าโครงสร้างใน Rule 1 ซ้อนกันอยู่ใน control flow อื่น:
- nested 1 ชั้น → +1 (Rule 1) + 1 (nesting) = +2
- nested 2 ชั้น → +1 + 2 = +3
- nested 3 ชั้น → +1 + 3 = +4

### Rule 3: ไม่ Nest (+0)

- `else if` ที่ flat (ไม่นับเป็น nested)
- function declaration ใหม่ (reset nesting ภายใน)

---

## ตัวอย่างคำนวณ

### Example 1: complexity = 4 (อ่านง่าย)

```typescript
function getDisplayName(user) {
  if (user.nickname) {       // +1 (rule 1)
    return user.nickname;
  }
  if (user.firstName) {      // +1 (rule 1, not nested = no +1)
    return user.firstName;
  }
  return 'Anonymous';
}
// total: 1 + 1 = 2
```

แก้ — มี chain:
```typescript
function isAdmin(user) {
  return user && user.role === 'admin' && !user.banned;
  //     ^^^^   +1   ^^^^^^^^^^^^^^^^^^   +1 (chain ใหม่)
}
// total: 2 (one && chain = 1, second different op = 1)
// จริง ๆ คือ &&-chain ต่อเนื่อง = +1 ครั้งเดียว
// total: 1
```

### Example 2: complexity = 10 (อ่านยาก)

```typescript
function processUser(user) {
  if (user) {                          // +1
    if (user.active) {                 // +2 (nested 1)
      if (user.role === 'admin') {     // +3 (nested 2)
        if (user.permissions) {        // +4 (nested 3)
          return doStuff();
        }
      }
    }
  }
}
// total: 1 + 2 + 3 + 4 = 10
```

### Example 3: ลดเหลือ 4 (Guard Clauses)

```typescript
function processUser(user) {
  if (!user) return;              // +1
  if (!user.active) return;       // +1 (not nested)
  if (user.role !== 'admin') return; // +1
  if (!user.permissions) return;  // +1
  return doStuff();
}
// total: 4
```

### Example 4: switch (flat)

```typescript
function statusText(status) {
  switch (status) {  // +1 (the switch block, not per case)
    case 'pending': return 'รอ';
    case 'active':  return 'ใช้งาน';
    case 'banned':  return 'ระงับ';
    default:        return 'ไม่ทราบ';
  }
}
// total: 1
```

### Example 5: ternary chain (อ่านยาก)

```typescript
function classify(x) {
  return x > 100 ? 'high'         // +1 (ternary)
       : x > 50  ? 'medium'       // +1 (another ternary)
       : x > 10  ? 'low'          // +1
       : 'tiny';
}
// total: 3
```

ดีกว่า:
```typescript
function classify(x) {
  if (x > 100) return 'high';   // +1
  if (x > 50) return 'medium';  // +1
  if (x > 10) return 'low';     // +1
  return 'tiny';
}
// total: 3 — เท่ากัน แต่อ่านง่ายกว่า (subjective)
```

---

## Threshold (Sonar default)

| Range | Severity | Action |
|-------|:--------:|--------|
| 0-15 | OK | — |
| 16-25 | MAJOR | refactor (extract method / guard clauses) |
| 26-40 | CRITICAL | refactor ทันที |
| > 40 | BLOCKER | split class, redesign |

---

## Calculator (pseudocode)

```typescript
function cognitiveComplexity(node: ASTNode, nestingLevel = 0): number {
  let complexity = 0;

  for (const child of node.children) {
    if (isControlFlow(child)) {
      // Rule 1 + Rule 2
      complexity += 1 + nestingLevel;
      complexity += cognitiveComplexity(child.body, nestingLevel + 1);
    } else if (isLogicalChainStart(child)) {
      // Rule 1 (chain เพิ่ม +1 ครั้งเดียว ต่อ chain)
      complexity += 1;
      complexity += cognitiveComplexity(child, nestingLevel);  // ไม่เพิ่ม nesting
    } else {
      complexity += cognitiveComplexity(child, nestingLevel);
    }
  }

  return complexity;
}
```

---

## Quick Manual Check (ไม่ต้องใช้ tool)

```
1. นั่งอ่านฟังก์ชัน
2. นับ control flow keyword: if/else/for/while/catch/switch/&&/||/?:
3. เพิ่ม nesting penalty:
   - if ใน if    → +1
   - if ใน if ใน if → +2
4. รวม — ถ้า > 15 → refactor
```

---

## Refactor Strategies (เพื่อลด complexity)

| Pattern | ลดได้ |
|---------|-------|
| **Guard Clauses** (early return) | -50% ของ nested if |
| **Extract Method** | reset nesting (helper function เริ่มจาก 0) |
| **Polymorphism / Strategy** | switch ใหญ่ → class hierarchy |
| **Table / Map lookup** | if-else chain → object/Map |
| **Simplify boolean** | de Morgan / รวม condition |

---

## Tools ที่ใช้คำนวณจริงได้

```bash
# ESLint (ใช้ได้แต่ไม่ใช่ cognitive — เป็น cyclomatic)
pnpm eslint src/ --rule 'sonarjs/cognitive-complexity: [error, 15]'
# ต้องติดตั้ง: pnpm add -D eslint-plugin-sonarjs

# SonarQube CLI (ของจริง)
sonar-scanner -Dsonar.complexity.threshold=15
```
