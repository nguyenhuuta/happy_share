# CLAUDE.md — Happy Share · Mobile (`happy_share`)

Hướng dẫn cho Claude Code khi làm việc trong repo mobile Flutter của Happy Share. **Phần A** là bối cảnh chung, giống hệt trong repo server. **Phần B** là quy ước riêng của repo này.

<!-- ===== PHẦN CHUNG (SHARED) — giữ GIỐNG HỆT giữa mobile/CLAUDE.md và server/CLAUDE.md ===== -->
<!-- Sửa phần chung ở file này thì phải chép y nguyên sang file CLAUDE.md của project kia + tăng SHARED_VERSION. -->

> **SHARED_VERSION: 2.0 (2026-11-09)** — nếu 2 project có SHARED_VERSION khác nhau, phần chung đã lệch: đồng bộ trước khi code tiếp.

# Phần A — Bối cảnh chung Happy Share

## A1. Sản phẩm

**Happy Share** (đổi tên từ "Family Journey", PRD v1.0) là ứng dụng iOS & Android cho phép thành viên gia đình **tự nguyện** chia sẻ vị trí để tự động tạo **nhật ký hành trình trong ngày**: các nơi đã ghé, giờ đến/rời, tuyến đường đã ghi nhận. Định hướng: **History-first • Consent-based • Privacy-first**. Không phải app theo dõi GPS liên tục, không hỗ trợ theo dõi bí mật.

