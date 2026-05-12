# 06 — UX/UI Design
**[Project Name]**

| เวอร์ชัน | วันที่ |
|---------|-------|
| v1.0 | YYYY-MM-DD |

> อ่านก่อนสร้าง UI component หรือแก้ layout

---

## Design Tokens

### Color (Tailwind config)

| Token | Light | Dark | ใช้กับ |
|-------|------|------|-------|
| `--background` | `#ffffff` | `#0a0a0a` | body |
| `--foreground` | `#0a0a0a` | `#fafafa` | text หลัก |
| `--primary` | `#2563eb` | `#3b82f6` | CTA, link |
| `--muted` | `#f4f4f5` | `#1f1f1f` | bg secondary |
| `--border` | `#e5e7eb` | `#27272a` | input, divider |
| `--destructive` | `#dc2626` | `#ef4444` | delete, error |
| `--success` | `#16a34a` | `#22c55e` | success toast |
| `--warning` | `#ea580c` | `#f97316` | warning |

### Spacing

ใช้ Tailwind scale — ห้าม hardcode pixel:
- `p-2` (8px) — gap เล็กในกลุ่ม
- `p-4` (16px) — gap ทั่วไป
- `p-6` (24px) — gap ระหว่าง card
- `p-8` (32px) — gap ระหว่าง section

### Typography

| Class | ใช้กับ |
|-------|-------|
| `text-3xl font-bold` | h1 / page title |
| `text-2xl font-semibold` | h2 / section title |
| `text-xl font-semibold` | h3 |
| `text-base` | body |
| `text-sm text-muted-foreground` | hint / metadata |
| `text-xs` | label, badge |

### Radius / Shadow

- `rounded-md` (6px) — input, button
- `rounded-lg` (8px) — card
- `shadow-sm` — card default
- `shadow-md` — dropdown, popover

---

## Responsive Breakpoints

| Breakpoint | Tailwind | ตรวจ Browser Test |
|-----------|---------|-------------------|
| Mobile | `< 640px` | 375px (iPhone) |
| Tablet | `sm: 640px+` | 768px (iPad) |
| Desktop | `md: 768px+` `lg: 1024px+` | 1440px |

Layout pattern:
- Mobile-first: เริ่มจาก mobile แล้วเพิ่ม `md:` / `lg:`
- Sidebar: drawer บน mobile, fixed sidebar บน desktop
- Table: card list บน mobile, table grid บน desktop

---

## Component Conventions

### Form

```
- ใช้ react-hook-form + Zod resolver
- field ทุกตัวต้องมี <Label> + aria-label
- error message อยู่ใต้ field, ใช้ text-destructive
- submit button: loading state + disabled ตอนกำลังส่ง
- ห้าม alert() / confirm() — ใช้ Toast (sonner) + AlertDialog (shadcn)
```

### Table / List

```
- pagination ทุก list (default limit 20)
- empty state: icon + ข้อความ + CTA
- loading state: skeleton (ไม่ใช่ spinner เปล่า)
- error state: ปุ่ม "ลองใหม่"
- delete: AlertDialog ยืนยันก่อนจริง
```

### Toast

| ประเภท | เมื่อไหร่ | duration |
|-------|---------|---------|
| `success` | save/update/delete สำเร็จ | 3s |
| `error` | API error, validation fail | 5s |
| `warning` | rate limit, partial success | 4s |

---

## Accessibility (WCAG 2.1 AA — บังคับ)

- [ ] ทุก input มี `<label>` หรือ `aria-label`
- [ ] ทุก button/link มี text (ถ้า icon-only ต้องมี `aria-label`)
- [ ] ทุก image มี `alt`
- [ ] keyboard navigation ครบ (Tab + Enter + Esc)
- [ ] focus ring มองเห็นชัดเจน
- [ ] color contrast ratio ≥ 4.5:1 (text) / 3:1 (UI)
- [ ] form error อ่านได้ด้วย screen reader (`role="alert"`)

---

## Dark Mode

- ใช้ `next-themes` + Tailwind `dark:` modifier
- toggle อยู่บน header — บันทึก preference ใน localStorage
- ตรวจทุกหน้า dark + light ก่อน mark task เสร็จ

---

## Iconography

- ใช้ `lucide-react` เท่านั้น — ห้ามผสม icon library อื่น
- ขนาด: `size={16}` ใน inline, `size={20}` ใน button, `size={24}` ใน header

---

## Changelog

| เวอร์ชัน | วันที่ | รายละเอียด |
|---------|-------|-----------|
| v1.0 | YYYY-MM-DD | สร้าง template |
