# 05 — Interaction and States

All values below match the behavior and timing in `taarraa-ui-prototype.html`.

---

## Navigation Behavior

### Screen Transitions
| From | To | Trigger | Animation |
|---|---|---|---|
| Splash | Login | Auto after 2200ms | fadeUp 280ms |
| Splash | Login | "Skip →" tap | fadeUp 280ms |
| Login | OTP | "Next" (valid phone) | fadeUp 280ms |
| OTP | Home | 4 digits entered | fadeUp 280ms |
| OTP | Register | "Complete your profile" link | fadeUp 280ms |
| Register | Home | "Create" or "Skip" | fadeUp 280ms |
| Home | Map | Tap vehicle row or "Where to?" | fadeUp 280ms |
| Map | Search | Tap search card | fadeUp 280ms |
| Search | Map | Tap place result | fadeUp 280ms |
| Map | Booking | Book Now (after driver found) | fadeUp 280ms |
| Booking | Fee | Auto after 17s or Skip | fadeUp 280ms |
| Fee | Rating | After payment confirmed (900ms delay) | fadeUp 280ms |
| Rating | Receipt | Submit rating | fadeUp 280ms |
| Receipt | Home | "Back to Home" | fadeUp 280ms |
| Receipt | Map | "Book again" | fadeUp 280ms |

### Back Navigation
| Screen | Back Button | Action |
|---|---|---|
| Splash | None | Auto-route |
| Login | None | Entry point |
| OTP | Chevron left icon-btn | → Login |
| Register | None | Forward only |
| Map | Back icon-btn | → Home |
| Search | Back icon-btn | → Map |
| Booking | None (PopScope canPop:false) | Cannot go back |
| Fee | None | Forward only |
| Rating | None | Forward only |
| Receipt | None | Forward only |
| History | None | Tab switch |
| HistoryDetail | Back icon-btn | → History |
| Profile | None | Tab switch |
| Terms | Back icon-btn | → Profile |
| Contact | Back icon-btn | → Profile |
| Announcements | Back icon-btn | → Home |
| AnnouncementDetail | Back icon-btn | → Announcements |

### Tab Navigation
- 3 tabs: Home (0), My Booking (1), Profile (2)
- Tap tab → instant switch + fadeUp animation
- Tap same tab → no-op
- Tab bar shows only on Home, History, Profile screens

---

## Auth Flow

```
App Start → Splash (2200ms) → Login
Login → Phone input → validate (≥8 digits) → OTP
OTP → 4-digit input → auto-verify → Home
                        ↘ "New here?" → Register → Home
```

### Login Validation
- Trigger: "Next" button press (NOT on blur)
- Rule: phone digits after +855 ≥ 8 characters
- Invalid: shake animation (400ms) on field + haptic (vibrate 60ms) + error text below
- Valid: navigate to OTP

### OTP Verification
- Auto-focus first box on screen open
- Auto-advance: on input, focus next box
- Auto-back: on backspace + empty, focus previous box
- Auto-verify: when all 4 boxes filled → 700ms delay → navigate to Home
- Demo mode: any 4 digits are accepted
- Timer: 30s countdown, then show "Send again" link
- Resend: restart timer + toast "Code resent"

### Registration
- Name input: ≥2 characters to enable "Create" button
- "Create" → call API → navigate to Home
- "Skip" → call API with auto-name → navigate to Home
- Photo: camera tap → toast "Photo picker coming soon" (not implemented)

---

## Loading States

### Home Screen
```
On load: show 3 skeleton rows (TaSkeleton, 1.1s shimmer)
On data: replace skeletons with vehicle list
On refresh: manual icon-btn → reload + toast "Refreshed"
```

### Map Screen
```
On open: full-screen white overlay (rgba(255,255,255,.94))
  Spinner (64×64, 0.8s rotate)
  Car bounce icon
  Message: "Contacting nearby drivers…"
  Cancel button
On driver found (1800ms): message → "Driver found!"
On booking confirmed (2800ms): dismiss overlay → navigate to Booking
```

