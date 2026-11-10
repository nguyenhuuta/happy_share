## Task: M1 — dựng UI từ thiết kế Stitch (Design System "Sage Green & Honey Amber")
**Lưu lúc:** 2026-11-09 (chuyển từ phiên CLI ở repo server `happy_share_server` sang phiên CLI repo mobile)

> ## ✅ ĐÃ SYNC data/state mobile sang HỢP ĐỒNG 2.0 (2026-11-09) — `flutter analyze` sạch, 170 test xanh, APK debug build OK
> (Danh sách bên dưới là nội dung đã làm; chi tiết ở `CLAUDE.md` B9 "Ghi chú đồng bộ hợp đồng 2.0" và B10. Các mục "Còn lại"/"Files liên quan" phía dưới có thể còn nhắc gia đình/1.3 — ưu tiên Phần A 2.0.)
> ## Bối cảnh: HỢP ĐỒNG ĐÃ LÊN 2.0
> Mọi chỗ bên dưới ghi "SHARED_VERSION 1.3 / gia đình / 1 gia đình" là **đã cũ**. Phần A của `CLAUDE.md` này **đã được chép sang bản 2.0** (giống hệt server) và server `happy_share_server` đã triển khai xong (S5; 118 unit + 160 e2e xanh). **Code mobile (`lib/`, 164 test) vẫn viết theo 1.3 và phải sync TRƯỚC khi dựng UI.**
> Tóm tắt 2.0 (đọc Phần A để đủ chi tiết; đề xuất gốc ở `T:\Data\Project\happy_share_server\docs\contract-2.0-proposal.md`, ghi chú triển khai ở B9 mục S5 của `happy_share_server\CLAUDE.md`):
> - Hành trình ghi **theo user**, bật ở Cài đặt ("Ghi lại hành trình của tôi"), **không cần thuộc nhóm**; timeline cá nhân qua `/journeys|visits|summaries/me`. Nhóm chỉ là danh sách ai được xem ai; vào nhóm = đồng ý chia sẻ **từ lúc vào** (`shared_from`), rời nhóm = dừng chia sẻ và **không** tắt ghi nhận. Một người ở tối đa 5 nhóm. Chữ hiển thị "Nhóm" (code/API giữ `Family`/`/families`).
> - Việc cần sửa ở mobile: `MeData` → `families: [{family, member}]` + `consent` luôn là object (status null nếu chưa bật); `User.timezone` (+ `PATCH /me {timezone}`); `POST /families` và `/families/join` gửi `sharing_consent_version` = `2026-11-g1`; `CURRENT_CONSENT_VERSION` = `2026-11-v2`; thêm `ErrorCode.GROUP_LIMIT` (422), `ALREADY_IN_FAMILY` nghĩa là "đã ở nhóm này"; `/locations/latest?family_id=`, `/places?family_id=` (+`family_id` khi tạo Place); `Visit/timeline/latest` dùng `user_id` thay `member_id`, timeline có `shared_from`; `DELETE /locations/history`; ngày theo `users.timezone` (không còn theo `families.timezone`).
> - Điều hướng/state: đăng nhập → (tuỳ chọn) bật ghi nhận → nhóm là tùy chọn; cần khái niệm "nhóm đang xem" cho các tab; `AppSessionCubit`/`sessionRedirect`/`FamilySetupCubit`/`MembersCubit` và các test (`fakes.dart`, `session_redirect_test`…) phải sửa theo. Thu thập native chạy khi ghi nhận = `granted`, không phụ thuộc nhóm.
> - Prompt Stitch (`docs/ui/stitch-prompts.md`) cần viết lại cho luồng mới (màn đầu, màn 3 và 7, thêm Cài đặt ghi nhận + bộ chọn nhóm) — đợi người dùng xác nhận trước khi sửa.
> - **Đã làm:** hằng số (`kCurrentConsentVersion=2026-11-v2`, `kCurrentSharingConsentVersion`, `kMaxGroupsPerUser`, `kPersonalHistoryDays`), `ApiErrorCode.groupLimit`, `User.timezone`, `MeData.families` + `consent` bắt buộc, `SessionStatus.noFamily` bị bỏ, `SessionState.activeFamily`/`selectFamily`, redirect (family-setup dùng được khi ready), `FamilyRepository` gửi `sharing_consent_version`, `MeRepository.updateMe`, `FamilySetupCubit.finish()` chọn nhóm mới, `MembersCubit` theo nhóm đang xem và không dọn dữ liệu khi rời nhóm, chuỗi l10n "Nhóm" (vi/en), test cập nhật + test mới (nhiều nhóm, GROUP_LIMIT…). `dart format` đã chạy trên `lib` và `test` (đổi định dạng ~39 file).
> - **Bước tiếp theo thực tế:** (1) prompt Stitch ĐÃ viết lại cho 2.0 (`docs/ui/stitch-prompts.md`, 9 prompt: 0–8; thêm Màn 8 Cài đặt → Ghi lại hành trình của tôi, bộ chọn nhóm ở 6g, bỏ ô múi giờ khỏi Tạo nhóm) — chờ người dùng chạy Stitch và gửi thiết kế (bắt đầu Màn 1); (2) các màn UI M1 + màn Cài đặt ghi nhận; (3) repository/cubit cho latest/places/journeys (`shared_from`), `DELETE /locations/history` ở milestone M3/M5.

