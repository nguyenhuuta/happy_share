# Prompt Google Stitch — Happy Share M1 (hợp đồng 2.0: nhật ký cá nhân + nhóm)

Phạm vi của bộ prompt này: **đúng các màn hình và luồng chuyển giữa chúng** (màn chính, bước tiếp theo, bottom sheet, hộp thoại xác nhận, màn thành công). **Chưa** gồm trạng thái lỗi (lỗi API/mạng/validate), đang tải, offline — cách hiển thị các trạng thái đó sẽ quy ước riêng sau rồi mới thêm prompt.

**Thay đổi so với bản cũ (hợp đồng 2.0):** hành trình được ghi **cho từng người**, dùng được ngay cả khi chưa có nhóm. Nhóm (gia đình, bạn bè…) là **tùy chọn**: một người ở tối đa 5 nhóm; vào nhóm = đồng ý chia sẻ hành trình **từ lúc vào trở đi**; rời nhóm = ngừng chia sẻ. Mọi nhóm của một người thấy cùng một phần dữ liệu. Chữ hiển thị là **"Nhóm"** (không còn "Gia đình").

Cách dùng
1. Tạo project Stitch mới, chọn **Mobile**. Dán **Khối A + Khối B + Prompt 0** để tạo màn "style guide" làm chuẩn. Nếu bạn đã tự tạo design system trong Stitch thì bỏ qua Prompt 0, chỉ kiểm tra token trong đó khớp Khối A.
2. Mỗi màn dán: **Khối A** (+ **Khối B** chỉ khi màn có chip trạng thái / độ mới — Prompt 0, 6 và 8) + prompt của màn đó. Stitch không nhớ ngữ cảnh giữa các lần tạo nên phải dán lại. Không dán Khối B cho màn không cần: Stitch sẽ vẽ chip vô nghĩa vào màn Đăng nhập.
3. **Mỗi lần chỉ tạo MỘT màn chính.** Các bước tiếp theo của luồng (bottom sheet, hộp thoại, màn thành công, bước kế) gửi sau bằng prompt "Nối tiếp" ngay dưới mỗi màn, trên chính màn vừa tạo. Yêu cầu nhiều khung trong một prompt thường cho kết quả lộn xộn.
4. Chỉnh bằng lệnh ngắn ("làm nút chính cao hơn", "giảm nền xám"). Xong thì xuất **ảnh chụp từng màn + mã HTML/CSS** gửi lại để dựng bằng Flutter.
5. Stitch sinh HTML/CSS chứ không sinh Flutter. Ta dùng nó làm tham chiếu bố cục, màu, khoảng cách và chữ; widget Flutter vẫn dựng lại.

Mọi văn bản hiển thị trong màn hình đã viết sẵn bằng **tiếng Việt** — giữ nguyên, đừng để Stitch dịch hay đổi giọng điệu.

## Sơ đồ luồng M1

```
Mở app
 ├─ chưa đăng nhập ─► [1 Đăng nhập] ◄──► [2 Đăng ký]
 │                          │ xong
 │                          ▼
 ├─ chưa bật "Ghi lại hành trình" ─► [7 Giới thiệu ghi lại hành trình] ─► bước quyền vị trí (7a) ─► vào ứng dụng
 │                                        └─ "Để sau" ─► vào ứng dụng
 └─ đã sẵn sàng ─► Ứng dụng 5 tab (Nhóm · Hành trình · Địa điểm · Thành viên · Cài đặt)
        │   Nhóm là TÙY CHỌN: chưa có nhóm vẫn dùng được nhật ký cá nhân
        ├─ tab Nhóm, chưa có nhóm ─► [3 Chưa có nhóm: Tạo / Tham gia]
        │                               ├─► [4 Tạo nhóm] (kèm đồng ý chia sẻ) ─► thành công ─► "Mời thành viên" hoặc "Để sau"
        │                               └─► [5 Tham gia bằng mã] ⇄ [5A Quét QR] (kèm đồng ý chia sẻ) ─► thành công "Tiếp tục"
        ├─ tab Thành viên ─► [6 Thành viên của nhóm đang xem]
        │                      ├─ Bộ chọn nhóm (đổi nhóm, tạo / tham gia thêm — tối đa 5 nhóm)
        │                      ├─ Mời thành viên (bottom sheet mã + QR)
        │                      ├─ Đổi biệt danh · Xóa khỏi nhóm (chủ nhóm) · Rời nhóm (thành viên)
        └─ tab Cài đặt ─► [8 Ghi lại hành trình của tôi]
                             ├─ Tạm dừng / Tiếp tục / Tắt (và bật lại)
                             ├─ Nhóm đang xem hành trình của tôi (rời nhóm để ngừng chia sẻ với nhóm đó)
                             └─ Múi giờ · Xóa lịch sử hành trình
```