Hệ thống gồm 2 repo cùng cấp trong `T:\Data\Project\`:

| Repo | Vai trò | Stack |
|---|---|---|
| `happy_share` | Mobile | Flutter (Dart) + native Swift (Core Location) / Kotlin (Fused Location, Geofencing) |
| `happy_share_server` | Backend | NestJS (modular monolith) + PostgreSQL 16 + PostGIS 3 (+ Redis khi cần), Docker trên 1 VPS |

**Ranh giới trách nhiệm**: server quyết định mọi nghiệp vụ (quyền xem, consent, giới hạn gói, lọc nhiễu, phát hiện Visit, Gap, freshness, khớp Place). Mobile thu thập, xếp hàng offline, đồng bộ, hiển thị — **không tự tính lại** các thứ server đã tính.

### Luồng chính
1. Đăng ký/đăng nhập → 2. Mỗi người **tự** đọc giải thích, bật "Ghi lại hành trình của tôi" (Cài đặt), cấp quyền OS → 3. App thu thập nền, lưu SQLite khi offline → 4. Server xử lý Visit → 5. Người dùng xem **timeline của chính mình** theo ngày (không cần thuộc nhóm nào) → 6. Tùy chọn: tạo nhóm (`owner`) và nhận mã mời/QR, hoặc tham gia nhóm bằng mã; vào nhóm là đồng ý chia sẻ hành trình cho các thành viên **từ lúc vào trở đi**, rời nhóm là dừng chia sẻ → 7. Thành viên cùng nhóm xem timeline + bản đồ của nhau theo ngày. Một người có thể ở nhiều nhóm.

### 5 tab
| Tab | Key | Nội dung |
|---|---|---|
| Nhóm | `family` | Chọn nhóm đang xem; bản đồ, trạng thái chia sẻ, vị trí gần nhất + độ mới |
| Hành trình | `journey` | Timeline (visit/travel/gap) + bản đồ theo ngày: của tôi hoặc của thành viên cùng nhóm |
| Địa điểm | `places` | Nhà, Trường, Công ty, tùy chỉnh |
| Thành viên | `members` | Danh sách, trạng thái chia sẻ, mời, xóa |
| Cài đặt | `settings` | Tài khoản, ghi lại hành trình của tôi (bật/tạm dừng/tắt, xóa dữ liệu), nhóm của tôi, quyền riêng tư, gói, xóa tài khoản |

### Phạm vi MVP
**Có**: F01 đăng ký/đăng nhập (tên tài khoản / email / SĐT + mật khẩu, không OTP) • F02 tạo nhóm • F03 mời bằng mã/QR • F04 ghi lại hành trình cá nhân (bật/tạm dừng/tắt) và đồng ý chia sẻ khi vào nhóm • F05 định vị nền native • F06 SQLite queue + batch sync • F07 Visit detection • F08 Timeline (của tôi + của thành viên) • F09 Bản đồ hành trình • F10 Địa điểm • F15 Xóa tài khoản & dữ liệu.
**Không làm**: OTP điện thoại, thông báo đến/rời, báo cáo tuần, thanh toán, chat/mạng xã hội, livestream vị trí, AI, xuất dữ liệu, tự phân loại địa điểm nhạy cảm, quảng cáo.

### Nguyên tắc dữ liệu & UX (bắt buộc cả 2 repo)
- Không khẳng định/hiển thị "theo dõi liên tục", "real-time" — OS không đảm bảo.
- Phân biệt `recorded_at` (thiết bị ghi) và `received_at` (server nhận). Sắp xếp/hiển thị theo `recorded_at`.
- Timeline **đánh dấu khoảng trống**, không nội suy hành trình.
- Không tự gán/nhận diện địa điểm nhạy cảm; người dùng tự đặt tên Place.
- Ưu tiên đúng đến/rời hơn đường đi chính xác từng mét.
- Luôn hiển thị độ mới dữ liệu cạnh vị trí gần nhất.

## A2. Quyết định đã chốt (khác/bổ sung PRD)

| # | Quyết định |
|---|---|
| D01 | Tên sản phẩm **Happy Share**; package Flutter `happy_share`. |
| D02 | MVP đăng ký/đăng nhập bằng **một `identifier`** (tên tài khoản, email hoặc SĐT — người dùng nhập dạng nào cũng được) + mật khẩu. **Không OTP, không xác minh** email/SĐT. OTP điện thoại để sau (cần nhà cung cấp SMS). Xem D13. |
| D03 | Mỗi user thuộc tối đa `MAX_GROUPS_PER_USER` (5) nhóm `active`; vượt → `GROUP_LIMIT`. Mỗi cặp (nhóm, user) chỉ có một bản ghi thành viên. |
| D04 | `devices` thuộc **user**; **dữ liệu vị trí (điểm, Visit, tóm tắt) thuộc user** (`user_id`). `member` chỉ biểu diễn quan hệ user–nhóm (vai trò, biệt danh, `joined_at`). |
| D05 | JSON API dùng **snake_case** cho mọi field; thời gian ISO 8601 UTC có `Z`. |
| D06 | Thời gian sống token: access 15 phút, refresh 30 ngày **xoay vòng**, lưu hash trong bảng `refresh_tokens`. |
| D07 | Người dùng luôn xem được dữ liệu của chính mình. Người khác chỉ xem được khi cùng nhóm `active`, người đó đang ghi nhận (`granted`/`paused`) và dữ liệu nằm sau `shared_from` (xem A6). |
| D08 | Ngày (`date`) được cắt theo `users.timezone` của **người có dữ liệu** (mặc định `Asia/Ho_Chi_Minh`, đổi qua `PATCH /me`). `families.timezone` chỉ còn là giá trị tham khảo, không dùng để cắt ngày. |
| D09 | Visit detection chạy **ở server**, bất đồng bộ sau mỗi batch; tính lại cửa sổ bị ảnh hưởng (idempotent). |
| D10 | Native ghi sự kiện **trực tiếp vào SQLite queue**; Dart `SyncService` gửi batch (foreground, đổi mạng, workmanager định kỳ). |
| D11 | Giai đoạn beta: gia đình mới nhận plan `beta`; chưa thanh toán. |
| D12 | Server dùng TypeORM với **migrations** (`synchronize: false`). |
| D13 | `identifier` là **một cột duy nhất** (unique, không phân biệt hoa thường). Server tự nhận dạng `identifier_type` ∈ `email` · `phone` · `username` và chuẩn hóa trước khi lưu/so khớp: cắt khoảng trắng; có `@` → **email** (hợp lệ theo định dạng email, chữ thường); chỉ gồm chữ số, có thể bắt đầu bằng `+` (9–15 số, bỏ khoảng trắng/`.`/`-`/`()`; đầu `+84`/`84` đổi thành `0`) → **phone**; còn lại → **username** (`^[a-z][a-z0-9_.]{2,29}$`, chữ thường). Mobile chỉ gửi chuỗi người dùng nhập, **không tự chuẩn hóa**. |
| D14 | Chữ hiển thị là **"Nhóm"** (l10n); tên trong code/API giữ `Family`, `/families`, `family_id`. |
| D15 | Ghi lại hành trình bật ở **cấp tài khoản** (Cài đặt), có thể bật khi chưa thuộc nhóm nào. Rời nhóm **không** tắt ghi nhận. |
| D16 | Vào nhóm (tạo hoặc tham gia) là hành động **đồng ý chia sẻ** (kèm `sharing_consent_version`): thành viên cùng nhóm xem được hành trình của bạn **từ lúc vào trở đi**. Rời nhóm = thu hồi chia sẻ với nhóm đó, hiệu lực ngay. Không có công tắc chia sẻ riêng theo nhóm: mọi nhóm của bạn thấy cùng phần dữ liệu. |
| D17 | Địa điểm (Place) thuộc nhóm. Timeline của chính mình khớp tên với Place của mọi nhóm mình đang ở; không ở nhóm nào thì `place = null` (Place cá nhân: sau MVP). |

**Câu hỏi còn mở** (không tự quyết; hỏi chủ dự án): Q1 Google Maps hay Mapbox (tạm dùng Google Maps) • Q2 quy trình tài khoản trẻ em/người giám hộ (MVP: chỉ người tự có tài khoản; cần tư vấn pháp lý) • Q3 bundle id chính thức (hiện `com.happy.share.happy_share`) • Q4 domain/VPS production.

## A3. Thuật ngữ, Enum và Hằng số

> **Bắt buộc**: server (TypeScript enum / Postgres enum) và mobile (Dart enum) phải dùng **đúng các giá trị chuỗi dưới đây**. Thêm/đổi giá trị = sửa phần chung ở **cả 2** CLAUDE.md + tăng SHARED_VERSION.
> Mobile phải xử lý giá trị enum lạ (không biết) bằng một nhánh `unknown` an toàn, không crash.

### A3.1 Thuật ngữ

| Thuật ngữ | Code name | Định nghĩa |
|---|---|---|
| Người dùng | `User` | Một tài khoản đăng nhập. |
| Nhóm | `Family` | Nhóm riêng tư (hiển thị "Nhóm"; code/API giữ `Family`). Mỗi user ở tối đa `MAX_GROUPS_PER_USER` nhóm `active` (D03). |
| Thành viên | `FamilyMember` / `member` | Liên kết user ↔ nhóm (vai trò, biệt danh, `joined_at`). Dữ liệu vị trí gắn với **user** (D04), không gắn với member. |
| Chủ nhóm | `owner` | Người tạo gia đình. Quản lý mời/xóa thành viên, địa điểm. **Không** có quyền bật chia sẻ thay người khác. |
| Lời mời | `FamilyInvitation` | Mã 8 ký tự (kèm QR), dùng 1 lần, hết hạn sau 48 giờ. |
| Ghi nhận hành trình | `LocationConsent` | Lịch sử bật/tạm dừng/tắt ghi nhận của **một user** (cấp tài khoản, không phụ thuộc nhóm). Trạng thái hiện tại = bản ghi mới nhất. Đồng ý **chia sẻ** với nhóm là hành động vào nhóm (D16). |
| Thiết bị | `Device` | Một bản cài app trên một điện thoại, thuộc một user. Có `device_id` (UUID do server cấp khi đăng ký). |
| Sự kiện vị trí | `LocationEvent` | Một mẫu vị trí do thiết bị ghi nhận, có `event_id` (UUID do thiết bị sinh) — dùng cho idempotency. |
| Điểm vị trí | `LocationPoint` | Sự kiện đã được server chấp nhận và lưu. |
| Điểm dừng | `Visit` | Khoảng thời gian user ở yên trong bán kính nhỏ, có `arrival_time`, `departure_time`, `confidence`. |
| Địa điểm | `Place` | Vị trí có tên do nhóm tạo (Nhà, Trường…) với bán kính. Visit được khớp vào Place nếu nằm trong bán kính. |
| Di chuyển | `Travel` | Đoạn giữa hai Visit, có polyline các điểm đã ghi nhận. |
| Khoảng trống | `Gap` | Khoảng thời gian không có dữ liệu ≥ `GAP_THRESHOLD_MINUTES`. **Không nội suy**. |
| Timeline | `Timeline` | Danh sách có thứ tự (theo `recorded_at`) các item `visit` / `travel` / `gap` của 1 user trong 1 ngày. |
| Mốc chia sẻ | `shared_from` | Thời điểm sớm nhất mà dữ liệu của một user được người khác (cùng nhóm) xem; xem A6. |
| Độ mới | `freshness` | Mức độ mới của vị trí gần nhất — do server tính. |
| Ngày | `date` | `YYYY-MM-DD` theo `users.timezone` của người có dữ liệu (mặc định `Asia/Ho_Chi_Minh`). |
| `recorded_at` | | Thời điểm thiết bị ghi nhận (UTC). Dùng để sắp xếp/hiển thị. |
| `received_at` | | Thời điểm server nhận (UTC). Dùng để giám sát độ trễ đồng bộ. |

### A3.2 Enum

#### `member_role`
| Giá trị | Ý nghĩa |
|---|---|
| `owner` | Người tạo/quản lý gia đình (đúng 1 người) |
| `member` | Thành viên thường |

#### `member_status`
| Giá trị | Ý nghĩa |
|---|---|
| `active` | Đang trong gia đình |
| `left` | Tự rời — mất quyền xem lịch sử nhóm ngay lập tức |
| `removed` | Bị owner xóa — mất quyền xem ngay lập tức |

#### `consent_status` (trạng thái **ghi nhận hành trình của một user**, D15)
| Giá trị | Thu thập | Chính mình xem | Người khác (cùng nhóm, sau `shared_from`) xem |
|---|---|---|---|
| `granted` | Có | Toàn bộ | Vị trí gần nhất + lịch sử |
| `paused` | Dừng; server **từ chối** điểm có `recorded_at` trong lúc paused | Toàn bộ; khoảng tạm dừng là gap `sharing_paused` | Lịch sử **trước** khi tạm dừng; vị trí gần nhất hiển thị trạng thái "Đã tạm dừng" (không trả tọa độ) |
| `revoked` | Dừng; mobile xóa queue cục bộ | Lịch sử đã ghi (xóa được bằng `DELETE /locations/history`) | **Không** xem được bất kỳ dữ liệu vị trí nào cho đến khi `granted` lại |

User chưa từng bật: không có bản ghi consent → `sharing_state = not_shared`. Trạng thái này **không phụ thuộc nhóm**: rời/bị xóa khỏi nhóm không làm đổi nó.

#### `sharing_state` (server tính, trả trong API members/latest)
| Giá trị | Điều kiện |
|---|---|
| `sharing` | ghi nhận `granted` và thiết bị có quyền `always` |
| `limited` | ghi nhận `granted` nhưng quyền OS không phải `always` hoặc thiết bị báo dừng nền (dữ liệu có thể thiếu) |
| `paused` | ghi nhận `paused` |
| `not_shared` | chưa từng bật hoặc `revoked` |

#### `identifier_type` (server tự nhận dạng, xem D13)
`email` · `phone` · `username`

#### `platform`
`ios` · `android`

#### `os_permission` (quyền định vị OS do thiết bị báo)
| Giá trị | iOS | Android |
|---|---|---|
| `always` | Always | Fine/Coarse + ACCESS_BACKGROUND_LOCATION |
| `while_in_use` | When In Use | Fine/Coarse, không background |
| `denied` | Denied | Denied |
| `restricted` | Restricted (parental control) | — |
| `not_determined` | Not Determined | Chưa hỏi |

Kèm cờ boolean `precise` (iOS Precise Location / Android FINE vs COARSE).

#### `location_source`
| Giá trị | Nguồn |
|---|---|
| `gps` | Mẫu định vị thường (iOS standard updates) |
| `fused` | Android Fused Location Provider |
| `network` | Định vị mạng/độ chính xác thấp |
| `significant_change` | iOS Significant Location Change |
| `visit_arrival` | iOS CLVisit — thời điểm đến |
| `visit_departure` | iOS CLVisit — thời điểm rời |
| `geofence_enter` | Vào vùng (iOS region / Android geofence) |
| `geofence_exit` | Ra khỏi vùng |

#### `activity_type` (tùy chọn)
`still` · `walking` · `running` · `cycling` · `in_vehicle` · `unknown`

#### `visit_status`
| Giá trị | Ý nghĩa |
|---|---|
| `open` | Đang ở đó (chưa phát hiện rời đi). `departure_time = null` |
| `closed` | Đã rời |

#### `place_category`
`home` · `school` · `work` · `other`

#### `freshness` (server tính theo `now - last_recorded_at`)
| Giá trị | Ngưỡng |
|---|---|
| `fresh` | ≤ 15 phút |
| `recent` | ≤ 2 giờ |
| `stale` | > 2 giờ |
| `none` | Chưa có dữ liệu |

#### `timeline_item_type`
`visit` · `travel` · `gap`

#### `gap_reason`
| Giá trị | Ý nghĩa |
|---|---|
| `no_data` | Không nhận được dữ liệu (OS hạn chế, tắt máy, mất quyền…) — **không phỏng đoán nguyên nhân** |
| `sharing_paused` | Người dùng đang tạm dừng ghi nhận trong khoảng này |

#### `subscription_plan`
`free` · `basic` · `premium` · `beta`

#### `subscription_status`
`active` · `expired` · `canceled`

#### `audit_action`
`auth.login` · `auth.login_failed` · `auth.logout` · `user.deleted` · `family.created` · `family.invitation_created` · `family.joined` · `family.left` · `family.member_removed` · `consent.granted` · `consent.paused` · `consent.resumed` · `consent.revoked` · `location.history_viewed` · `place.created` · `place.updated` · `place.deleted` · `location.history_deleted`

### A3.3 Hằng số nghiệp vụ

Server đặt trong `src/common/constants/domain.constants.ts`; mobile mirror những gì cần trong `lib/core/constants/domain_constants.dart`. Tham số thuật toán có thể override qua env server (`VISIT_RADIUS_M`…) để thử nghiệm.

| Hằng số | Giá trị | Dùng ở |
|---|---|---|
| `DEFAULT_TIMEZONE` | `Asia/Ho_Chi_Minh` | Server |
| `CURRENT_CONSENT_VERSION` | `2026-11-v2` | Cả hai (ghi nhận hành trình cá nhân; mobile gửi lên khi bật) |
| `CURRENT_SHARING_CONSENT_VERSION` | `2026-11-g1` | Cả hai (đồng ý chia sẻ khi tạo/tham gia nhóm) |
| `MAX_GROUPS_PER_USER` | 5 | Server (mobile hiển thị) |
| `PERSONAL_HISTORY_DAYS` | 30 | Server — lịch sử xem được của chính mình |
| `ACCESS_TOKEN_TTL` | 15 phút | Server |
| `REFRESH_TOKEN_TTL` | 30 ngày, xoay vòng mỗi lần refresh | Server |
| `INVITE_CODE_LENGTH` | 8 (Crockford Base32, không có 0/O/1/I/L/U) | Cả hai (validate input) |
| `INVITE_TTL_HOURS` | 48 | Server |
| `BATCH_MAX_EVENTS` | 500 | Cả hai |
| `EVENT_MAX_AGE_DAYS` | 7 (cũ hơn → reject `too_old`) | Cả hai (mobile dọn queue) |
| `FUTURE_TOLERANCE_SECONDS` | 300 | Server |
| `ACCURACY_REJECT_M` | > 2000 hoặc ≤ 0 → reject | Server |
| `ACCURACY_FOR_VISIT_M` | ≤ 150 mới dùng cho visit detection | Server |
| `ACCURACY_FOR_ROUTE_M` | ≤ 100 mới đưa vào polyline | Server |
| `MAX_PLAUSIBLE_SPEED_MPS` | 70 (≈250 km/h) — vượt → coi là điểm nhảy | Server |
| `VISIT_RADIUS_M` | 120 (thử nghiệm 100–150) | Server |
| `VISIT_MIN_DURATION_MIN` | 5 (thử nghiệm 5–10) | Server |
| `VISIT_MIN_POINTS` | 2 (hoặc 1 sự kiện `visit_arrival`) | Server |
| `DEPARTURE_CONFIRM_POINTS` | 2 điểm liên tiếp ngoài `VISIT_RADIUS_M × 1.5` | Server |
| `GAP_THRESHOLD_MINUTES` | 30 (ngoài Visit đang mở) | Server |
| `VISIT_GAP_MAX_HOURS` | 12 — Visit mở không có điểm mới quá lâu thì đóng tại điểm cuối + tạo gap | Server |
| `MOVE_START_DISTANCE_M` | 200 (thử nghiệm 150–300) | Mobile native |
| `MOVING_SAMPLE_INTERVAL_S` | 60 (thử nghiệm 30–120) | Mobile native |
| `DESIRED_ACCURACY_M` | 50–100 (mục tiêu, không cam kết) | Mobile native |
| `FRESHNESS_FRESH_MIN` / `FRESHNESS_RECENT_MIN` | 15 / 120 | Server |
| `QUEUE_MAX_ROWS` | 20.000 (vượt → xóa bản ghi cũ nhất) | Mobile |
| `SYNC_MAX_ATTEMPTS` | 20, backoff mũ 30s → tối đa 1 giờ | Mobile |

#### Giới hạn gói (server kiểm tra)

| Plan | Thành viên | Ngày lịch sử xem được | Địa điểm |
|---|---|---|---|
| `free` | 3 | 1 (hôm nay + hôm qua) | 3 |
| `basic` | 5 | 30 | 10 |
| `premium` | 10 | 90 | không giới hạn |
| `beta` | 10 | 30 | 20 |

Nhóm mới tạo trong giai đoạn beta nhận plan `beta` (A2 D11). Giới hạn trên áp cho từng nhóm. Lịch sử của **chính mình**: `PERSONAL_HISTORY_DAYS` hoặc cửa sổ rộng nhất trong các nhóm user đang ở (lấy giá trị lớn hơn). Lịch sử của **người khác**: cửa sổ của gói rộng nhất trong các nhóm chung, **và** giới hạn bởi `shared_from` (A6).

## A4. Hợp đồng API (API Contract v1)

Base URL: `{host}/api/v1`. Auth: `Authorization: Bearer <access_token>` cho mọi endpoint trừ `auth/register|login|refresh` và `health`. Content-Type JSON UTF-8.

### Envelope phản hồi (mọi endpoint)
```json
// Thành công
{ "success": true, "data": { ... }, "error": null }
// Lỗi
{ "success": false, "data": null,
  "error": { "code": "CONSENT_REVOKED", "message": "Thông điệp đọc được", "details": { } } }
