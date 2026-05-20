# 17 — SonarQube + Claude CI/CD Setup

วิธีตั้งค่า code quality scan อัตโนมัติ + ให้ Claude แก้ issues ใน GitHub Actions

---

## ภาพรวม Flow

```
Local Code
   │
   ├─ git push
   ↓
GitHub Actions (.github/workflows/quality-pipeline.yml)
   │
   ├─ Step 1: รัน tests + coverage
   ├─ Step 2: sonar-scanner → ส่ง report ไป SonarQube
   ├─ Step 3: รอ Quality Gate result
   │            ├─ PASS  → จบ (success)
   │            └─ FAIL  → ไป auto-fix job
   │
   └─ Step 4 (auto-fix): Claude ดึง issues + แก้ + เปิด PR
```

---

## ไฟล์ที่ template ใส่ให้แล้ว

| ไฟล์ | หน้าที่ |
|------|--------|
| `.github/workflows/quality-pipeline.yml` | CI pipeline (scan → gate → auto-fix → PR) |
| `sonar-project.properties` | Sonar scanner config (sources/tests/coverage/exclusions) |
| `scripts/setup-sonar.sh` | Interactive setup (แทน placeholders + บอก secrets ที่ต้องตั้ง) |
| `.env.sonar.example` | Template สำหรับ local scan (สร้างโดย setup script) |

---

## ขั้นตอน Setup (one-time)

### 1) รัน setup script

```bash
bash scripts/setup-sonar.sh
```

ตอบคำถาม:
- **Project Key** — เช่น `myapp` (ห้ามมีช่องว่าง)
- **Project Name** — `My App`
- **Host** — SonarCloud (`https://sonarcloud.io`) หรือ self-hosted URL
- **Organization** — (เฉพาะ SonarCloud)

Script จะ:
- แทน placeholder ใน `sonar-project.properties`
- สร้าง `.env.sonar.example`
- เพิ่ม `.env.sonar` + `.sonar-fix/` เข้า `.gitignore`

### 2) สร้าง Project ใน SonarQube

**SonarCloud:**
1. https://sonarcloud.io → My Projects → `+` → Analyze new project
2. เลือก GitHub repo → ใช้ key เดียวกับใน `sonar-project.properties`

**Self-hosted:**
1. เปิด SonarQube → Projects → Create Project Manually
2. ใส่ key + name ตรงกัน

### 3) สร้าง Token

**SonarCloud / SonarQube:**
- My Account → Security → Generate Tokens
- Type: `User Token` (หรือ `Project Analysis Token`)
- Copy ทันที (เห็นครั้งเดียว)

### 4) ใส่ GitHub Secrets

GitHub repo → **Settings → Secrets and variables → Actions → New repository secret**

| Secret | ค่า |
|--------|-----|
| `SONAR_TOKEN` | token จาก step 3 |
| `SONAR_HOST_URL` | `https://sonarcloud.io` หรือ URL ของ self-hosted |
| `ANTHROPIC_API_KEY` | จาก https://console.anthropic.com → API Keys |

### 5) Push code

```bash
git add .
git commit -m "ci: add Sonar + Claude auto-fix workflow"
git push
```

→ ไป **Actions tab** ดู workflow ทำงาน

---

## ใช้งานประจำวัน

### Push ปกติ (main / develop)

Workflow รันเอง 100%:
1. Scan code
2. ถ้า gate PASS → จบ
3. ถ้า gate FAIL → Claude เปิด PR ชื่อ `Claude: Auto-fix SonarQube issues`
4. Review PR → merge ถ้าเห็นด้วย

### Pull Request

- Scan + comment ผล gate บน PR (ไม่ auto-fix)
- ใช้สำหรับ block merge ถ้า gate fail

### Manual trigger

GitHub → Actions → **Sonar + Claude Auto-Fix** → **Run workflow**
- เลือก branch
- toggle `auto_fix` ตามต้องการ

### Local scan (ทดสอบก่อน push)

```bash
cp .env.sonar.example .env.sonar
# แก้ .env.sonar ใส่ค่าจริง
set -a && source .env.sonar && set +a
npx -y sonar-scanner
```

---

## ปรับ Quality Gate

### ใช้ Default (แนะนำ)

Sonar Way ครอบคลุม:
- New code coverage ≥ 80%
- Duplicated lines on new code < 3%
- 0 BLOCKER / CRITICAL bugs

### Custom Gate

SonarQube → Quality Gates → Create → ใส่เงื่อนไขเอง → assign ให้ project

---

## Auto-Fix Scope

Claude จะ:
- ✅ แก้ issues `BLOCKER`, `CRITICAL`, `MAJOR` เท่านั้น (configurable ใน workflow)
- ✅ Skip ถ้าเป็น false positive (log ใน `.sonar-fix/skipped.md`)
- ✅ รัน tests verify ไม่พัง
- ❌ ไม่แก้ `node_modules/`, `dist/`, `build/`, workflows
- ❌ ไม่เปลี่ยน behavior — แก้แค่ code smell / minor refactor

### ปรับ severity threshold

แก้ `.github/workflows/quality-pipeline.yml`:
```yaml
# default: BLOCKER,CRITICAL,MAJOR
"${SONAR_HOST_URL}/api/issues/search?...&severities=BLOCKER,CRITICAL"
```

---

## Troubleshooting

| ปัญหา | สาเหตุ | แก้ไข |
|-------|--------|------|
| `SONAR_TOKEN: not set` | secret ไม่ได้ใส่ | ดู step 4 |
| Scan ผ่านแต่ coverage = 0% | ไม่ได้ generate `lcov.info` | เพิ่ม `--coverage` flag ใน test script |
| Auto-fix ไม่เปิด PR | gate PASS หรือไม่มี changes | ปกติ — ไม่ต้องแก้ |
| `Project not found` | key ใน properties ≠ Sonar | ตรวจ `sonar.projectKey` ตรงกัน |
| Claude แก้ผิด | LLM ผิดพลาด | review PR diff → request changes หรือ close + manual fix |

---

## ปิดใช้งานชั่วคราว

แค่ลบไฟล์ workflow:
```bash
rm .github/workflows/quality-pipeline.yml
```

หรือ disable ใน GitHub → Actions → Workflows → **...** → Disable