---

## Khối A — Ngữ cảnh & hệ thị giác (dán kèm MỌI prompt)

```
Product: "Happy Share" — a private mobile app (iOS + Android) where each person VOLUNTARILY records their own
daily journey diary (places visited, arrival/departure times, the route recorded) and may OPTIONALLY share it
with small private groups they choose to join (family, close friends). The diary works for one person alone;
groups are optional. Never covert monitoring. Principles: history-first, consent-based, privacy-first.

Design for a 390x844 phone, portrait, LIGHT theme unless told otherwise. UI language: Vietnamese
(diacritics must render correctly). Tone: warm, calm, trustworthy, friendly — like a calm personal notebook,
never a corporate dashboard, never anything that feels like surveillance.

VISUAL SYSTEM — "Warm Indigo & Terracotta" (use these exact tokens; the previous green/amber palette is NOT used any more):
Light: app background #F8F9FB; cards/dialogs #FFFFFF; subtle sections & secondary nav #F3F4F7;
  card borders/dividers #DDE2E8; text #1A2533; secondary text #556578;
  primary "Warm Indigo" #2B4C7E (white text on it); primary container #DDE7F5 with text #14294A (chips, badges, tonal buttons);
  accent "Terracotta" #D96B43 for highlights/fills only; accent container #FCE8E0;
  destructive/error #DC3545 (error text #C21F2F); error container #FEE2E2.
Dark (only when asked): background #141A24; cards #1F2837; raised cards/modals #2A3548; primary #79A7DF;
  primary container #22385A; accent #E28562; borders #2F3B50; text #F0F4F8; muted text #94A3B8.
Accessibility rules for the tokens: never put white text on Terracotta and never use plain Terracotta as small text
  (use dark text #1A2533 on terracotta fills, or text #AE4C28 for links / small accent text on light backgrounds);
  input-field borders use a darker cool grey #7F8B9C (1px) so they are visible; focused input border is 2px #2B4C7E;
  card borders stay the soft #DDE2E8.
Shape & type: font "Be Vietnam Pro" (full Vietnamese diacritics); cards radius 16; input fields radius 12;
  chips/pills fully rounded (9999); touch targets >= 48px; Material 3 style; generous spacing (16/24).

Hard rules:
- Do not print these banned words in any visible text (they are instructions, not copy): "real-time", "live",
  "giám sát", "theo dõi liên tục", "tracking". Prefer: "Hành trình", "Nhật ký", "Điểm đến", "Chia sẻ tự nguyện".
- Each person decides for themselves; a group owner can never turn on recording or sharing for someone else.
- Joining a group means sharing your journey with that group from that moment on; leaving the group stops it.
- Accessible: text contrast >= 4.5:1, readable at 130% font scale.
- Use realistic Vietnamese sample data (names like Mẹ, Bố, Bé Na, Ông ngoại, Lan, Mai; groups "Nhà Nguyễn" and "Hội bạn thân").
- Say "nhóm" (group), never "gia đình" as the generic word.
```

## Khối B — Hiển thị thành viên & độ mới (CHỈ dán cho màn có chip: Prompt 0, 6 và 8)

```
Every group member is always shown together with their sharing state — icon + text, never color alone:
    Đang chia sẻ    — check-circle icon; chip background #E8F5E9; accent #2E7D32; text & icon on chip #2E7D32
    Chia sẻ hạn chế — info-circle icon;  chip background #FEF3C7; accent #D97706; text & icon on chip #A35600
    Đã tạm dừng     — pause-circle icon; chip background #F3F4F6; accent #4B5563; text & icon on chip #4B5563
    Chưa chia sẻ    — minus-circle icon; chip background #F3F4F6; accent #6B7280; text & icon on chip #69707E
  ("accent" = dots, left borders, large icons; the darker "text & icon" value is for small text so it stays readable.)

Location data always carries its freshness as a pill chip:
    "Cập nhật 5 phút trước"        — soft indigo chip (background #DDE7F5, text #14294A)
    "Cập nhật 1 giờ 20 phút trước" — neutral chip (background #F3F4F7, text #556578)
    "Dữ liệu cũ (2 giờ trước)"     — soft terracotta chip (background #FCE8E0, text #AE4C28)
    "Chưa có dữ liệu"              — neutral grey chip (background #F3F4F6, text #69707E)
```