```
- Mobile phân nhánh theo `error.code`, **không** theo `message`. `details` của `VALIDATION_ERROR` = `{ "fields": { "<field>": ["<rule>"] } }`.
- Danh sách có phân trang: `data = { "items": [...], "next_cursor": "string|null" }`, query `?limit=` (mặc định 50, tối đa 200) & `?cursor=`.
- ID là UUID (string). Tọa độ: `latitude`, `longitude` (number, WGS84). Khoảng cách mét, thời lượng giây.

### Mã lỗi
| code | HTTP | Khi nào |
|---|---|---|
| `VALIDATION_ERROR` | 400 | Body/query sai |
| `BATCH_TOO_LARGE` | 400 | > `BATCH_MAX_EVENTS` |
| `UNAUTHENTICATED` | 401 | Thiếu/sai token |
| `TOKEN_EXPIRED` | 401 | Access token hết hạn → mobile gọi refresh rồi thử lại 1 lần |
| `REFRESH_TOKEN_INVALID` | 401 | Refresh sai/đã dùng/hết hạn → mobile đăng xuất |
| `INVALID_CREDENTIALS` | 401 | Sai identifier/mật khẩu |
| `FORBIDDEN` | 403 | Không có quyền |
| `NOT_FAMILY_MEMBER` | 403 | Không thuộc nhóm đó / đã rời / không có quyền xem người đó |
| `CONSENT_REQUIRED` | 403 | Gửi vị trí khi chưa từng bật ghi nhận |
| `CONSENT_REVOKED` | 403 | Đã tắt ghi nhận → mobile dừng thu thập + xóa queue |
| `DEVICE_NOT_REGISTERED` | 403 | `device_id` không thuộc user |
| `NOT_FOUND` | 404 | |
| `IDENTIFIER_TAKEN` | 409 | Identifier (đã chuẩn hóa) đã được dùng |
| `ALREADY_IN_FAMILY` | 409 | Đã là thành viên `active` của nhóm này (mã mời không bị tiêu thụ) |
| `INVITE_INVALID` | 409 | Mã sai hoặc đã dùng |
| `INVITE_EXPIRED` | 409 | |
| `OWNER_CANNOT_LEAVE` | 409 | Owner rời khi còn thành viên khác |
| `GROUP_LIMIT` | 422 | Đã ở đủ `MAX_GROUPS_PER_USER` nhóm |
| `PLAN_LIMIT_MEMBERS` | 422 | Vượt số thành viên của gói |
| `PLAN_LIMIT_PLACES` | 422 | Vượt số địa điểm |
| `HISTORY_OUT_OF_PLAN` | 422 | Ngày xem vượt cửa sổ lịch sử của gói |
| `RATE_LIMITED` | 429 | |
| `INTERNAL_ERROR` | 500 | |

### Giới hạn dữ liệu đầu vào (server kiểm tra; mobile validate trước để tránh `VALIDATION_ERROR`)
| Trường | Giới hạn |
|---|---|
| `identifier` | ≤ 254 ký tự (sau chuẩn hóa D13 phải hợp lệ) |
| `password` | 8–72 ký tự |
| `display_name`, `nickname`, tên gia đình (`name`), tên địa điểm (`name`) | không rỗng, ≤ 100 ký tự |
| `radius_meters` (Place) | số nguyên 50–500, mặc định 150 |
| mã mời `code` | 8 ký tự; server chấp nhận chữ thường, khoảng trắng và dấu `-` (tự chuẩn hóa) |
| `device_model` / `app_version`, `os_version` / `push_token` | ≤ 100 / ≤ 50 / ≤ 4096 ký tự |
| `events` của batch | ≤ `BATCH_MAX_EVENTS`; thân request ≤ 2 MB |

### Object dùng chung
```jsonc
// User
{ "id": "uuid", "identifier": "a@b.com", "identifier_type": "email", "display_name": "Mẹ", "avatar_url": null, "timezone": "Asia/Ho_Chi_Minh", "created_at": "2026-11-09T02:00:00Z" }
// Member
{ "member_id": "uuid", "user_id": "uuid", "display_name": "Mẹ", "nickname": "Mẹ", "avatar_url": null,
  "role": "owner", "status": "active", "joined_at": "...",
  "sharing_state": "sharing", "is_me": true }
// Family
{ "id": "uuid", "name": "Nhà Nguyễn", "timezone": "Asia/Ho_Chi_Minh", "owner_user_id": "uuid",
  "plan": "beta", "member_count": 3, "created_at": "..." }
// Place
{ "id": "uuid", "name": "Nhà", "category": "home", "latitude": 21.0285, "longitude": 105.8542,
  "radius_meters": 150, "created_at": "...", "updated_at": "..." }
// Visit
{ "id": "uuid", "user_id": "uuid", "arrival_time": "...", "departure_time": null,
  "duration_seconds": 1800, "latitude": 21.0, "longitude": 105.8, "confidence": 0.82,
  "status": "open", "place": { "id": "uuid", "name": "Nhà", "category": "home" } }   // place có thể null