### Fee Screen
```
On open: fee content renders immediately
On payment: badge changes from amber "Waiting..." to green "Payment confirmed ✓"
After 900ms: navigate to Rating
```

### History Screen
```
On open: history renders immediately (no skeleton)
On tab switch: instant content swap
```

### Skeleton Specification
```
Animation: linear-gradient(90deg, #EDEEF2, #F7F7FA, #EDEEF2) → background-position
Duration: 1.1s infinite
Shape: white card, borderRadius 16, shadow shadowSm, padding 14, marginBottom 10
Content: 84×52 image block + two text strips (60% and 40% width)
```

---

## Error States

### Validation Errors (Login, OTP)
```
Shake animation: 400ms, translateX(-7px → +7px → -4px → 0)
Haptic: vibrate 60ms
Error text: 13px, #D32F2F, below field, minHeight 18px
```

### API/Network Errors
```
Toast: navy bg, "Something went wrong", 2400ms
No retry button on most screens (user manually retries)
```

### Empty States
```
Not implemented in prototype — list screens always show data
Future: centered text, muted color, optional action button
```

---

## Toast

### Spec (Prototype)
```
Background: #232838 (navy)
Color: white, fontSize: 14, fontWeight: 600
BorderRadius: 14px
Shadow: shadowLg
Icon: check (mint #7CFFB2)
Position: absolute, left: 20, right: 20, bottom: 100px
Animation: opacity 0→1 + translateY(12px→0), 250ms
Duration: 2400ms
No swipe-to-dismiss
No type variants (always mint check icon)
```

### Toast Messages (Prototype)
| Event | Message (EN) | Message (KM) |
|---|---|---|
| Welcome | 🎉 Welcome to Taarraa! | 🎉 សូមស្វាគមន៍មកតារា! |
| Refreshed | ↻ Refreshed | ↻ បានធ្វើបច្ចុប្បន្នភាព |
| Destination set | Destination set ✓ | បានកំណត់គោលដៅ ✓ |
| Centered | 📍 Centered on your location | 📍 នៅទីតាំងរបស់អ្នក |
| Promo | Promo applied: FLY20 | — |
| Calling | 📞 Calling driver… | 📞 កំពុងហៅអ្នកបើកបរ… |
| Safety | 🛡️ Safety toolkit — coming in v2 | — |
| Saved places | 🏠 Saved places — coming in v2 | — |
| Photo | 📷 Photo picker — coming soon | — |
| Cancelled | Booking cancelled | បានបោះបង់ការកក់ |
| Logged out | Logged out | បានចាកចេញ |
| OTP resent | 📩 Code resent | 📩 បានផ្ញើលេខកូដម្ដងទៀត |

---

## Dialog

### Spec (Prototype)
```
Container:
  position: absolute, left: 24, right: 24, top: 50%, translateY(-50%)
  bg: white, borderRadius: 20px, padding: 22px
  textAlign: center
  animation: pop 250ms cubic-bezier(.2,.9,.3,1.2)

Backdrop:
  bg: rgba(15,17,25,.5), animation: fade 200ms

Title: h3, fontSize: 18, margin: 0 0 8px
Body: fontSize: 14, color: #6B7588, margin-bottom: 16px
Actions (.drow): display flex, gap: 10px, full-width buttons side by side
```

### Dialogs in Prototype
| Trigger | Title | Actions |
|---|---|---|
| Cancel booking | "Cancel booking?" | "Yes, cancel" (danger-ghost) + "Keep waiting" (primary) |
| Logout | "Log out" | "Cancel" (ghost) + "Log out" (primary) |

---

## Bottom Sheet

### Spec (Prototype)
```
Container:
  position: absolute, left: 0, right: 0, bottom: 0
  bg: white, borderRadius: 22px 22px 0 0
  padding: 12px top (grab), 20px sides, 26px bottom
  maxHeight: 82%
  overflow-y: auto
  animation: up 300ms cubic-bezier(.2,.9,.3,1)

Grab handle:
  width: 44px, height: 5px
  borderRadius: 99px
  bg: #D8DBE3
  margin: 0 auto 14px

Backdrop:
  bg: rgba(15,17,25,.5)
  animation: fade 200ms
  close on tap
```