### Mô tả
Dự án **Happy Share**: app chia sẻ vị trí tự nguyện của gia đình để tạo nhật ký hành trình (Flutter, repo này) + backend NestJS ở `T:\Data\Project\happy_share_server` (đã xong S0–S4, chạy được, 140 e2e + 118 unit xanh). Hợp đồng chung A của hai `CLAUDE.md` là chuẩn, hiện **SHARED_VERSION 1.3** — kiểm tra hai file còn đồng bộ bằng diff đoạn từ `# Phần A` đến `# Phần B` (chỉ được khác dòng tiêu đề Phần B). Đọc kỹ `CLAUDE.md` mục **B9 (ghi chú M1, ghi chú Design System)** và **B10 (hành vi server mà mobile PHẢI tuân thủ)** trước khi code.

Mobile đang ở **M1**: tầng data/state đã xong và có test; thiết kế UI đang làm trên **Google Stitch** (người dùng tự chạy Stitch rồi gửi ảnh chụp + HTML/CSS từng màn). Việc của phiên này là dựng 7 màn Flutter theo thiết kế đó, nối vào các cubit đã có, rồi chạy thử với server local.

7 màn M1 (prompt Stitch ở `docs/ui/stitch-prompts.md`): 1 Đăng nhập · 2 Đăng ký · 3 Chưa có gia đình (Tạo/Tham gia) · 4 Tạo gia đình · 5 Tham gia bằng mã (+ quét QR) · 6 Tab Thành viên (+ mời) · 7 Giới thiệu chia sẻ (consent).

### Files liên quan
- `CLAUDE.md` (Phần A đồng bộ với server; B9 trạng thái; **B10 hành vi server**)
- `docs/ui/stitch-prompts.md` — Khối A / Khối A rút gọn / Khối B + Prompt 0–7 (Prompt 1 đã tách "nối tiếp 1a–1d"; Prompt 2–7 còn "Variants" trong cùng prompt)
- Theme/token: `lib/core/theme/app_colors.dart` (AppPalette, AppColorSchemes, AppStatusColors, AppRadius), `lib/core/theme/app_theme.dart`, font `assets/fonts/BeVietnamPro-*.ttf`
- State/điều hướng: `lib/core/session/{app_session_cubit,session_state}.dart`, `lib/core/router/{app_router,app_routes,session_redirect}.dart`, `lib/core/utils/{submit_state,invite_code,status_l10n,api_error_l10n}.dart`
- Data: `lib/features/auth/data/{model,repository}`, `lib/features/family/data/{model,repository}`, `lib/features/consent/data/model/consent_info.dart`, `lib/features/auth/domain/auth_validators.dart`
- Cubit: `lib/features/auth/presentation/cubit/auth_cubit.dart`, `lib/features/family/presentation/cubit/{family_setup_cubit,members_cubit}.dart`
- Test helper: `test/helpers/fakes.dart` (Harness, FakeAdapter, dữ liệu mẫu A4)
- Đang là **placeholder** (cần thay bằng màn thật): các `GoRoute` splash/login/register/family-setup(+create,+join)/consent-intro trong `app_router.dart`, và 5 trang tab trong `lib/features/*/presentation/pages/`

