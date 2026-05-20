# 18 — JMeter Load Testing Setup

วิธีตั้งค่า Apache JMeter load test ใน Quality Pipeline (รวมใน workflow เดียวกับ Sonar)

---

## ภาพรวม Flow

```
workflow_dispatch (manual)
   │
   ├─ ติ๊ก "Run JMeter load test" = ON
   ↓
JMeter job (.github/workflows/quality-pipeline.yml)
   │
   ├─ Step 1: อ่าน target URL (จาก input หรือ secret)
   ├─ Step 2: รัน baseline.jmx → result.jtl
   ├─ Step 3: check thresholds (jmeter-check.sh)
   │            ├─ PASS → ✅
   │            └─ FAIL → ส่งต่อให้ Claude แก้ + เปิด PR
   └─ Step 4: upload HTML report เป็น artifact (14 วัน)
```

---

## ไฟล์ที่ template ใส่ให้แล้ว

| ไฟล์ | หน้าที่ |
|------|--------|
| `tests/jmeter/baseline.jmx` | Test plan parameterized (target/users/duration ส่งจาก CLI) |
| `tests/jmeter/thresholds.env` | Pass/fail budget — P95, P99, error rate, throughput |
| `tests/jmeter/README.md` | คู่มือปรับ test plan |
| `scripts/setup-jmeter.sh` | Interactive setup (target + thresholds) |
| `scripts/run-jmeter.sh` | Local runner — `bash scripts/run-jmeter.sh <URL>` |
| `scripts/jmeter-check.sh` | Threshold checker — อ่าน .jtl + เทียบ thresholds.env |

---

## Setup (one-time)

### 1) รัน setup

```bash
bash scripts/setup-jmeter.sh
# → ใส่ target URL + ปรับ P95/error thresholds
```

### 2) (Optional) ตั้ง Secret

ถ้าอยาก trigger ผ่าน schedule หรือไม่อยากใส่ URL ทุกครั้ง:

GitHub → Settings → Secrets → Actions → New repository secret:
- `JMETER_TARGET_URL` = `https://staging.example.com/api/health`

ถ้าใส่ใน workflow input ตอนรัน → override secret

### 3) ติดตั้ง JMeter (เฉพาะ run local)

```bash
# macOS
brew install jmeter

# Linux
sudo apt install jmeter

# Docker (ไม่ต้องติดตั้ง)
docker run --rm -v $PWD:/tests justb4/jmeter \
  -n -t /tests/tests/jmeter/baseline.jmx \
  -l /tests/result.jtl \
  -Jtarget.host=app.example.com
```

(CI ไม่ต้องติดตั้ง — `rbhadti94/apache-jmeter-action` มี JMeter built-in)

---

## ใช้งานประจำวัน

### CI — Manual trigger

GitHub → **Actions** → **Quality Pipeline** → **Run workflow** → ตั้งค่า:

| Input | ค่า | หมายเหตุ |
|-------|------|---------|
| `Run SonarQube scan` | ✅ / ⬜ | static analysis |
| `Run JMeter load test` | ✅ / ⬜ | load test (ต้องใส่ target) |
| `JMeter target URL` | `https://...` | override `JMETER_TARGET_URL` secret |
| `Let Claude auto-fix` | ✅ / ⬜ | แก้อัตโนมัติถ้า fail |

### CI — Auto (push/PR)

- Push → Sonar เท่านั้น (JMeter ต้อง opt-in เสมอ เพราะใช้เวลานาน)
- PR → Sonar comment ผลบน PR

### Local — ทดสอบก่อน push

```bash
bash scripts/run-jmeter.sh https://staging.example.com/api/health 10 30
# arg: URL [users] [duration_sec] [ramp_sec]
```

ผลลัพธ์:
```
tests/jmeter/results/result.jtl        ← raw data
tests/jmeter/results/report/           ← HTML report (open index.html)
```

---

## ปรับ Test Plan

### กรณีที่ 1: เปลี่ยน endpoint

