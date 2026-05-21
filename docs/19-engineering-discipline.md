# 19 — Engineering Discipline
**[Project Name]**

| เวอร์ชัน | วันที่ |
|---------|-------|
| v1.0 | YYYY-MM-DD |

> หลักการ engineering ที่ทุก dev + AI ต้องยึด — โดยปรับมาจาก 9arm-skills (`debug-mantra` · `scrutinize` · `post-mortem`)
> ไม่ใช่ workflow stage แต่เป็น **discipline framework** ที่ใช้ตลอด

---

## A. 4-Step Debug Mantra (ใช้ทุกครั้งเจอ bug)

> ก่อนเสนอ fix ใด ๆ ต้องผ่าน 4 step ตามลำดับ — ห้ามข้าม

### Mantra (ท่องในใจ + บันทึกใน ISS entry)

```
1. First is reproducibility. Can the issue be reproduced reliably?
2. Know the fail path. Debugger first; then source trace + knob enumeration;
   then in-code instrumentation.
3. Question your hypothesis. What would disprove it?
4. Every run is a breadcrumb. Cross-reference all of them.
```

### Step 1 — Reproduce reliably

| สถานการณ์ | ทำอะไร |
|----------|--------|
| **Reliable repro** มีอยู่ | จับเป็น runnable artifact: failing test / curl / CLI / replay harness |
| **Flaky** (เจอบ้างไม่เจอบ้าง) | **เพิ่ม rate ก่อน** — loop, parallel, stress, narrow timing → 50% flake = debuggable; 1% = ยังไม่ใช่ |
| **No repro** | **หยุด** — บอก user ว่า missing อะไร ขอ env access / artifact / permission instrument · **ห้ามเดา hypothesis ต่อ** |

Target: signal pass/fail ใน 1-5 วินาที, deterministic (pin time, seed RNG, freeze network)

### Step 2 — Know the fail path

ลองตามลำดับ — escalate เมื่อตัวก่อนหน้าไม่ work:

1. **Debugger** — attach + step ไป failure site (1 breakpoint > 10 logs)
2. **Source trace + knob enumeration** — list ทุกตัวแปรที่ flip ได้ (config / env / flag / branch / timing / build option) — flip ทีละ knob
3. **In-code instrumentation** — log/print + tag เฉพาะ (เช่น `[DBG-a4f2]`) ให้ grep cleanup ได้ครั้งเดียว

### Step 3 — Falsify hypothesis (ก่อนทดสอบ)

- explain symptom end-to-end ได้ไหม?
- หา **disproof ที่สะอาดที่สุด** — รัน disproof ก่อน proof (กัน confirmation bias)
- **gen 3-5 hypotheses เรียง rank** — ไม่ใช่ anchor ที่ idea แรก

### Step 4 — Breadcrumb Ledger

เก็บ ledger ทุก experiment:
```
| Run # | What changed | Result | Ruled in / Ruled out |
|-------|--------------|--------|---------------------|
| 1     | log scratchBuf ก่อน launch | NULL | scratchBuf ไม่ถูก init |
| 2     | force numStreams = 2 | bug หาย | confirm fast-path gate |
```

เมื่อเจอ hypothesis ใหม่ → ตรวจกับ **ทุก** ledger entry ที่ผ่านมา — ถ้าขัด → hypothesis ผิด

### Operating rules

- ห้าม propose fix ก่อน step 1 (มี repro)
- ห้าม commit hypothesis ก่อน step 3 (พยายาม disprove)
- ห้าม declare correct ก่อน step 4 (ตรวจกับ ledger ทั้งหมด)

---

## B. Scrutinize — Outsider Review (ก่อน mark `[x]` หรือก่อน PR)

> ยืนข้างนอก เปิด code/plan อ่านเย็น ๆ ถามว่ามันควรมีอยู่หรือเปล่า แล้วเดิน path ตรวจว่าทำตามที่อ้างจริง

### Workflow 4 step

**1. Intent** — บอกเป้าหมายเป็น 1 ประโยคในภาษาตัวเอง
- ถ้าบอกไม่ได้ → artifact underspecified → **หยุด** บอก user
- ถาม: มีวิธีง่าย/เล็ก/elegant กว่านี้ไหม?
  - ไม่ทำเลย (ปัญหาจริงไหม?)
  - reuse ของที่มีอยู่
  - แก้ที่ layer อื่น (config vs code)
  - 90% ของ goal ด้วย 10% effort

**2. Trace** — เดิน call graph **จริง** (ไม่ใช่แค่ diff)
- Entry → call sites → branches → mutations → exit/side effect
- รวม code **รอบ** diff ด้วย — bug อยู่ที่ seam
- ถ้าเจอ surprise (branch ที่ไม่คาด, dead code, state ที่ไม่รู้) → จดไว้ = signal

**3. Verify**
- claim X → trace path A→B→C → "ที่ C: [observation] → holds / doesn't hold"
- edge cases: empty / null / unicode / huge / concurrent / retry / partial failure
- silent changes: perf / error semantics / observability / on-disk format / contract for other callers
- test: actually exercise path นี้ไหม? mock ไม่ได้บัง bug?

**4. Report** — finding เรียง severity (blocker → major → nit)

ทุก finding มี 4 ส่วน:
```
Finding:        [1 ประโยค + file:line]
Why it matters: [consequence ไม่ใช่ principle]
Evidence:       [trace step / input ที่ expose]
Suggested:      [concrete, minimal change]
```

ปิด 1 บรรทัด: **`ship / fix-then-ship / rework / reject`** + เหตุผลใหญ่ที่สุด

