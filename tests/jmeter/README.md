# tests/jmeter/

JMeter test plans + thresholds สำหรับ load/performance testing

## ไฟล์

| File | หน้าที่ |
|------|--------|
| `baseline.jmx` | Test plan default — GET target URL ด้วย 10 users / 30s |
| `thresholds.env` | Pass/fail thresholds (p95, p99, error rate, throughput) |
| `results/` | Output ของ run ล่าสุด (gitignored) |

## ปรับ Test Plan

### วิธีที่ 1: แก้ผ่าน JMeter GUI (แนะนำ)

```bash
# เปิด GUI (ต้องติดตั้ง JMeter local)
jmeter -t tests/jmeter/baseline.jmx
```

- เพิ่ม HTTP Request samplers ตาม endpoint ที่ต้อง test
- เพิ่ม CSV Data Set Config สำหรับ test data
- บันทึก save เป็น `.jmx` กลับ

### วิธีที่ 2: เพิ่ม endpoints หลายตัว

Copy `baseline.jmx` เป็น `api-stress.jmx`, `checkout-flow.jmx` ฯลฯ แล้ว reference ใน workflow:

```yaml
# .github/workflows/quality-pipeline.yml — jmeter job
testFilePath: tests/jmeter/checkout-flow.jmx
```

## Properties ที่ workflow ส่งให้

```
-Jtarget.protocol=https
-Jtarget.host=app.example.com
-Jtarget.port=443
-Jtarget.path=/api/health
-Jusers=10
-Jramp=10
-Jduration=30
```

ใน `.jmx` ใช้ `${__P(target.host)}` เพื่อ pickup ค่า

## Run Local

```bash
bash scripts/run-jmeter.sh https://app.example.com/api/health
# → tests/jmeter/results/result.jtl + report/
```

ดูรายละเอียดเต็มที่ `docs/18-jmeter-setup.md`