```

### Endpoints

**Auth**
| Method | Path | Body → data |
|---|---|---|
| POST | `/auth/register` | `{identifier, password(8–72), display_name}` → `{user, tokens}` |
| POST | `/auth/login` | `{identifier, password}` → `{user, tokens}` |
| POST | `/auth/refresh` | `{refresh_token}` → `{tokens}` (refresh cũ bị vô hiệu) |
| POST | `/auth/logout` | `{refresh_token}` → `{}` |

`tokens = { "access_token": "...", "refresh_token": "...", "access_expires_at": "...", "refresh_expires_at": "..." }`

**Me**
| Method | Path | Mô tả |
|---|---|---|
| GET | `/me` | `{user, families: [{family, member}], consent: {status, consent_version, updated_at}}` — `families` rỗng nếu chưa thuộc nhóm nào; `consent` luôn là object (`status` = null nếu chưa bật). App gọi khi mở để quyết định điều hướng |
| PATCH | `/me` | `{display_name?, avatar_url?, timezone?}` → `{user}` (`timezone` là tên IANA hợp lệ) |
| DELETE | `/me` | `{password}` → `{}`. Xóa tài khoản + toàn bộ dữ liệu vị trí (xem A6). Mỗi nhóm mà user là owner: còn thành viên khác → quyền owner chuyển cho thành viên tham gia sớm nhất; không còn ai → xóa nhóm |

**Families & members**
| Method | Path | Mô tả |
|---|---|---|
| POST | `/families` | `{name, timezone?, sharing_consent_version}` → `{family, member}`. Lỗi `GROUP_LIMIT`; `VALIDATION_ERROR` nếu phiên bản ≠ `CURRENT_SHARING_CONSENT_VERSION` |
| GET | `/families/:id` | → `{family}` |
| PATCH | `/families/:id` | owner: `{name?, timezone?}` → `{family}` |
| POST | `/families/:id/invitations` | owner → `{code: "K7M2Q9XA", expires_at, qr_payload: "happyshare://join?code=K7M2Q9XA"}` |
| POST | `/families/join` | `{code, sharing_consent_version}` → `{family, member}`. Lỗi `INVITE_INVALID`, `INVITE_EXPIRED`, `ALREADY_IN_FAMILY`, `GROUP_LIMIT`, `PLAN_LIMIT_MEMBERS` |
| GET | `/families/:id/members` | → `{items: Member[]}` |
| PATCH | `/families/:id/members/:memberId` | chính mình: `{nickname}` → `{member}` |
| DELETE | `/families/:id/members/:memberId` | owner xóa người khác → `{}` (status `removed`) |
| POST | `/families/:id/leave` | → `{}` (status `left`; mất quyền xem nhóm đó ngay, **không** đổi trạng thái ghi nhận cá nhân). Owner còn người khác → `OWNER_CANNOT_LEAVE` |

**Ghi nhận hành trình / Consent** (luôn là của chính người gọi; không ai bật thay người khác; **không cần thuộc nhóm nào**)
| Method | Path | Mô tả |
|---|---|---|
| GET | `/locations/consent` | → `{status\|null, consent_version, updated_at}` |
| POST | `/locations/consent` | `{consent_version, platform}` → đặt `granted` (cả khi đang paused/revoked) |
| PATCH | `/locations/consent` | `{status: "paused"\|"granted"}` → tạm dừng/tiếp tục |
| DELETE | `/locations/consent` | → `revoked`, hiệu lực ngay |
| DELETE | `/locations/history` | → `{}`. Xóa toàn bộ điểm vị trí, Visit, tóm tắt của chính mình (audit `location.history_deleted`) |

**Devices**
| Method | Path | Mô tả |
|---|---|---|
| POST | `/devices` | `{platform, app_version, os_version, device_model, push_token?, os_permission, precise}` → `{device_id}`. Gọi sau đăng nhập; lưu `device_id` cục bộ |
| PATCH | `/devices/:id` | `{app_version?, push_token?, os_permission?, precise?, background_enabled?}` — gọi mỗi khi quyền OS thay đổi và lúc mở app |
| DELETE | `/devices/:id` | khi đăng xuất |

**Locations**
| Method | Path | Mô tả |
|---|---|---|
| POST | `/locations/batch` | Gửi sự kiện (dưới) |
| GET | `/locations/latest?family_id=` | `family_id` bắt buộc → `{items: [{member_id, user_id, sharing_state, freshness, last_recorded_at (hoặc null), latitude (hoặc null), longitude (hoặc null), accuracy (hoặc null), current_visit: Visit (hoặc null)}]}` cho thành viên nhóm đó (áp quy tắc xem A6) — tọa độ `null` khi `paused`/`not_shared` hoặc dữ liệu nằm trước `shared_from` |

Request `POST /locations/batch`:
```json
{
  "device_id": "uuid",
  "events": [{
    "event_id": "uuid-v4-do-thiet-bi-sinh",
    "recorded_at": "2026-11-09T07:30:00Z",
    "latitude": 21.0285, "longitude": 105.8542,
    "accuracy": 25, "speed": 2.5, "altitude": 12.0, "heading": 90,
    "source": "fused", "activity": "walking", "battery_level": 0.64, "is_mock": false
  }]
}
```
Bắt buộc: `event_id, recorded_at, latitude, longitude, accuracy, source`. Còn lại tùy chọn/null.
Response:
```json
{ "success": true, "data": {
    "accepted": 48, "duplicates": 2,
    "rejected": [{ "event_id": "uuid", "reason": "too_old" }],
    "server_time": "2026-11-09T07:31:02Z" }, "error": null }