---

## Khối A rút gọn — dùng khi đã chọn màn "Quy chuẩn thiết kế" làm ngữ cảnh trong Stitch

Màn "Quy chuẩn thiết kế" chỉ mang được phần **hình thức** (màu, font, bo góc, thành phần). Các luật bên dưới không nằm trong ảnh nên vẫn phải nhắc. Hãy kiểm tra vài màn đầu: nếu màu/font/bo góc lệch so với Khối A thì quay lại dán Khối A đầy đủ.

```
Context: "Happy Share" — a private personal journey diary app; each person records their own journey, and may
optionally share it with small private groups (family, friends). Sharing is voluntary, never covert monitoring.
Use the attached "Quy chuẩn thiết kế" screen as the single source of truth for colors, typography, radius, buttons,
fields, chips and spacing: reuse its components exactly, do not invent new styles or brand colors.
Phone 390x844, light theme unless told otherwise. All visible text is Vietnamese, copied exactly as written in the
prompt (no English, no translation, no rewording). Say "nhóm", never "gia đình" as the generic word.
Do not print these banned words (instructions, not copy): "real-time", "live", "giám sát", "theo dõi liên tục",
"tracking". Prefer "Hành trình", "Nhật ký", "Điểm đến", "Chia sẻ tự nguyện".
Rules: text on Terracotta fills is dark #1A2533 (never white); links / small accent text #AE4C28; input borders #7F8B9C; error text #C21F2F;
touch targets >= 48px. Use realistic Vietnamese sample data (Mẹ, Bố, Bé Na, Ông ngoại, Lan, Mai; groups "Nhà Nguyễn", "Hội bạn thân").
```

---

## Prompt 0 — Hệ thiết kế (Khối A + Khối B + prompt này)

```
Create a style-guide screen for "Happy Share" using EXACTLY the "Warm Indigo & Terracotta" tokens from Block A and
the sharing-state / freshness rules from Block B (do not invent other brand colors). Show, in light AND dark:
1. Color swatches with hex labels: primary, primary container, accent, accent container, background, card,
   subtle section, border, text, secondary text, error, error container, and the dark equivalents.
2. Typography scale in "Be Vietnam Pro" with Vietnamese sample text (headline, title, body, label, caption).
3. Buttons: filled primary (white text on #2B4C7E), tonal (indigo container #DDE7F5 with text #2B4C7E), outlined, text, destructive (#DC3545 with white text),
   and an "accent" button (Terracotta background with DARK text #1A2533 — never white text).
4. Text field: default, focused (primary 2px border), disabled; border color #7F8B9C, radius 12. Also a checkbox with a label and a switch.
5. The four sharing-state chips (icon + text) exactly as specified, each with its optional helper line below:
     Đang chia sẻ — "Đang ghi nhận hành trình"
     Chia sẻ hạn chế — "Dữ liệu có thể gián đoạn"
     Đã tạm dừng — "Người dùng chủ động dừng"
     Chưa chia sẻ — "Chưa bật chia sẻ"
6. The four freshness chips exactly as specified.
7. Avatar with initials, list row (member), card (radius 16, 1px #DDE2E8 border), bottom sheet, dialog,
   bottom navigation bar (5 tabs: Nhóm, Hành trình, Địa điểm, Thành viên, Cài đặt; selected tab uses the indigo container as indicator).
Mood: warm, friendly, natural — like a calm personal notebook, not a corporate dashboard.
```

---

## Prompt 1 — Đăng nhập (Khối A + prompt này)

```
Screen: Login (Đăng nhập). Light theme. No OTP anywhere.
Layout, top to bottom, vertically centered with generous whitespace on the background #F8F9FB:
- A small friendly logo mark (a simple rounded house/heart shape in Warm Indigo #2B4C7E with a Terracotta #D96B43 accent),
  the app name "Happy Share" and the tagline "Ghi lại hành trình của bạn, gần nhau hơn mỗi ngày".
  Keep it a clean vector/flat mark — no stock photos, no map, no pins, no people photos.
- Text field, label "Tên tài khoản, email hoặc số điện thoại", placeholder "vd: mai.tran, mai@email.com, 0912345678".
  ONE single field (the user may type any of the three). White fill, 1px #7F8B9C border, radius 12.
- Password field, label "Mật khẩu", with a show/hide eye toggle. Same style.
- Filled primary button, full width, height 52: "Đăng nhập" (#2B4C7E background, white text).
- Centered text row: "Chưa có tài khoản?" in secondary text #556578 + bold link "Đăng ký" in Terracotta #AE4C28.
- Do NOT include "Quên mật khẩu", social login, phone-OTP, or any language switcher.
```