แก้ `tests/jmeter/baseline.jmx` ผ่าน JMeter GUI:
```bash
jmeter -t tests/jmeter/baseline.jmx
```

เพิ่ม HTTP Request samplers + assertions ตามต้องการ → save กลับ

### กรณีที่ 2: เพิ่ม test plan หลายตัว

Copy `baseline.jmx` เป็นไฟล์ใหม่:
```
tests/jmeter/
├── baseline.jmx       ← health check (default)
├── checkout-flow.jmx  ← multi-step user flow
└── api-stress.jmx     ← stress test (100+ users)
```

แล้ว config workflow ให้รันไฟล์ที่ต้องการ (แก้ `testFilePath` ใน `.github/workflows/quality-pipeline.yml`)

### กรณีที่ 3: ปรับ load profile

ส่งผ่าน CLI properties (JMeter รับผ่าน `${__P(name,default)}`):

```bash
jmeter -n -t baseline.jmx \
  -Jusers=50 \
  -Jramp=30 \
  -Jduration=120
```

หรือใน workflow_dispatch — เพิ่ม input ใน `quality-pipeline.yml`

---

## ปรับ Thresholds

แก้ `tests/jmeter/thresholds.env`:

```env
P95_MAX_MS=500          # 95th percentile (แนะนำ start ที่ 500ms)
P99_MAX_MS=1000         # 99th percentile
AVG_MAX_MS=300          # average response
ERROR_RATE_MAX=1.0      # % errors allowed
THROUGHPUT_MIN_RPS=0    # 0 = ไม่ check (ตั้ง > 0 ถ้าอยาก enforce)
```

### Recommended thresholds

| Use case | P95 | Error % |
|----------|-----|---------|
| Internal API | 200ms | 0.1 |
| Public API | 500ms | 1.0 |
| Page load | 1500ms | 1.0 |
| Background job | 5000ms | 5.0 |

---

## Auto-Fix Scope (Claude)

ถ้า threshold fail Claude จะ:
- ✅ อ่าน `.quality-fix/jmeter/result.jtl` หา slow endpoint
- ✅ วิเคราะห์ source code → หา N+1 query, missing index, blocking I/O
- ✅ แก้ที่ controller/service ของ endpoint นั้น
- ✅ Run tests verify ไม่พัง
- ❌ ไม่แก้ test plan (.jmx) เอง — ปล่อยให้ดูปัญหาที่ code

ถ้าแก้ไม่ได้ (false alarm จาก network jitter) → Claude log ใน `.quality-fix/skipped.md`

---

## Troubleshooting

| ปัญหา | สาเหตุ | แก้ไข |
|-------|--------|------|
| `tests/jmeter/baseline.jmx not found` | template ไม่สมบูรณ์ | clone ใหม่ |
| `No JMeter target URL` | ไม่ใส่ input + ไม่มี secret | ใส่ workflow input หรือ secret |
| `jmeter: command not found` (local) | ไม่ได้ติดตั้ง | `brew install jmeter` |
| Threshold fail แต่ผลดูปกติ | network jitter จาก runner | run อีกรอบ หรือเพิ่ม `users`/`duration` |
| Run นาน > 10 นาที | ตั้ง `duration` สูงเกิน | ลดเหลือ 30-60s ใน CI |

---

## เปรียบเทียบกับ Sonar

| | Sonar (static) | JMeter (runtime) |
|---|----------------|------------------|
| ตรวจตอน | commit / pre-deploy | post-deploy / staging |
| เจอ | bug, smell, security, coverage | slow API, error rate, capacity |
| รันบ่อย | ทุก push | manual / nightly |
| ต้อง deploy ไหม | ❌ ไม่ต้อง | ✅ ต้อง — มี target URL |
| ใช้ทดแทนกันได้ไหม | ❌ คนละหน้าที่ | ❌ คนละหน้าที่ |

→ ใช้คู่กัน = quality ครบ 360°