```
`reason` ∈ `invalid_coordinates | invalid_accuracy | too_old | future_timestamp | consent_not_granted | mock_location`.
Mobile **xóa khỏi queue** mọi event accepted + duplicates + rejected (rejected là vĩnh viễn, không retry). Lỗi mạng/5xx/429 → giữ queue, retry backoff. 403 `CONSENT_REVOKED` → dừng thu thập + xóa queue.

**Journeys / Visits / Summaries** (`date=YYYY-MM-DD` theo `timezone` của người có dữ liệu; `me` = của chính mình, `:userId` = người khác cùng nhóm)
| Method | Path | data |
|---|---|---|
| GET | `/journeys/me?date=` · `/journeys/:userId?date=` | Timeline (dưới) |
| GET | `/visits/me?date=` · `/visits/:userId?date=` | `{items: Visit[]}` |
| GET | `/summaries/me?date=` · `/summaries/:userId?date=` | `{summary_date, visit_count, distance_meters, total_stay_seconds, generated_at}` |

Timeline:
```jsonc
{
  "user_id": "uuid", "date": "2026-11-09", "timezone": "Asia/Ho_Chi_Minh",
  "sharing_state": "sharing", "last_recorded_at": "...", "is_complete": false, "shared_from": null,   // ISO khi xem dữ liệu người khác (mọi item đã cắt tại mốc này)
  "items": [   // sắp theo start_time tăng dần, không chồng lấn
    { "type": "visit",  "start_time": "...", "end_time": "...|null", "visit": { /* Visit */ } },
    { "type": "travel", "start_time": "...", "end_time": "...", "distance_meters": 3200,
      "path": [{ "latitude": 21.0, "longitude": 105.8, "recorded_at": "..." }] },
    { "type": "gap",    "start_time": "...", "end_time": "...", "reason": "no_data" }
  ]
}
```
`is_complete=false` khi ngày là hôm nay hoặc còn có thể nhận dữ liệu muộn.

**Places** (của nhóm; mọi thành viên active xem; owner + người tạo sửa/xóa)
| Method | Path | Mô tả |
|---|---|---|
| GET | `/places?family_id=` | `family_id` bắt buộc → `{items: Place[]}` |
| POST | `/places` | `{family_id, name, category, latitude, longitude, radius_meters (50–500, mặc định 150)}` → `{place}`. Lỗi `PLAN_LIMIT_PLACES` |
| PATCH | `/places/:id` | các field trên (tùy chọn) → `{place}` |
| DELETE | `/places/:id` | → `{}`; visit cũ chuyển `place = null` |

**Health**: `GET /health` → `{status: "ok", version, time}`.

## A5. Quy tắc định vị & xử lý

### Mobile thu thập (native)
- **Không** lấy GPS liên tục mỗi vài giây; **không** dùng timer Dart làm cơ chế nền.
- Đứng yên: dùng sự kiện tiết kiệm pin (iOS Visits + Significant Change + Region quanh điểm hiện tại; Android Geofence quanh điểm hiện tại + Fused độ ưu tiên thấp). Ra khỏi vùng `MOVE_START_DISTANCE_M` → chuyển chế độ di chuyển: lấy mẫu mỗi `MOVING_SAMPLE_INTERVAL_S`. Dừng lâu → quay lại chế độ đứng yên.
- Mỗi sự kiện: sinh `event_id` UUID v4, ghi ngay vào SQLite queue (native ghi trực tiếp; WAL mode), rồi mới tính chuyện gửi.
- Android: xin quyền foreground trước, giải thích rồi mới xin `ACCESS_BACKGROUND_LOCATION`; foreground service type `location` khi đang di chuyển; kiểm thử Doze, Battery Saver, OEM, Force Stop. Phát hiện mock location → `is_mock: true`.
- iOS: `allowsBackgroundLocationUpdates`, `pausesLocationUpdatesAutomatically` phù hợp, Info.plist có mô tả mục đích rõ ràng; kiểm thử khóa màn hình, bị suspend/terminate, khởi động lại, đổi quyền.
- Khi consent ≠ `granted`: dừng mọi theo dõi native. `revoked`: xóa queue.
- Báo quyền OS lên server (`PATCH /devices/:id`) khi thay đổi.

### Server xử lý batch (thứ tự)
1. Xác thực token, `device_id` thuộc user. 2. Trạng thái ghi nhận hiện tại của user (**không cần thuộc nhóm**): chưa từng bật → 403 `CONSENT_REQUIRED`; `revoked` → 403 `CONSENT_REVOKED`. Khi `paused` server **vẫn nhận batch**: từng event được kiểm tra ở bước 3 theo các khoảng `granted`, nên điểm ghi *trước* lúc tạm dừng nhưng đồng bộ muộn vẫn được chấp nhận, còn điểm ghi *trong* lúc tạm dừng bị reject `consent_not_granted`. 3. Validate từng event: tọa độ, `accuracy` (0 < a ≤ 2000), `recorded_at` không > now + 300s, không cũ hơn 7 ngày, `recorded_at` nằm trong khoảng consent `granted`, `is_mock` → reject. 4. Insert `ON CONFLICT (event_id) DO NOTHING` → đếm duplicates. 5. Đánh dấu điểm nhảy (tốc độ suy ra > 70 m/s) `is_outlier = true` (vẫn lưu). 6. Cập nhật `devices.last_sync_at/last_location_at`. 7. Đẩy job tính lại Visit cho **user** từ `min(recorded_at) − 2h`.

### Visit detection (thuần hàm, có unit test)
Đầu vào: điểm hợp lệ của user (không outlier, `accuracy ≤ 150`) sắp theo `recorded_at`.
- Gom cụm: điểm nằm trong `VISIT_RADIUS_M` (120m) quanh tâm cụm hiện tại → thêm vào cụm, cập nhật tâm (trung bình có trọng số theo 1/accuracy).
- Tạo Visit khi cụm kéo dài ≥ `VISIT_MIN_DURATION_MIN` (5 phút) **và** có ≥ 2 điểm — hoặc có sự kiện `visit_arrival`. **Không bao giờ** tạo Visit từ 1 điểm GPS đơn lẻ.
- Rời đi: 2 điểm liên tiếp ngoài `VISIT_RADIUS_M × 1.5`, hoặc `visit_departure`. `departure_time` = điểm cuối trong cụm. Không có điểm rời → Visit `open`.
- Visit mở mà không có điểm mới > 12 giờ → đóng tại điểm cuối, phần sau là gap.
- `confidence` 0–1: tăng theo số điểm, thời lượng, độ chính xác tốt, có `visit_arrival`.
- Khớp Place: tâm Visit cách Place ≤ `radius_meters` → gán Place gần nhất.
- Tính lại theo cửa sổ: xóa visit trong cửa sổ rồi tạo lại → idempotent, xử lý dữ liệu đến muộn.
- Gap: giữa hai điểm liên tiếp cách nhau ≥ 30 phút và không nằm trong Visit → item `gap` (`sharing_paused` nếu khoảng đó consent paused, ngược lại `no_data`).

## A6. Bảo mật & quyền riêng tư (bắt buộc)
- Mọi request đọc dữ liệu vị trí của **người khác**: actor và target phải cùng ít nhất một nhóm `active`, ghi nhận của target là `granted`/`paused` (bảng A3 `consent_status`), dữ liệu nằm sau `shared_from` và ngày nằm trong cửa sổ lịch sử. `shared_from` = nhỏ nhất, trên các nhóm chung, của `max(joined_at của actor, joined_at của target)`. Dữ liệu giao với `shared_from` được **cắt tại mốc** (Visit/travel/gap: `start_time`, `arrival_time`, `duration_seconds` tính lại; `path` bỏ điểm trước mốc); tóm tắt ngày hoàn toàn trước mốc không có dữ liệu. Xem dữ liệu của **chính mình** không cần nhóm và không bị cắt. Một nơi duy nhất quyết định: `AccessPolicy`. UUID khó đoán **không** phải cơ chế phân quyền.
- Owner **không** bật/tắt ghi nhận thay người khác. Rời/bị xóa khỏi nhóm → mất quyền xem nhóm đó ngay; rời nhóm **không** tắt ghi nhận cá nhân. Vào lại nhóm: `joined_at` đặt lại và phải đồng ý chia sẻ lại.
- Thu hồi consent có hiệu lực ngay ở backend.
- **Không ghi tọa độ** vào log, analytics, crash report (cả server lẫn mobile). Log chỉ ghi số lượng, id, mã lỗi.
- Không hardcode secret/API key; server dùng `.env` (commit `.env.example`), mobile dùng `--dart-define-from-file` (file thật không commit).
- Token mobile lưu trong secure storage (Keychain/Keystore), không lưu SharedPreferences.
- HTTPS bắt buộc ngoài môi trường local. Rate limit endpoint auth và join.
- Mã mời: lưu **hash** (SHA-256 + pepper), 1 lần dùng, 48 giờ.
- Audit log cho các hành động trong enum `audit_action`.
- Xóa tài khoản: xóa user, refresh tokens, devices, location_points, visits, daily_summaries, consents của user; mỗi nhóm user là owner: còn thành viên khác → chuyển quyền cho người vào sớm nhất, không còn ai → xóa nhóm; giữ audit log ẩn danh. Backup xóa theo chu kỳ retention công bố. `DELETE /locations/history` xóa dữ liệu hành trình mà không xóa tài khoản.
- Không bán dữ liệu vị trí, không dùng cho quảng cáo. Không giả lập GPS trong production.
- Trước khi phát hành tại Việt Nam: rà soát Luật BVDLCN 91/2025/QH15, Nghị định 356/2025/NĐ-CP (dữ liệu vị trí nhạy cảm, trẻ em, DPIA, chuyển dữ liệu xuyên biên giới).

## A7. Quy tắc làm việc chung cho Claude Code
- Làm **theo milestone**, không sinh cả hệ thống một lần. Mỗi milestone kết thúc bằng: test chạy xanh, hướng dẫn chạy thử, cập nhật mục "Trạng thái" ở cuối file này.
- Hợp đồng API ở A4 là chuẩn: tên field, enum, mã lỗi phải giống **từng ký tự** giữa server DTO và model mobile. Thiếu thứ gì → đề xuất bổ sung vào phần chung (tăng SHARED_VERSION) chứ không tự chế riêng một bên.
- Không đoán khi gặp câu hỏi còn mở (A2) — hỏi chủ dự án.
- Viết tiếng Việt cho tài liệu/comment giải thích nghiệp vụ; code, tên biến, commit message bằng tiếng Anh.

<!-- ===== HẾT PHẦN CHUNG ===== -->

# Phần B — Riêng cho `happy_share` (Flutter mobile)

## B1. Hiện trạng
Project Flutter mới tạo (`flutter create`), package `happy_share`, Dart SDK `^3.11.5`, Android `applicationId = com.happy.share.happy_share` (xem Q3). Chưa có code nghiệp vụ.

## B2. Thư viện
| Nhu cầu | Package |
|---|---|
| State | `flutter_bloc` (ưu tiên Cubit) + `equatable` |
| DI | `get_it` + `injectable` (+ `injectable_generator`) |
| Routing | `go_router` — `StatefulShellRoute.indexedStack` cho 5 tab |
| HTTP | `dio` (interceptor: gắn token, refresh khi `TOKEN_EXPIRED`, map envelope) |
| Model | `freezed` + `json_serializable` — `@JsonSerializable(fieldRename: FieldRename.snake)` |
| Local DB | `sqflite` (queue + cache) |
| Token | `flutter_secure_storage` |
| Native bridge | `pigeon` |
| Nền | `workmanager` (sync định kỳ) |
| Quyền | `permission_handler` (chỉ để mở Settings/đọc trạng thái; xin quyền vị trí do native làm) |
| Bản đồ | `google_maps_flutter` (tạm, Q1) |
| QR | `mobile_scanner`, `qr_flutter` |
| Khác | `uuid`, `intl`, `flutter_localizations`, `connectivity_plus`, `package_info_plus`, `device_info_plus`, `logger` |

## B3. Lệnh thường dùng
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # freezed, json, injectable
dart run pigeon --input pigeons/location_api.dart
flutter run --dart-define-from-file=env/dev.json
flutter analyze && flutter test
```
`env/dev.json` (không commit; commit `env/example.json`): `{"ENV":"dev","API_BASE_URL":"http://10.0.2.2:3000/api/v1","GOOGLE_MAPS_API_KEY":"..."}`. Key bản đồ native đưa vào qua Gradle/xcconfig đọc từ biến, không hardcode trong repo.
`API_BASE_URL` theo môi trường chạy: emulator Android `http://10.0.2.2:3000/api/v1`; iOS simulator `http://localhost:3000/api/v1`; thiết bị thật dùng IP LAN của máy chạy server (cùng Wi-Fi) hoặc `adb reverse tcp:3000 tcp:3000` rồi `http://localhost:3000/api/v1`. HTTP thường chỉ được phép ở bản **debug** Android (`usesCleartextTraffic` chỉ nằm trong `android/app/src/debug/AndroidManifest.xml`) và mạng nội bộ trên iOS (ATS `NSAllowsLocalNetworking`); bản release bắt buộc HTTPS (A6). Quyền `INTERNET` nằm ở manifest chính (mọi biến thể).

## B4. Cấu trúc thư mục
```
lib/
├── main.dart, app.dart
├── core/
│   ├── config/        # Env đọc từ --dart-define
│   ├── di/            # injection.dart (+ .config.dart sinh tự động, không sửa tay)
│   ├── network/       # api_client.dart, api_envelope.dart, api_exception.dart (ApiErrorCode enum = mã lỗi A4)
│   ├── router/        # app_router.dart, route names
│   ├── storage/       # secure_token_store.dart, app_database.dart
│   ├── constants/     # domain_enums.dart (enum A3 + fromJson có unknown), domain_constants.dart
│   ├── theme/ l10n/ utils/ widgets/
├── features/
│   ├── auth/ family/ members/ consent/ journey/ places/ settings/ onboarding/
│   │   └── data/ (api, dto/model, repository) · domain/ (entity nếu cần) · presentation/ (cubit, pages, widgets)
└── location/
    ├── location_api.g.dart        # Pigeon sinh
    ├── location_controller.dart   # start/stop theo consent, đọc trạng thái quyền
    ├── queue/location_queue.dart  # đọc/xóa từ SQLite queue
    └── sync/sync_service.dart     # gửi batch theo A4
pigeons/location_api.dart
ios/Runner/Location/      # LocationManager.swift, QueueWriter.swift, HappyShareLocationApiImpl.swift
android/app/src/main/kotlin/com/happy/share/happy_share/location/   # LocationService.kt, GeofenceReceiver.kt, QueueWriter.kt, BootReceiver.kt
```