Luồng: nhấn "Đăng ký" → Màn 2. Đăng nhập xong → tự điều hướng (Màn 7 nếu chưa bật ghi lại hành trình, ngược lại vào ứng dụng). Không có màn nối tiếp.

Nối tiếp (tuỳ chọn): trạng thái mật khẩu đang hiện.

```
Nối tiếp 1a — Duplicate this screen with the password visible (eye icon in "hide" state) and sample text typed in
both fields: "mai.tran" and "matkhau123". Nothing else changes.
```

## Prompt 2 — Đăng ký (Khối A + prompt này)

```
[Khối A]

Screen: Register (Đăng ký). No verification code step.
- Top app bar with back arrow, title "Tạo tài khoản".
- Field "Tên hiển thị", placeholder "vd: Mẹ" (helper: "Tên người thân và bạn bè sẽ thấy trong nhóm").
- Field "Tên tài khoản, email hoặc số điện thoại" (single field), helper "Bạn có thể dùng tên tài khoản, email hoặc số điện thoại. Không cần mã xác thực."
- Field "Mật khẩu" with eye toggle and helper "Ít nhất 8 ký tự".
- Filled primary full-width button "Tạo tài khoản".
- Small legal line: "Bằng việc tiếp tục, bạn đồng ý với Điều khoản sử dụng và Chính sách quyền riêng tư." (the two names are links)
- Row: "Đã có tài khoản?" + link "Đăng nhập".
```

Luồng: mũi tên quay lại hoặc "Đăng nhập" → Màn 1. Tạo tài khoản xong → Màn 7 (tài khoản mới chưa bật ghi lại hành trình; không bắt tạo nhóm trước). Không có màn nối tiếp.

## Prompt 3 — Tab Nhóm khi chưa có nhóm (Khối A + prompt này)

```
[Khối A]

Screen: the "Nhóm" tab (first of 5 bottom-nav tabs: Nhóm [selected], Hành trình, Địa điểm, Thành viên, Cài đặt) when the
user does not belong to any group yet. The bottom navigation bar is visible. Groups are optional, so this is a friendly
invitation, not a blocker.
- App bar title "Nhóm".
- Warm illustration of two or three friendly figures around a house/heart (flat vector, no photos, no map).
- Heading: "Hành trình của bạn vẫn được ghi lại cho riêng bạn".
- Body: "Tạo hoặc tham gia một nhóm để cùng xem hành trình của nhau — gia đình, bạn bè hay người thân."
- Two large selectable cards (full width, icon left, chevron right):
  1) icon "group+": title "Tạo nhóm mới", subtitle "Bạn sẽ là chủ nhóm và mời mọi người bằng mã hoặc mã QR."
  2) icon "key/qr": title "Tham gia bằng mã mời", subtitle "Nhập mã 8 ký tự hoặc quét mã QR từ người đã mời bạn."
- Footnote: "Bạn có thể ở tối đa 5 nhóm. Vào nhóm nghĩa là chia sẻ hành trình của bạn với nhóm đó từ lúc này trở đi."
```

Luồng: thẻ 1 → Màn 4; thẻ 2 → Màn 5. Cùng màn này (hoặc bộ chọn nhóm ở Màn 6) cũng được mở khi người dùng đã ở nhóm khác và muốn thêm nhóm. Không có "Đăng xuất" ở đây (nằm trong Cài đặt). Không có màn nối tiếp.

## Prompt 4 — Tạo nhóm (Khối A + prompt này)