### Đã hoàn thành
- [x] M0: nền tảng (ApiClient, envelope, AuthInterceptor refresh có khóa, DI, router 5 tab, l10n vi/en)
- [x] Server S0–S4 xong; Phần A đồng bộ 1.0→1.3; sửa M0 cho khớp hợp đồng (IDENTIFIER_TAKEN, IdentifierType, refresh khi UNAUTHENTICATED, cấu hình mạng INTERNET/cleartext debug/ATS)
- [x] M1 tầng data/state: model freezed, AuthRepository/MeRepository/FamilyRepository, AppSessionCubit + sessionRedirect, AuthCubit/FamilySetupCubit/MembersCubit, validator, router có redirect theo phiên
- [x] Design System màu mới đã vào code + test tương phản WCAG + guard từ cấm (`test/core/theme_test.dart`, `l10n_guard_test.dart`); font Be Vietnam Pro đóng gói
- [x] Bộ prompt Stitch + Khối A rút gọn (dùng khi đã chọn màn "Quy chuẩn thiết kế" làm ngữ cảnh)
- [x] `flutter analyze` sạch, **164 test xanh**, `flutter build apk --debug` OK

### Còn lại
- [ ] Nhận thiết kế từ người dùng (ảnh + HTML/CSS) cho 7 màn và dựng widget Flutter (đặt ở `lib/features/<feature>/presentation/pages|widgets/`)
- [ ] Chuỗi l10n cho 7 màn (vi + en, cùng bộ khóa — `l10n_guard_test` bắt thiếu); ánh xạ `fieldErrors` (`required|minLength|maxLength|invalid|invalidIdentifier`) và `ApiErrorCode.localized(l10n)` sang thông báo
- [ ] Danh sách múi giờ cho màn Tạo gia đình (mặc định `Asia/Ho_Chi_Minh`; server kiểm tra IANA)
- [ ] Quét QR (`mobile_scanner`, payload `happyshare://join?code=...`), chia sẻ/sao chép mã mời (`qr_flutter`)
- [ ] Màn splash/failure có nút "Thử lại" → `session.refreshMe()`; hiển thị `session.state.error` dạng banner khi làm mới lỗi mạng
- [ ] Test widget cho từng màn; chạy thử đăng nhập thật với server local trên emulator (nghiệm thu M1: 2 máy vào cùng một gia đình)
- [ ] Cập nhật `CLAUDE.md` B9 khi xong M1; sau đó M2 (spike native, cần máy thật), M3…

### Bước tiếp theo
Hỏi người dùng đã có thiết kế màn nào từ Stitch chưa (bắt đầu **màn 1 Đăng nhập**). Khi nhận được ảnh/HTML: dựng `LoginPage` trong `lib/features/auth/presentation/pages/`, bọc `BlocProvider(create: (_) => getIt<AuthCubit>())`, dùng `SubmitState` (`fieldErrors`, `error`, `isSubmitting`), thay route `/login` trong `app_router.dart`; chỉ lấy màu/kiểu từ theme (`Theme.of(context)`, `context.statusColors`) — **không** viết mã hex hay `Colors.xxx` trong widget.