## B5. Quy ước code
- Model JSON khớp **từng ký tự** với A4; enum có `@JsonValue('...')` đúng chuỗi A3 và giá trị `unknown` (`unknownEnumValue`). `snake_case` cho mọi field được bật **toàn cục** trong `build.yaml` (`field_rename: snake`) — không lặp `@JsonSerializable(...)` trên từng model (annotation đó đặt trên `factory` của freezed bị analyzer cảnh báo).
- `ApiClient` trả `Result`/ném `ApiException(code)`; UI hiển thị thông báo theo `ApiErrorCode` (chuỗi l10n), không hiển thị `message` thô của server.
- Refresh token: một request refresh tại một thời điểm (khóa), các request khác chờ; refresh thất bại `REFRESH_TOKEN_INVALID` → xóa token, về màn đăng nhập.
- Điều hướng khi mở app: gọi `GET /me` → chưa có family → màn Tạo/Tham gia; có family nhưng `consent.status` là `null` (chưa từng đồng ý) hoặc `revoked` → màn giới thiệu chia sẻ (có thể bỏ qua). `consent` chỉ là `null` khi chưa có family; ngược lại → shell 5 tab.
- **Màu/kiểu dáng chỉ lấy từ token** (`lib/core/theme/app_colors.dart`, `app_theme.dart`): không viết mã màu hex hay `Colors.xxx` trong widget; trạng thái chia sẻ và độ mới dùng `context.statusColors.forSharing(...)` / `.forFreshness(...)` (luôn biểu tượng + chữ, nhãn qua `SharingState.label(l10n)`); chữ trên nền Terracotta (accent) dùng `onSecondary` (chữ đậm), KHÔNG chữ trắng; liên kết/chữ nhỏ màu accent dùng `AppPalette.accentText`, KHÔNG dùng accent nguyên bản.
- UI tiếng Việt mặc định (l10n arb), có `en`. Không dùng chữ "theo dõi liên tục", "real-time".
- Luôn hiển thị `freshness` ("Cập nhật 5 phút trước" / "Dữ liệu cũ" / "Chưa có dữ liệu") và `sharing_state` của từng member.
- Timeline vẽ item `gap` rõ ràng (ví dụ nét đứt + "Không có dữ liệu 10:30–11:45"), không nối đường qua gap.
- **Không log tọa độ** (logger, Crashlytics, analytics). Log queue chỉ ghi số lượng.

## B6. Location module (native ↔ Dart)
**Pigeon API** (`pigeons/location_api.dart`):
- Host (Dart → native): `startTracking(TrackingConfig)`, `stopTracking()`, `getPermissionStatus() → PermissionInfo{os_permission, precise, background_enabled}`, `requestForegroundPermission()`, `requestBackgroundPermission()`, `openAppSettings()`, `isTracking()`.
- Flutter API (native → Dart, khi engine đang chạy): `onPermissionChanged(PermissionInfo)`, `onEventsQueued(int count)`.
- `TrackingConfig` chứa hằng số A3 (`move_start_distance_m`, `moving_sample_interval_s`, `desired_accuracy_m`) + đường dẫn file DB.

**SQLite queue** (file `location_queue.db`, WAL mode; native ghi, Dart đọc/xóa):
```sql
CREATE TABLE location_queue (
  event_id TEXT PRIMARY KEY, recorded_at TEXT NOT NULL,   -- ISO UTC
  latitude REAL NOT NULL, longitude REAL NOT NULL, accuracy REAL NOT NULL,
  speed REAL, altitude REAL, heading REAL,
  source TEXT NOT NULL, activity TEXT, battery_level REAL, is_mock INTEGER NOT NULL DEFAULT 0,
  attempts INTEGER NOT NULL DEFAULT 0, created_at TEXT NOT NULL
);
CREATE INDEX idx_queue_recorded ON location_queue(recorded_at);
```
**SyncService**: kích hoạt khi app foreground, có mạng trở lại, sau `onEventsQueued` (debounce 30s), và `workmanager` định kỳ (~15 phút, theo giới hạn OS). Mỗi lần: lấy tối đa 500 dòng theo `recorded_at` → `POST /locations/batch` → xóa accepted/duplicates/rejected → lặp đến hết. Lỗi mạng/5xx/429 → tăng `attempts`, backoff. Dọn dòng cũ hơn 7 ngày và vượt `QUEUE_MAX_ROWS`. 403 `CONSENT_REVOKED` → `stopTracking()` + xóa queue. Chi tiết xử lý lỗi batch: xem B10. Hiển thị trạng thái đồng bộ (lần cuối, số chờ gửi) trong Cài đặt.
Native cần `device_id` + `consent` hiện tại → Dart ghi vào nơi native đọc được (UserDefaults / SharedPreferences native) khi thay đổi; native **không** gọi API (MVP).

**Kiểm thử thiết bị thật bắt buộc** (ghi kết quả vào `docs/device-test-log.md`): khóa màn hình, app bị kill/suspend, reboot, đổi quyền giữa chừng, Doze/Battery Saver, OEM (Xiaomi/Oppo/Samsung), mất mạng 1 ngày, đo pin 8 giờ.

## B7. Consent flow (UX)
Màn giải thích: dữ liệu nào được thu, ai xem được, cách tạm dừng/thu hồi, không bán dữ liệu → nút "Tôi đồng ý chia sẻ" → `POST /locations/consent {consent_version: CURRENT_CONSENT_VERSION, platform}` → xin quyền foreground → giải thích lý do cần "Luôn cho phép" → xin quyền nền → `PATCH /devices/:id` → `startTracking`. Từ chối quyền nền vẫn cho dùng app, `sharing_state` sẽ là `limited` và UI giải thích hạn chế. Cài đặt có: Tạm dừng / Tiếp tục / Thu hồi (xác nhận, nói rõ hậu quả theo A3). `PATCH` chỉ dùng khi đang `granted`/`paused`; sau khi `revoked` phải đi lại từ `POST` (server trả `CONSENT_REQUIRED` nếu PATCH). Khi `paused` vẫn tiếp tục đồng bộ queue bình thường (xem B10).

## B8. Milestones mobile
| # | Nội dung | Phụ thuộc | Nghiệm thu |
|---|---|---|---|
| M0 | Thêm package, cấu trúc thư mục, DI, router 5 tab rỗng, theme, l10n, Env, ApiClient + envelope + error map | — | `flutter analyze` sạch, chạy được shell 5 tab |
| M1 | Auth (đăng ký/đăng nhập/refresh/đăng xuất), `GET /me` điều hướng, tạo/tham gia gia đình, mời bằng mã + QR, tab Thành viên | S1 | Đăng nhập thật với server local; 2 máy vào cùng gia đình |
| M2 | Spike native iOS + Android: Pigeon, quyền, thu thập thích ứng, ghi SQLite queue | — | Có log số sự kiện trên máy thật khi khóa màn hình 1 giờ |
| M3 | Consent flow, đăng ký device, SyncService + workmanager, trạng thái đồng bộ | S2, M2 | Tắt mạng → bật lại đồng bộ đủ, không trùng; thu hồi dừng ngay |
| M4 | Tab Gia đình (bản đồ + latest + freshness), tab Hành trình (timeline + map + gap), tab Địa điểm (CRUD trên bản đồ) | S3 | Timeline 1 ngày thật hiển thị đúng visit/travel/gap |
| M5 | Cài đặt: tạm dừng/thu hồi, xóa tài khoản, quyền riêng tư; hoàn thiện UX lỗi/rỗng/loading; đo pin | S4 | Checklist nghiệm thu MVP (A1) đạt trên 2 nền tảng |

## B9. Trạng thái
- [x] M0  - [~] M1 (data/state xong, chờ UI Stitch)  - [ ] M2  - [ ] M3  - [ ] M4  - [ ] M5
(Cập nhật mục này sau mỗi milestone, kèm ghi chú lệch so với kế hoạch.)

**Ghi chú M0 (2026-11-09):**
- Dùng Flutter **3.41.7 qua FVM** (`C:\Users\nguye\fvm\versions\3.41.7`), không phải `flutter` trong PATH (3.35.4, Dart 3.9 — không đủ cho `sdk: ^3.11.5`).
- `permission_handler` ghim **^12.0.1**: bản 13.x dùng AGP 9, project đang AGP 8.11.1 / Gradle 8.14 nên build lỗi. Nâng lại khi nâng toolchain Android.
- Đã làm: Env, ApiClient + envelope + `ApiErrorCode`, `AuthInterceptor` (refresh có khóa; đọc lại kho token trước/sau khi refresh để chống race với isolate workmanager), `SecureTokenStore`, `domain_enums`/`domain_constants`, DI (injectable), router 5 tab, theme, l10n vi/en, 13 test. `flutter analyze` sạch, `flutter build apk --debug` OK.
- Chưa làm (đúng kế hoạch): redirect theo `AppSessionCubit` (M1), entry point workmanager (M3), Pigeon/native (M2). Chưa chạy thử trên máy thật/emulator.

**Ghi chú rà soát đồng bộ với server S0–S4 (2026-11-09, SHARED_VERSION 1.3):**
- Phần A đã đồng bộ 1.0 → 1.3: D13 (`identifier` thay email), `IDENTIFIER_TAKEN`, enum `identifier_type`, `paused` vẫn đồng bộ batch, bảng chữ mã mời loại thêm `U`, mục "Giới hạn dữ liệu đầu vào".
- Sửa trong code M0: `ApiErrorCode.emailTaken` → `identifierTaken`; l10n bỏ chữ "email" (`errorIdentifierTaken`, `errorInvalidCredentials`); thêm enum `IdentifierType`; `kInviteCodePattern` loại `U` cho khớp server; thêm hằng số giới hạn đầu vào (A4) và `normalizeInviteCode()`; **`AuthInterceptor` giờ refresh cả khi `UNAUTHENTICATED`** (tài khoản bị xóa ở thiết bị khác trước đây làm app kẹt, không bao giờ tự thoát phiên).
- Test: 13 → 28 (hợp đồng lỗi mới, refresh khi UNAUTHENTICATED, DELETE kèm body, query, mã mời, l10n phủ mọi `ApiErrorCode` và không còn chữ "email"). `flutter analyze` sạch.
- Phát hiện nhưng chưa làm (thuộc milestone sau): logout phải đọc refresh token mới nhất tại thời điểm gọi (M1); xử lý 400 `VALIDATION_ERROR` của batch không retry vô hạn (M3); chi tiết ở B10.
- Cấu hình mạng (chặn M1 "đăng nhập thật với server local"): quyền `INTERNET` trước đây chỉ có ở manifest debug nên bản profile/release không có mạng → đã thêm vào manifest chính; thêm `usesCleartextTraffic` **chỉ cho debug** (Android 9+ chặn HTTP tới `10.0.2.2`); iOS thêm ATS `NSAllowsLocalNetworking`. Đã `flutter build apk --debug` thành công và kiểm tra manifest đã gộp.
- Phần B của repo này không còn chỗ nào nhắc "email" làm định danh đăng nhập.
- Chưa chạy thử trên emulator/máy thật (không có thiết bị trong phiên này): hợp đồng được kiểm chứng bằng test với adapter giả + e2e phía server, chưa phải đăng nhập thật qua app.