```
[Khối A]

Screen: Create group.
- App bar with back arrow, title "Tạo nhóm".
- Field "Tên nhóm", placeholder "vd: Nhà Nguyễn, Hội bạn thân".
- Info card: "Gói Beta · tối đa 10 thành viên · xem lịch sử 30 ngày · 20 địa điểm".
- Info line with shield icon: "Bạn là chủ nhóm: mời và quản lý thành viên. Chủ nhóm không thể bật ghi lại hay chia sẻ hành trình thay người khác."
- A consent card (soft indigo container #DDE7F5) titled "Chia sẻ với nhóm này", text: "Khi tạo nhóm, các thành viên sẽ xem được hành trình của bạn từ lúc này trở đi — không xem được những gì bạn đã ghi trước đó. Mọi nhóm bạn tham gia thấy cùng hành trình của bạn. Bạn rời nhóm bất cứ lúc nào để ngừng chia sẻ."
- Checkbox below the card: "Tôi hiểu và đồng ý chia sẻ hành trình với nhóm này" (unchecked; the primary button is disabled until checked).
- Filled primary button "Tạo nhóm".
```

Nối tiếp (gửi sau khi có màn chính):

```
Nối tiếp 4a — Duplicate this screen with the group name "Hội bạn thân" typed, the consent checkbox checked, and the
primary button enabled.
```

```
Nối tiếp 4b — SUCCESS screen after creating the group (no back arrow): a big check illustration, title "Đã tạo Hội bạn thân!",
subtitle "Mời mọi người tham gia để cùng xem hành trình của nhau.", buttons "Mời thành viên" (filled primary) and "Để sau" (text button).
```

Luồng: "Mời thành viên" → bottom sheet mời (Prompt 6, nối tiếp 6b) rồi vào tab Thành viên của nhóm vừa tạo; "Để sau" → tab Thành viên của nhóm vừa tạo. (Múi giờ không còn nằm ở đây: đặt trong Cài đặt → Màn 8.)

## Prompt 5 — Tham gia bằng mã, kèm quét QR (Khối A + prompt này)

```
[Khối A]

Screen A: Join group by code.
- App bar with back arrow, title "Tham gia nhóm".
- Instruction: "Nhập mã mời gồm 8 ký tự do chủ nhóm gửi cho bạn."
- Code input as 8 individual boxes (it is a short invite code, NOT an OTP). Letters auto-uppercase.
  Example filled state: K 7 M 2 Q 9 X A. Helper: "Mã gồm chữ và số, không có O, I, L, U, 0, 1."
- Consent card (soft indigo container #DDE7F5) titled "Chia sẻ với nhóm này", text: "Khi tham gia, các thành viên sẽ xem được hành trình của bạn từ lúc này trở đi — không xem được những gì bạn đã ghi trước đó. Mọi nhóm bạn tham gia thấy cùng hành trình của bạn. Bạn rời nhóm bất cứ lúc nào để ngừng chia sẻ."
- Checkbox: "Tôi hiểu và đồng ý chia sẻ hành trình với nhóm này" (the "Tham gia" button is disabled until checked).
- Filled primary button "Tham gia".
- Divider "hoặc", then outlined button with QR icon "Quét mã QR".
```

Nối tiếp:

```
Nối tiếp 5a — New screen B: QR scanner. Full-screen camera viewfinder with a rounded square frame and a dimmed
surround, hint "Đưa mã QR vào khung", a close button, and a flashlight toggle.
```

```
Nối tiếp 5b — Duplicate Screen A with the code boxes empty, the checkbox unchecked and the "Tham gia" button disabled
(the empty starting state, cursor in the first box).
```

```
Nối tiếp 5c — SUCCESS screen after joining (no back arrow): "Chào mừng bạn đến với Nhà Nguyễn!", a row of member avatars
(Mẹ, Bố, Bé Na), and a filled primary button "Tiếp tục".
```

Luồng: "Quét mã QR" → 5a; quét được mã → điền 8 ô (người dùng vẫn phải tích đồng ý) rồi bấm "Tham gia" → 5c; "Tiếp tục" → tab Thành viên của nhóm vừa tham gia.

## Prompt 6 — Tab Thành viên, kèm mời và bộ chọn nhóm (Khối A + Khối B + prompt này)

```
[Khối A + Khối B]

Screen: Members tab (one of 5 bottom-nav tabs: Nhóm, Hành trình, Địa điểm, Thành viên [selected], Cài đặt).
- Header: a tappable group switcher showing the current group name "Nhà Nguyễn" with a small chevron-down icon,
  and a chip "Beta · 4/10" next to it. Title "Thành viên" above it.
- List of members (avatar with initial, name, optional nickname in smaller text, role badge "Chủ nhóm"
  for the owner, a "Tôi" tag on my own row, and the sharing-state chip on the right/below):
    Mẹ (Tôi) · Chủ nhóm · Đang chia sẻ
    Bố · Chia sẻ hạn chế
    Bé Na · Đã tạm dừng
    Ông ngoại · Chưa chia sẻ
- A short explanation line under the list: "Mỗi người tự quyết định việc ghi lại và chia sẻ hành trình của mình."
- Owner view: a prominent button "Mời thành viên" (floating or sticky bottom, above the nav bar).
- Each row has an overflow menu icon.
```