### Sheets in Prototype
| Trigger | Content |
|---|---|
| Map Tariff button | Vehicle name + tariff (min fee, price/km, seats) + "Got it" |
| Prototype FAB | "Jump to screen" grid |

---

## Micro-Interactions

### Button Press
```css
button:active { transform: scale(.97) }
```
Duration: instant on press, instant on release

### Screen Transition
```css
@keyframes fadeUp { from { opacity:0; transform:translateY(10px) } to { opacity:1; transform:none } }
.screen.active { animation: fadeUp .28s ease }
```

### Sheet Open
```css
@keyframes up { from { transform:translateY(60px); opacity:0 } }
.sheet { animation: up .3s cubic-bezier(.2,.9,.3,1) }
```

### Dialog Open
```css
@keyframes pop { from { transform:translateY(-50%) scale(.9); opacity:0 } }
.dialog { animation: pop .25s cubic-bezier(.2,.9,.3,1.2) }
```

### Toast
```css
#toast { opacity:0; transform:translateY(12px); transition:.25s }
#toast.show { opacity:1; transform:none }
```

### Shake (Validation Error)
```css
@keyframes shake { 0%,100%{transform:none} 25%{translateX(-7px)} 50%{translateX(7px)} 75%{translateX(-4px)} }
.shake { animation: shake .4s }
```

### Splash Pop
```css
@keyframes pop2 { from { transform:scale(.7); opacity:0 } }
.splash-logo { animation: pop2 .6s cubic-bezier(.2,.9,.3,1.2) }
```

### Skeleton Shimmer
```css
@keyframes sh { to { background-position:-200% 0 } }
skel i { animation: sh 1.1s infinite }
```

### Splash Loading Bar
```css
@keyframes load { 0%{transform:translateX(-100%)} 100%{transform:translateX(300%)} }
.splash-load span { animation: load 1s infinite ease-in-out }
```

### Booking Spinner
```css
@keyframes spin { to { transform:rotate(360deg) } }
.spinner { animation: spin .8s linear infinite }
```

### Car Bounce
```css
@keyframes bnc { 50%{transform:translateY(-8px)} }
.car-bounce { animation: bnc 1s infinite ease-in-out }
```

### Status Pulse
```css
@keyframes pl { 50%{opacity:.35} }
.pulse { animation: pl 1.2s infinite }
```

### Star Pop
```css
@keyframes pop3 { 50%{transform:scale(1.3)} }
.stars button.lit { animation: pop3 .25s }
```

### Backdrop Fade
```css
@keyframes fade { from { opacity:0 } }
.backdrop { animation: fade .2s }
```

---

## Keyboard Handling

| Screen | Auto-Focus | Dismiss On |
|---|---|---|
| Login | Phone field | Tap Continue / Tap outside |
| OTP | First OTP box | 4 digits entered |
| Register | Name field | Tap Create / Skip |
| Search | Search field | Tap place result |
| Map Note | Note field | Tap outside / Scroll |

---

## Accessibility

### Touch Targets
- Icon buttons: 42×42px (meets minimum)
- Tab buttons: 8px padding top/bottom on 11px text
- Vehicle rows: full-width, 12+14px padding
- History cards: full-width, 14px padding

### Contrast Ratios
| Color Pair | Ratio | WCAG |
|---|---|---|
| #191C24 on white | 16.7:1 | AAA |
| #6B7588 on white | 4.82:1 | AA (large text) |
| #9AA0B4 on white | 2.75:1 | Decorative only |
| #FF4500 on white | 4.52:1 | AA (large text) |
| #CC3700 on white | 5.94:1 | AA |
| white on #FF4500 | 4.52:1 | AA (large text) |
| white on #232838 | 12.6:1 | AAA |

### Localization
- All strings: EN/KM bilingual via I18N dictionary
- Date format: "10 Sep 2026" (prototype) — dd MMM yyyy
- Currency: $ (US Dollar) — prototype uses `$` not ៛
- RTL: not required (both languages are LTR)
- Font: KantumruyPro supports both scripts natively