**Ghi chú M1 — tầng data/state (2026-11-09; UI chưa làm, chờ thiết kế Stitch — prompt ở `docs/ui/stitch-prompts.md`):**
- Đã làm: model freezed (`User`, `Family`, `Member`, `Invitation`, `ConsentInfo`, `MeData`, `FamilyWithMember`); `AuthRepository` (login/register/logout), `MeRepository`, `FamilyRepository`; `LocalDataCleaner` (M2/M3 mở rộng); `AppSessionCubit` + `sessionRedirect` (điều hướng theo `GET /me`); `AuthCubit`, `FamilySetupCubit`, `MembersCubit`; validator đầu vào; router có redirect theo phiên và route placeholder cho splash/login/register/family-setup(+create,+join)/consent-intro.
- **Quy tắc điều hướng** (`lib/core/router/session_redirect.dart`, có test): `initializing`/`failure` → `/splash`; `unauthenticated` → `/login`|`/register`; `noFamily` → `/family-setup/**`; `consentIntro` → `/consent-intro`; `ready` → shell (mọi màn trước-shell kể cả `/consent-intro` tự chuyển về `/family`, nên "Để sau"/đồng ý xong không cần tự điều hướng). Bật chia sẻ từ Cài đặt (M3) phải dùng route riêng trong shell.
- `FamilySetupCubit` KHÔNG làm mới phiên khi tạo/tham gia thành công — UI gọi `finish()` khi người dùng bấm "Tiếp tục"/"Để sau", vì làm mới ngay thì router rời `/family-setup` trước khi màn xác nhận hiện ra.
- Lỗi mạng khi mở app: `failure` (màn chờ + nút "Thử lại" gọi `session.refreshMe()`); đã có dữ liệu mà làm mới lỗi thì giữ màn hình, chỉ gắn `error` (banner). Chỉ `UNAUTHENTICATED` còn sót hoặc token đã bị xóa mới đăng xuất.
- Phát hiện khi viết test: (1) `TOKEN_EXPIRED` + refresh bị từ chối chạy đua với `sessionExpired` có thể kẹt ở `failure` → `refreshMe` kiểm tra token đã bị xóa thì kết thúc phiên; (2) `/consent-intro` mở được khi `ready` làm người dùng kẹt ở màn đó sau "Để sau" → đã bỏ.
- Hiện app mở ra màn **Đăng nhập placeholder** (chưa có UI thật) nên chưa vào được shell 5 tab trên máy; test `session_navigation_test` kiểm chứng toàn bộ luồng. `HappyShareApp(session: null)` vẫn cho xem shell (dùng trong test).
- Test: 28 → 139 (model, repository, validator, cubit phiên/form/thành viên, quy tắc điều hướng, luồng điều hướng bằng widget, resolve DI). `flutter analyze` sạch.
- Việc còn lại của M1: dựng 7 màn từ thiết kế Stitch + l10n chuỗi, danh sách múi giờ cho màn tạo gia đình, quét QR (`mobile_scanner`), chia sẻ/sao chép mã mời, chạy thử với server local trên emulator.