Nối tiếp (gửi từng cái một, trên chính màn này):

```
Nối tiếp 6a — Non-owner view of the same screen (I am Bố): no "Mời thành viên" button, no remove action, and a text
button at the bottom "Rời nhóm".
```

```
Nối tiếp 6b — Bottom sheet "Mời thành viên" over the owner view: large grouped code "K7M2 Q9XA", a QR code,
text "Hết hạn sau 48 giờ · dùng được một lần", buttons "Sao chép mã" (outlined) and "Chia sẻ" (filled).
```

```
Nối tiếp 6c — Overflow menu open on MY row (small popup with one item "Đổi biệt danh"), and then a dialog
titled "Đổi biệt danh" with a text field (current value "Mẹ") and actions "Hủy" / "Lưu".
```

```
Nối tiếp 6d — Owner view: overflow menu open on Bố's row with one item "Xóa khỏi nhóm" (destructive color), and then
a confirm dialog: title "Xóa Bố khỏi nhóm?", body "Bố sẽ không còn xem được hành trình của bạn trong nhóm này và bạn cũng không xem được hành trình của Bố qua nhóm này.", actions "Hủy" / "Xóa" (destructive).
```

```
Nối tiếp 6e — Non-owner view: confirm dialog after tapping "Rời nhóm": title "Rời khỏi Nhà Nguyễn?", body "Bạn sẽ không còn xem được nhóm này và các thành viên cũng không xem được hành trình của bạn nữa. Hành trình của riêng bạn vẫn được ghi lại. Muốn tham gia lại, bạn cần mã mời mới và đồng ý chia sẻ lại.", actions "Hủy" / "Rời nhóm".
```

```
Nối tiếp 6f — Empty state when I am the only member (owner view): illustration, "Mới có mình bạn. Mời mọi người để cùng tham gia." with button "Mời thành viên".
```

```
Nối tiếp 6g — Group switcher bottom sheet over the screen, opened by tapping the group name: title "Chọn nhóm", a list of my groups
as selectable rows (name, "4 thành viên", check icon on the selected one): "Nhà Nguyễn" (selected, 4 thành viên) and
"Hội bạn thân" (3 thành viên), then two actions at the bottom: "Tạo nhóm mới" and "Tham gia bằng mã", and a helper line
"Bạn ở 2/5 nhóm."
```

Luồng: tên nhóm → 6g; chọn nhóm khác → danh sách đổi sang nhóm đó; "Tạo nhóm mới" → Màn 4; "Tham gia bằng mã" → Màn 5; "Mời thành viên" → 6b; "Xóa" → quay lại danh sách (thành viên biến mất); "Rời nhóm" → về nhóm còn lại, hoặc Màn 3 nếu không còn nhóm nào.

## Prompt 7 — Giới thiệu ghi lại hành trình (Khối A + prompt này)

```
[Khối A]

Screen: Journey recording introduction / consent — shown right after sign-in to a user who has not turned on
"Ghi lại hành trình" yet. It works without any group. It must feel like an honest, friendly explanation, not a legal wall.
Scrollable, with a sticky bottom action area.
- Title: "Ghi lại hành trình — do bạn quyết định".
- Intro: "Happy Share ghi lại các nơi bạn ghé và giờ đến/rời để tạo nhật ký hành trình trong ngày — trước hết là của riêng bạn."
- 4 sections, each with an icon, a short heading and 1–2 lines:
  1. "Chúng tôi ghi gì" — "Vị trí khi bạn di chuyển hoặc dừng lại, giờ đến/rời và tuyến đường đã ghi nhận."
  2. "Ai xem được" — "Mặc định chỉ mình bạn. Nếu bạn tham gia một nhóm, các thành viên xem được hành trình của bạn từ lúc vào nhóm trở đi. Rời nhóm là ngừng chia sẻ."
  3. "Bạn luôn kiểm soát" — "Tạm dừng hoặc tắt ghi lại trong Cài đặt bất cứ lúc nào, và xóa lịch sử đã ghi. Khi tạm dừng, người trong nhóm vẫn xem được phần trước đó nhưng không thấy vị trí mới."
  4. "Cam kết" — "Không bán dữ liệu, không quảng cáo, không theo dõi bí mật."
- A neutral note card: "Hệ điều hành có thể hạn chế việc ghi vị trí khi máy tiết kiệm pin hoặc tắt máy. Khi thiếu dữ liệu, nhật ký sẽ hiển thị khoảng trống thay vì đoán."
- A line: "Mỗi người tự quyết định cho chính mình. Chủ nhóm không thể bật thay bạn."
- Small footer: "Phiên bản điều khoản 2026-11-v2".
- Sticky bottom: filled primary button "Bắt đầu ghi lại hành trình" and a text button "Để sau".
```