### Rules

- ห้าม "LGTM" — ถ้าไม่เจออะไรเลย ระบุว่า trace อะไรไปบ้าง + check อะไร เพื่อให้ user judge
- **cite หรือ didn't happen** — ทุก claim มี file:line
- แยก "PR บอก X" กับ "ผม trace ยืนยัน X" ออกจากกัน
- One simpler-alternative pass **บังคับ** (skip ได้แค่ user บอก "don't question scope")
- มี structural issue → ห้าม pad ด้วย style nit
- no flattery, no hedging

---

## C. Post-mortem Gates (ก่อน ISS-XXX → `CLOSED`)

> ก่อนปิด issue ต้องผ่าน 4 input — ถ้าไม่ครบ refuse + บอก user ว่าขาดอะไร

### Required inputs (refuse to close ถ้าไม่ครบ)

```
[ ] 1. Reliable repro    (deterministic — ไม่ใช่ "เจอบางที")
[ ] 2. Root cause known  (mechanism — ไม่ใช่ hypothesis)
[ ] 3. Fix identified    (PR/commit/branch pointer)
[ ] 4. Fix validated     (repro เดิม pass + workload สำเร็จ)
```

**4 ข้อนี้ map ตรงกับ debug-mantra step 1-4** → ledger จาก step 4 = raw material

### Mandatory sections (4 ข้อ ใน ISS entry สำหรับ CLOSED)

| Section | บังคับ | เนื้อหา |
|---------|:------:|--------|
| Symptom | | สิ่งที่สังเกตจริง (error msg / log / perf) — concrete identifier ไม่ paraphrase |
| **Root Cause** | ✅ | mechanism จริง — code identifier welcome (function name, file:line, SHA) |
| Why it produced symptom | | link cause → visible failure (อาจ non-obvious) |
| **Fix** | ✅ | อะไรเปลี่ยน + ทำไม fix นี้แก้ root cause (ไม่ใช่บังอาการ) |
| How it was found | | path debug + hypotheses rejected (จาก ledger) |
| **Why it slipped through** | ✅ | CI gap / latent / workload gap / incomplete prior fix / review miss — **blameless** |
| **Validation** | ✅ | repro pass + scope ที่ test — **honest** ถ้า test แค่ 1 config |
| Action items | | what + owner + tracking artifact (test เพิ่ม / CI gap / doc) |

### Anti-patterns (อย่าทำ)

| ❌ | ✅ |
|----|----|
| paraphrase root cause | "synchronization issue" → "function X ข้าม event Y ใต้ gate Z" |
| hedging | "we believe / appears to / may have" → ลบ |
| blame คน | "X should have caught this" → "CI gap is the failure mode" |
| imply broader test coverage | ทดสอบ config เดียว → ระบุชัด "tested on A; not retested on B" |
| มี structural issue → list nit หลายอัน | lead with structural, drop nits |

---

## D. Tone Rules (ทุก doc + commit + ISS + Report)

| Rule | ตัวอย่าง |
|------|---------|
| **Active voice** | "Alex wrote the fix" > "The fix was authored" |
| **Concrete subject** | "the kernel reads NULL" > "an issue occurs" |
| **Short paragraph** | 1-3 ประโยค |
| **No hedging** | drop "we believe / appears / may have" — state or don't write |
| **No flattery** | ไม่ "This is great but…" — ระบุ finding ตรง ๆ |
| **Cite file:line** | "src/auth/login.ts:42" — ไม่ใช่ "in the login function" |
| **Distinguish claim vs verified** | "PR says X" ≠ "I traced and confirmed X" |
| **Blameless** | describe gap/bug — ไม่ใช่ describe คน |
| **Code identifier เก็บใน eng record** | post-mortem (12) เก็บ `tadaLaunchPrepare`; FB (14) strip ออก |
| **Honest scope** | "tested on Llama-2-70B / 8 GPUs; not retested on others" |

---

## E. Integration กับ Workflow

| ตอนไหน | ใช้ discipline ไหน | บันทึกที่ไหน |
|--------|-------------------|-------------|
| เจอ bug / error | A. Debug Mantra (4 step) | ledger ใน ISS entry · `12-log-issues.md` |
| ก่อน mark `[x]` (PR-size change) | B. Scrutinize (4 step) | Test Report Section 11 (Overall Result) — ระบุ "Self-scrutinize: passed" + verdict |
| ก่อน ISS → `CLOSED` | C. Post-mortem (4 gates) | `12-log-issues.md` (mandatory sections) |
| ทุกที่ | D. Tone Rules | ทุก doc + commit message |

---

## F. Refuse Patterns (AI ปฏิเสธทำ)

AI **ปฏิเสธ + บอกขาดอะไร** ในกรณีเหล่านี้:

| Action | Refuse condition |
|--------|------------------|
| เสนอ bug fix | ไม่มี reliable repro |
| Mark ISS `CLOSED` | 4 inputs ไม่ครบ |
| Draft post-mortem section ใน ISS | hypothesis ยังไม่ confirm เป็น root cause |
| LGTM ใน scrutinize | ระบุไม่ได้ว่า trace อะไรไปบ้าง |
| State validation broader than tested | imply coverage เกินจริง |

ถ้า user กดดันให้ proceed → AI **อธิบายความเสี่ยง** + บันทึกการตัดสินใจใน ISS เป็น risk note

---

## Changelog

| เวอร์ชัน | วันที่ | รายละเอียด |
|---------|-------|-----------|
| v1.0 | YYYY-MM-DD | adapted from 9arm-skills (debug-mantra, scrutinize, post-mortem) |