**Ghi chú Design System "Warm Indigo & Terracotta" (2026-11-09; thay bảng "Sage Green & Honey Amber" cũ vì trích xuất từ Stitch bị sai — xanh chàm mới là đúng):**
- Bảng hiện hành: primary `#2B4C7E`, primary container `#DDE7F5`, accent Terracotta `#D96B43` (container `#FCE8E0`), nền `#F8F9FB`, chữ `#1A2533`/`#556578`, viền thẻ `#DDE2E8`; dark: nền `#141A24`, thẻ `#1F2837`, primary `#79A7DF`, accent `#E28562`. Điều chỉnh WCAG cho bảng mới: chữ trên Terracotta là chữ đậm `#1A2533` (trắng chỉ 3.42:1), liên kết/chữ nhỏ accent → `#AE4C28`, chữ lỗi trên nền lỗi → `#C21F2F`, chữ chip "hạn chế" → `#A35600`, viền ô nhập → `#7F8B9C` (≥ 3:1). "Chưa chia sẻ" bảng mới chưa nêu → giữ giá trị cũ. Chip độ mới "fresh" dùng indigo container.
- (Các gạch đầu dòng dưới đây mô tả cấu trúc code vẫn đúng; giá trị màu cụ thể trong đó là của bảng Sage cũ, lấy `app_colors.dart` làm chuẩn.)
- Bảng màu do chủ dự án cung cấp đã vào code: `AppPalette` (nguyên văn bảng), `AppColorSchemes` (sáng/tối dựng tường minh, không dùng `fromSeed`), `AppStatusColors` (ThemeExtension: 4 trạng thái chia sẻ + 4 chip độ mới), `AppRadius` (thẻ 16, ô nhập 12, chip 9999), `kMinTouchTarget = 48`. Font **Be Vietnam Pro** (OFL) đóng gói ở `assets/fonts/`.
- Giá trị nguyên văn bảng thiết kế được giữ làm màu thiết kế; chỉ **điều chỉnh tối thiểu cùng tông** ở những chỗ đo được là không đạt WCAG (đánh dấu `// điều chỉnh` trong code): chữ chip trạng thái (#1B8755→#197E50, #B25E00→#AC5B00, #6B7280→#69707E), chữ lỗi trên nền lỗi (#DC3545→#CF2434), chữ trên Honey Amber đổi thành chữ đậm #232C24 (trắng chỉ 2.73:1), accent dùng làm chữ → #9E5F17, viền ô nhập/nút viền #E0DACD (1.4:1) → #A08E66 (≥ 3:1; #E0DACD chỉ dành cho viền thẻ/đường kẻ).
- Bảng chưa nêu → **suy ra** (đánh dấu `// suy ra`): màu 4 trạng thái chia sẻ và chip độ mới ở dark mode; on-primary/on-accent/error/accent-container của dark mode; chip độ mới "recent" (≤ 2 giờ, server có 4 mức fresh/recent/stale/none còn bảng chỉ có 3) dùng kiểu trung tính; `unknown` hiển thị như "Chưa chia sẻ".
- `test/core/theme_test.dart` (token khớp bảng, tương phản mọi cặp màu ở cả hai theme, bo góc, vùng chạm 48dp) và `test/core/l10n_guard_test.dart` (không có từ cấm "real-time/giám sát/theo dõi liên tục/tracking"; vi/en cùng bộ khóa) chặn sai lệch về sau.
- Prompt Stitch (`docs/ui/stitch-prompts.md`) đã cập nhật theo bảng màu mới, kể cả các giá trị "chữ & biểu tượng" đã điều chỉnh để thiết kế và code khớp nhau.

**Ghi chú đồng bộ hợp đồng 2.0 (2026-11-09):** tầng data/state M1 đã sync sang SHARED_VERSION 2.0 (server S5). Thay đổi: `MeData` = `{user, families: [{family, member}], consent}` (`consent` luôn là object, `status: null` nếu chưa bật; `User.timezone`); `SessionStatus.noFamily` bị bỏ — nhóm là tùy chọn (D15), chỉ ghi nhận hành trình quyết định `consentIntro` hay `ready`; `SessionState.activeFamilyId/activeFamily/families` + `AppSessionCubit.selectFamily()` ("nhóm đang xem" cho các tab, mặc định nhóm đầu, tự quay về nhóm đầu nếu nhóm đang xem biến mất); `/family-setup/*` dùng được cả khi đã `ready` (có thể ở nhiều nhóm, tối đa `kMaxGroupsPerUser`); `FamilyRepository.createFamily/joinFamily` luôn gửi `sharing_consent_version = kCurrentSharingConsentVersion` (UI phải hiển thị nội dung đồng ý trước); `kCurrentConsentVersion` = `2026-11-v2`; `ApiErrorCode.groupLimit`; `FamilySetupCubit.finish()` chuyển sang nhóm vừa tạo/tham gia; `MembersCubit` dùng nhóm đang xem và **không** còn dọn dữ liệu vị trí khi rời nhóm; `AppSessionCubit` chỉ dọn hàng đợi khi ghi nhận chuyển granted/paused → revoked (tắt từ máy khác); `MeRepository.updateMe` (`PATCH /me`). Chuỗi hiển thị "Gia đình" → "Nhóm" (D14, trong arb vi/en). **Chưa làm (milestone sau):** repository/cubit cho `GET /locations/latest?family_id=`, `/places?family_id=`, `/journeys|visits|summaries/me|:userId` (+ `shared_from`), `DELETE /locations/history`, màn Cài đặt "Ghi lại hành trình của tôi", bộ chọn nhóm trên UI, prompt Stitch đã viết lại cho luồng 2.0 (`docs/ui/stitch-prompts.md`: Prompt 3 = tab Nhóm khi chưa có nhóm, 4/5 = tạo/tham gia kèm đồng ý chia sẻ, 6 = Thành viên + bộ chọn nhóm, 7 = giới thiệu ghi lại hành trình, 8 = Cài đặt → Ghi lại hành trình của tôi; múi giờ chuyển sang Cài đặt).

## B10. Hành vi server đã chốt (S1–S5, hợp đồng 2.0)
Tổng hợp hành vi thực tế của server mà Phần A (hợp đồng chung) không mô tả hết. Server là nguồn đúng; lệch thì hỏi chủ dự án, không tự chế.

**Đăng ký / đăng nhập / phiên**
- Một ô `identifier` (tên tài khoản, email hoặc SĐT — D13). Gửi nguyên chuỗi người dùng nhập (chỉ `trim`), **không** tự chuẩn hóa hay đoán loại; server trả `user.identifier` (đã chuẩn hóa) + `identifier_type` (enum `IdentifierType` có `unknown`). Validate sớm theo A4: không rỗng, ≤ `kIdentifierMaxLength`, mật khẩu `kPasswordMinLength`–`kPasswordMaxLength`; còn lại để server trả `VALIDATION_ERROR` (`fieldErrors`).
- Lỗi: `IDENTIFIER_TAKEN`, `INVALID_CREDENTIALS`, `RATE_LIMITED` (429: auth/join 10 lần/phút/IP; ≥ 10 lần đăng nhập sai trong 15 phút trên một tài khoản bị khóa tạm kể cả khi gõ đúng; xóa tài khoản 5 lần/phút) → hiện "thử lại sau", không tự retry dồn dập.
- `AuthInterceptor` refresh **một lần** cho cả `TOKEN_EXPIRED` lẫn `UNAUTHENTICATED` (token hỏng, hoặc tài khoản đã bị xóa — server từ chối ngay, không đợi 15 phút); `REFRESH_TOKEN_INVALID` → xóa phiên về màn đăng nhập. Dùng lại refresh token cũ làm server thu hồi cả chuỗi phiên, nên **tuyệt đối không** gọi refresh song song hay giữ token cũ (đã có khóa + đọc lại kho token).
- Đăng xuất: lấy refresh token **mới nhất từ kho tại thời điểm gọi** (access có thể vừa được refresh), gọi `POST /auth/logout {refresh_token}` rồi `DELETE /devices/:id`; dù API lỗi mạng vẫn xóa token, queue SQLite, `device_id` và cache cục bộ.
- Xóa tài khoản: `DELETE /me {password}` → `{}`. Sai mật khẩu = `INVALID_CREDENTIALS`. Thành công → xóa token, queue, `device_id`, cache, dừng thu thập native, về màn đăng nhập. Hậu quả cần nói rõ trong UI: xóa toàn bộ dữ liệu vị trí; nếu là chủ nhóm và còn người khác thì quyền chủ nhóm chuyển cho người tham gia sớm nhất; nếu ở một mình thì gia đình bị xóa.

**Gia đình**
- Mã mời: `normalizeInviteCode()` (chữ hoa, bỏ khoảng trắng/dấu `-`) chỉ để báo lỗi sớm; đúng/đã dùng/hết hạn do server quyết (`INVITE_INVALID`, `INVITE_EXPIRED`). Bảng chữ không có 0/O/1/I/L/U.
- Rời nhóm hoặc bị chủ nhóm xóa → chỉ mất quyền xem nhóm đó **ngay**; ghi nhận hành trình cá nhân (consent) **không đổi** (D15) nên **không** dừng thu thập, **không** xóa queue. Vào lại nhóm là đồng ý chia sẻ lại (`sharing_consent_version`) và `joined_at` được đặt lại (mốc `shared_from` mới). Nhận biết bị xóa qua `NOT_FAMILY_MEMBER` ở API của nhóm đó → làm mới `/me`.
- Tạo/tham gia nhóm là đồng ý chia sẻ (D16): body bắt buộc có `sharing_consent_version` (= `kCurrentSharingConsentVersion`, sai/thiếu → `VALIDATION_ERROR`). Tối đa `kMaxGroupsPerUser` (5) nhóm → `GROUP_LIMIT` (422). `ALREADY_IN_FAMILY` (409) = đã ở **nhóm này** và mã mời **không** bị tiêu thụ.
- Chủ nhóm có thể đổi khi chủ cũ xóa tài khoản: luôn đọc `role` từ `/me`/members, không cache lâu.

**Consent / thiết bị / đồng bộ**
- `POST /locations/consent` phải gửi đúng `kCurrentConsentVersion` (sai → `VALIDATION_ERROR`). POST/PATCH/DELETE đều trả `{status, consent_version, updated_at}` → dùng để cập nhật UI ngay. `GET` khi chưa đồng ý trả `status: null`.
- `sharing_state` luôn lấy từ server (`limited` khi quyền OS ≠ `always` hoặc đã báo `background_enabled=false`); gọi `PATCH /devices/:id` mỗi khi quyền OS đổi và lúc mở app.
- `DEVICE_NOT_REGISTERED` (thiết bị đã bị xóa / không thuộc user) → `POST /devices` đăng ký lại, ghi `device_id` mới cho native, rồi gửi lại.
- Batch `POST /locations/batch`: ≤ `kBatchMaxEvents` event, thân ≤ 2 MB.
  - **`paused` vẫn đồng bộ bình thường**: server nhận điểm ghi *trước* lúc tạm dừng; điểm ghi *trong* lúc tạm dừng bị `rejected: consent_not_granted` (xóa khỏi queue như mọi rejected).
  - 403 `CONSENT_REVOKED` → `stopTracking()` + xóa queue. 403 `CONSENT_REQUIRED` (chưa từng đồng ý) → dừng đồng bộ, không retry, chờ consent `granted`.
  - 400 `VALIDATION_ERROR` (event sai hình dạng, vd `source` lạ, `event_id` không phải UUID v4) làm hỏng **cả lô** và không phải lỗi tạm thời → **không retry nguyên lô vô hạn**: dùng `fieldErrors` (khóa dạng `events.<chỉ số>.<field>`) để loại các event sai khỏi queue rồi gửi lại phần còn lại; không xác định được thì loại cả lô sau vài lần.
  - Giá trị `rejected` (`invalid_coordinates | invalid_accuracy | too_old | future_timestamp | consent_not_granted | mock_location`) là vĩnh viễn: xóa khỏi queue, không retry.

**Hành trình / bản đồ**
- `GET /locations/latest?family_id=` (bắt buộc) trả mọi member active của nhóm đó, mỗi item có `member_id` + `user_id`; `current_visit` (Visit đang mở kèm `place`) dùng cho "đang ở <Địa điểm>". `paused` → tọa độ và `current_visit` null (hiện "Đã tạm dừng"); `not_shared` → mọi trường vị trí null, `freshness: none`. Với người khác, dữ liệu ghi **trước `shared_from`** không được trả (item hiện như chưa có dữ liệu); của chính mình luôn đầy đủ.
- `GET /journeys|/visits|/summaries/me?date=YYYY-MM-DD` (của chính mình, không cần nhóm — nhật ký cá nhân) hoặc `/:userId` (người khác cùng nhóm; dùng `Member.userId`). Ngày theo `User.timezone` của **người có dữ liệu** (D08), **không** theo múi giờ máy hay `family.timezone`. Timeline có `shared_from` (null khi xem của mình): với người khác, mọi item đã bị cắt tại mốc đó (giờ đến thật trước mốc không lộ) — hiển thị "Chia sẻ từ <thời điểm>"; ngày hoàn toàn trước mốc trả `items: []`. Cửa sổ lịch sử: của mình `max(kPersonalHistoryDays, gói rộng nhất)`, của người khác theo gói nhóm chung. Lỗi: 403 `FORBIDDEN` = *người đó* không chia sẻ (**không phải lỗi của mình — tuyệt đối không xóa queue hay dừng thu thập**), 403 `NOT_FAMILY_MEMBER`, 422 `HISTORY_OUT_OF_PLAN` (ẩn/vô hiệu các ngày ngoài cửa sổ), 400 `VALIDATION_ERROR`. `DELETE /locations/history` xóa dữ liệu hành trình của mình (không tắt ghi nhận, không xóa tài khoản). Tên địa điểm trong timeline của mình khớp Place của mọi nhóm mình ở; của người khác chỉ Place của nhóm chung; chưa ở nhóm nào thì `place = null`.
- Timeline: `travel.path` có thể rỗng (biết có di chuyển nhưng không có điểm); `gap.reason` ∈ `no_data | sharing_paused`; Visit đang mở có `end_time: null`; Visit có thể bắt đầu từ hôm trước (hiển thị theo `visit.arrival_time` gốc); `is_complete=false` cho tới 7 ngày sau khi hết ngày (còn nhận dữ liệu muộn → cho kéo để làm mới). **Visit `id` không ổn định** giữa các lần server tính lại — đừng dùng làm khóa lâu dài.
- Visit được tính bất đồng bộ sau mỗi batch (vài trăm ms–giây): sau khi sync xong, làm mới sau một nhịp, đừng giả định có ngay.

**Địa điểm**
- `GET /places?family_id=` và `POST /places` (body có `family_id`) theo từng nhóm. `radius_meters` ∈ [`kPlaceRadiusMinM`, `kPlaceRadiusMaxM`], mặc định `kPlaceRadiusDefaultM`; `PLAN_LIMIT_PLACES` (422); chỉ chủ nhóm và người tạo sửa/xóa (403 `FORBIDDEN` cho người khác — ẩn nút sửa/xóa). Tên và loại do người dùng tự đặt; app không tự gợi ý/gán loại nhạy cảm.

**Quyền riêng tư (nội dung màn Quyền riêng tư)**
- Xem lịch sử của *người khác* được ghi nhật ký (ngày + loại, không có tọa độ). Dữ liệu vị trí cũ hơn cửa sổ lịch sử của gói bị server xóa tự động. Xóa tài khoản xóa toàn bộ dữ liệu vị trí; backup xóa theo chu kỳ retention công bố.