Nối tiếp:

```
Nối tiếp 7a — Step 2 after tapping "Bắt đầu ghi lại hành trình" (new screen, back arrow): a location-permission illustration, title
"Cho phép dùng vị trí", body "Để ghi hành trình khi bạn không mở ứng dụng, Happy Share cần quyền vị trí 'Luôn cho phép'. Bạn có thể từ chối — ứng dụng vẫn dùng được nhưng dữ liệu có thể thiếu."
Buttons "Tiếp tục" (filled primary) and "Không phải bây giờ" (text).
```

Luồng: "Để sau" → vào ứng dụng (chưa ghi lại; bật sau ở Cài đặt → Màn 8); "Bắt đầu ghi lại hành trình" → 7a; "Tiếp tục" → hộp thoại quyền của hệ điều hành → vào ứng dụng; "Không phải bây giờ" → vào ứng dụng.

## Prompt 8 — Cài đặt → Ghi lại hành trình của tôi (Khối A + Khối B + prompt này)

```
[Khối A + Khối B]

Screen: "Ghi lại hành trình của tôi", opened from the Settings tab (bottom nav visible with Cài đặt selected, back arrow in the app bar).
- App bar title "Ghi lại hành trình của tôi".
- Status card: a chip using the "Đang chia sẻ" chip style but with the text "Đang ghi lại" (check-circle icon), title "Hành trình của bạn đang được ghi lại",
  body "Bạn luôn xem được nhật ký của mình, kể cả khi chưa tham gia nhóm nào."
- Two buttons side by side under the card: outlined "Tạm dừng" and text button in destructive color "Tắt ghi lại".
- Section "Nhóm đang xem hành trình của tôi" (card with rows): "Nhà Nguyễn · 4 thành viên · từ 02/11" and "Hội bạn thân · 3 thành viên · từ 07/11",
  each with a chevron. Helper under the list: "Mọi nhóm bạn tham gia thấy cùng một hành trình. Muốn ngừng chia sẻ với một nhóm, hãy rời nhóm đó."
- Section "Dữ liệu của tôi" (card with rows): "Múi giờ" with value "Việt Nam (GMT+7)" and chevron; "Xóa lịch sử hành trình" in destructive color.
- Short note at the bottom: "Bạn chỉ có thể xem lịch sử trong 30 ngày gần nhất, hoặc dài hơn nếu nhóm của bạn dùng gói cao hơn."
```

Nối tiếp (gửi từng cái một, trên chính màn này):

```
Nối tiếp 8a — Same screen when recording is PAUSED: chip "Đã tạm dừng" (pause-circle icon, "Đã tạm dừng" chip style), title "Đã tạm dừng ghi lại",
body "Người trong nhóm vẫn xem được hành trình trước đó của bạn nhưng không thấy vị trí mới. Khoảng thời gian này sẽ hiển thị là khoảng trống trong nhật ký.",
buttons "Tiếp tục ghi lại" (filled primary) and "Tắt ghi lại" (text, destructive). Everything else unchanged.
```

```
Nối tiếp 8b — Same screen when recording is TURNED OFF: chip "Đã tắt" (minus-circle icon, "Chưa chia sẻ" chip style), title "Đã tắt ghi lại hành trình",
body "Không ai trong nhóm xem được dữ liệu vị trí của bạn. Nhật ký đã ghi trước đó vẫn ở trên máy chủ cho tới khi bạn xóa.",
a single filled primary button "Bật lại ghi lại hành trình". Everything else unchanged.
```