### Lưu ý quan trọng (đã gặp bẫy)
**Môi trường**
- Dùng Flutter **3.41.7 qua FVM**, KHÔNG dùng `flutter` mặc định trong PATH (3.35.4, quá cũ): PowerShell `$env:Path = "C:\Users\nguye\fvm\versions\3.41.7\bin;" + $env:Path`
- Lệnh: `flutter analyze` · `flutter test` · `dart run build_runner build --delete-conflicting-outputs` (freezed/json/injectable) · `flutter gen-l10n` (sau khi sửa `.arb`) · `flutter build apk --debug`
- Chạy với server local: trong `T:\Data\Project\happy_share_server` → `docker compose up -d db` (Docker nằm ở `C:\Users\nguye\AppData\Local\Programs\DockerDesktop\resources\bin`, có thể phải làm mới PATH) → `yarn migration:run` → `yarn start:dev` (http://localhost:3000/api/v1). Emulator Android dùng `http://10.0.2.2:3000/api/v1` (`env/dev.json`, không commit)
- Chưa từng chạy app trên emulator/máy thật; hợp đồng mới chỉ được kiểm chứng bằng test adapter giả + e2e phía server

**Quy tắc dự án**
- Phần A của hai `CLAUDE.md` phải giống hệt nhau; đổi Phần A thì sửa cả hai + tăng SHARED_VERSION. Hợp đồng/field/enum/mã lỗi giống từng ký tự với server
- Giao diện tiếng Việt mặc định (+ en). Từ cấm: "real-time", "giám sát", "theo dõi liên tục", "tracking" (có test chặn). Dùng "Hành trình", "Nhật ký", "Điểm đến", "Chia sẻ tự nguyện"
- Trạng thái chia sẻ (4 loại) luôn là **biểu tượng + chữ**, độ mới dữ liệu luôn đi kèm vị trí; `unknown` hiển thị như "Chưa chia sẻ"
- Không log tọa độ. Token chỉ ở secure storage
- Chủ nhóm không bật chia sẻ thay người khác

**Quyết định thiết kế cần nhớ**
- `FamilySetupCubit` KHÔNG làm mới phiên khi tạo/tham gia thành công; UI gọi `finish()` khi người dùng bấm "Tiếp tục/Để sau/Mời thành viên" (nếu không router rời màn trước khi màn xác nhận hiện)
- `/consent-intro` chỉ thuộc luồng trước-shell: khi `ready` router tự chuyển về `/family` (nên "Để sau"/đồng ý xong không cần tự điều hướng). Bật chia sẻ từ Cài đặt (M3) dùng route riêng trong shell
- 403 `FORBIDDEN` khi xem lịch sử của *người khác* KHÔNG phải lỗi của mình — đừng xóa queue/dừng thu thập
- App hiện mở ra màn **Đăng nhập placeholder** (chưa có UI), nên chưa vào được shell 5 tab trên máy; `HappyShareApp(session: null)` vẫn cho xem shell (test dùng)
- Màu "text & icon" của chip trạng thái và vài màu khác đã **điều chỉnh tối thiểu** so với bảng gốc để đạt WCAG (đánh dấu `// điều chỉnh` / `// suy ra` trong `app_colors.dart`); không "sửa lại cho giống bảng gốc" vì sẽ làm test tương phản fail

**Quyết định đang chờ người dùng**
- ĐÃ QUYẾT (người dùng đồng ý): hai câu mô tả phụ đổi thành "Đang ghi nhận hành trình" (trạng thái Đang chia sẻ) và "Chưa bật chia sẻ" (trạng thái Chưa chia sẻ); đã sửa trong Prompt 0 của `docs/ui/stitch-prompts.md`. Khi đưa vào l10n dùng đúng hai câu này.
- Có dùng "Khối A rút gọn" + chọn màn "Quy chuẩn thiết kế" làm ngữ cảnh trong Stitch hay dán Khối A đầy đủ (người dùng đang kiểm tra màn Đăng nhập đầu tiên)
- Kiểu chip độ mới mức `recent` (≤ 2 giờ): bảng thiết kế chỉ có 3 chip, đã chọn kiểu trung tính

**Bẫy công cụ (đã mất thời gian)**
- Trong lệnh bash, heredoc làm mất dấu `\` trong regex JS; viết script bằng công cụ Write rồi chạy `node`, không nhồi regex vào heredoc
- `Edit`/`Write` đè file có sẵn phải `Read` trước trong phiên đó
- Nhiều file là CRLF; khi patch bằng script nên chuẩn hóa EOL rồi ghi lại đúng kiểu. PowerShell 5.1 `Set-Content -Encoding utf8` thêm BOM — tránh dùng cho `package.json`/`tsconfig`
- `flutter_test` có hàm `fail()` — đừng đặt tên helper trùng
- Repo không phải git repo (không có `git diff`); cẩn thận khi ghi đè