```
Nối tiếp 8c — Confirm dialog after tapping "Xóa lịch sử hành trình": title "Xóa toàn bộ lịch sử hành trình?",
body "Tất cả điểm đến và tuyến đường bạn đã ghi sẽ bị xóa vĩnh viễn, kể cả với các nhóm đang xem. Việc ghi lại hành trình không bị tắt.",
actions "Hủy" / "Xóa lịch sử" (destructive).
```

```
Nối tiếp 8d — Confirm dialog after tapping "Tắt ghi lại": title "Tắt ghi lại hành trình?",
body "Ứng dụng sẽ ngừng ghi vị trí và các nhóm của bạn không xem được dữ liệu vị trí của bạn nữa. Bạn có thể bật lại bất cứ lúc nào.",
actions "Hủy" / "Tắt ghi lại" (destructive).
```

```
Nối tiếp 8e — Bottom sheet "Chọn múi giờ" over the screen listing "Việt Nam (GMT+7)" (selected, check icon), "Lào (GMT+7)",
"Campuchia (GMT+7)", "Thái Lan (GMT+7)", "Singapore (GMT+8)", "Nhật Bản (GMT+9)", with the helper "Dùng để chia ngày trong nhật ký hành trình của bạn."
```

Luồng: "Tạm dừng" → 8a; "Tắt ghi lại" → hộp thoại 8d → 8b; "Tiếp tục ghi lại"/"Bật lại" → trạng thái đang ghi lại (nếu đã tắt thì đi lại qua Màn 7 để đồng ý); dòng nhóm → tab Thành viên của nhóm đó; "Múi giờ" → 8e; "Xóa lịch sử hành trình" → 8c.

---

## Ghi chú cho người dựng Flutter (không dán vào Stitch)

| Màn | Dữ liệu / API |
|---|---|
| 1, 2 | `POST /auth/login`, `/auth/register` — một ô `identifier`, server tự nhận dạng |
| 3 | tab Nhóm khi `me.families` rỗng (`AppSessionCubit.state.activeFamily == null`); điều hướng tới `/family-setup/*` |
| 4 | `POST /families` `{name, timezone?, sharing_consent_version}` (repository tự gửi `kCurrentSharingConsentVersion`); lỗi `GROUP_LIMIT`; gói `beta` do server cấp. **Không còn ô múi giờ** (múi giờ là của user, `PATCH /me {timezone}` ở Màn 8) |
| 5 | `POST /families/join` `{code, sharing_consent_version}`; QR payload `happyshare://join?code=...`; `ALREADY_IN_FAMILY` = đã ở nhóm này (mã không bị tiêu thụ) |
| 6 | `GET /families/:id/members` (nhóm đang xem = `activeFamily`), `POST /families/:id/invitations`, `DELETE …/members/:id`, `POST …/leave`, `PATCH …/members/:id {nickname}`; bộ chọn nhóm = `AppSessionCubit.selectFamily()` |
| 7 | điều hướng khi `me.consent.status` là `null`/`revoked`; `POST /locations/consent {consent_version: kCurrentConsentVersion, platform}` (M3) |
| 8 | `GET/POST/PATCH/DELETE /locations/consent` (M3), `PATCH /me {timezone}` (`MeRepository.updateMe`), `DELETE /locations/history` (M3), danh sách nhóm từ `me.families` |

Hiển thị lỗi / đang tải / offline: **chưa quy ước**, sẽ bổ sung prompt và mô tả riêng sau. Trong lúc dựng, widget chỉ cần chừa chỗ cho `SubmitState.error` / `fieldErrors` / `isSubmitting`.

Bốn trạng thái chia sẻ (`sharing_state`): `sharing`, `limited`, `paused`, `not_shared`. Chữ hiển thị phải đúng bảng ở khối ngữ cảnh. Ở Màn 8 trạng thái ghi nhận của chính mình dùng cùng kiểu chip nhưng nhãn "Đang ghi lại" / "Đã tạm dừng" / "Đã tắt" (ánh xạ từ `consent.status` `granted` / `paused` / `revoked`).

### Token đã khớp trong code Flutter
Màu, bo góc, font và 4 trạng thái chia sẻ / 4 chip độ mới đã được đưa vào `lib/core/theme/app_colors.dart` +
`app_theme.dart` (font Be Vietnam Pro đóng gói ở `assets/fonts/`). Một số màu "text & icon" có thể đậm hơn bảng gốc một chút
chỉ để chữ nhỏ đạt tương phản 4.5:1; `test/core/theme_test.dart` kiểm tra từng cặp.
