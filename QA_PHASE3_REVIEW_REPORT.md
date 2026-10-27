# QA Post-Implementation Review Report — Doist Phase 3 UI/UX

**Branch:** `feature/phase3-ui-ux` vs `main`
**Repo:** `/mnt/ALL/Flutter Projects/doist`
**Date:** 2026-10-26
**Scope:** All Phase 3 UI/UX changes (tasks 3.1–3.16 per spec `.hermes/plans/2026-10-21_033922-doist-phase3-ui-ux.md`)
**Reviewers:** Code Reviewer, Security Engineer, Test Coverage Analyst, Spec Compliance Auditor (all context-free, read-only)
**Status:** Quality gate **FAILING** — halting for user approval before fix loop

---

## Executive Summary

Phase 3 wires STT (Groq Whisper) and LLM (Gemini) Blocs into the HomeTab UI, adds a Settings API-key section backed by `flutter_secure_storage`, and ships UI/UX enhancements (MicFab, AiActionChip, EmptyTasks, PriorityChip, haptics, pull-to-refresh, ARB localization). The implementation is well-structured and tests are thorough, but the quality gate currently **fails**: 1 High, 6 Medium, 2 Low findings, and 1 untested changed unit (`task_model.dart`). Zero Critical findings.

Per the `implement-review-ship` workflow, I am halting here for user approval on which fixes to apply before proceeding to the fix loop and PR.

---

## Quality Gate Assessment

| Criterion | Required | Actual | Status |
|---|---|---|---|
| Score > 90 | > 90 | ~25 (est.) | ❌ FAIL |
| Zero Critical findings | 0 | 0 | ✅ PASS |
| Zero High findings | 0 | 1 | ❌ FAIL |
| Zero Medium findings | 0 | 6 | ❌ FAIL |
| Zero untested changed units | 0 | 1 | ❌ FAIL |

**Gate result: FAILING.** The fix loop (max 3 rounds) must run before PR.

---

## Consolidated Findings (all four reviewers)

### Critical — 0

None found. No hardcoded API keys, no injection vulnerabilities, no committed secrets.

### High — 1

| ID | Severity | Finding | File(s) | Source |
|---|---|---|---|---|
| H1 | High | STT error messages can leak the Groq API key. `SttBloc` emits `SttError(message: e.toString())` unsanitized; `GroqSttService` embeds raw `response.body` (which may echo the API key) in the exception; `HomeTab` renders it verbatim in a SnackBar. Contrasts with `LlmBloc._sanitizeError`. | `lib/features/stt/stt_bloc.dart:23`, `lib/features/stt/groq_stt_service.dart:74-78`, `lib/home_tab/view/screens/home_tab.dart:172` | Code Reviewer + Security Engineer (duplicate) |

### Medium — 6

| ID | Severity | Finding | File(s) | Source |
|---|---|---|---|---|
| M1 | Medium | HomeTab constructs concrete bloc/service instances directly (`GroqSttService`, `GeminiLlmService.real`, `AudioRecorder`, `http.Client`), coupling the widget and hindering testability. Injection params exist but are not primary. | `lib/home_tab/view/screens/home_tab.dart:87-96` | Code Reviewer |
| M2 | Medium | No API key format validation. `SettingsSaveApiKeys` accepts any string; malformed keys only discovered at API-call time. | `lib/settings_tab/view_model/settings_events.dart:26-33`, `lib/settings_tab/view/widgets/api_key_section.dart:60-67` | Code Reviewer |
| M3 | Medium | `http.Client()` created but never disposed. Fallback client holds sockets with no `close()` path. | `lib/home_tab/view/screens/home_tab.dart:90` | Code Reviewer |
| M4 | Medium | `LlmBloc._sanitizeError` regex may miss edge cases (key echoed without `Bearer`/`apiKey`/URL labels). Best-effort rather than allowlist-based. | `lib/features/llm/llm_bloc.dart:46-56` | Code Reviewer |
| M5 | Medium | Microphone permission not declared on either platform. No `RECORD_AUDIO` in `AndroidManifest.xml`; no `NSMicrophoneUsageDescription` in `Info.plist`. STT flow fails at runtime on mic access. | `android/app/src/main/AndroidManifest.xml`, `ios/Runner/Info.plist` | Security Engineer |
| M6 | Medium | (Duplicate of H1 from security angle) SttBloc emits unsanitized third-party API error bodies to UI — uncontrolled information channel. | `lib/features/stt/stt_bloc.dart:23`, `lib/home_tab/view/screens/home_tab.dart:171-173` | Security Engineer |

### Low — 2

| ID | Severity | Finding | File(s) | Source |
|---|---|---|---|---|
| L1 | Low | Unchecked cast `decoded['text'] as String` on Groq response; `{}` body produces `TypeError` instead of descriptive exception. | `lib/features/stt/groq_stt_service.dart:81` | Code Reviewer |
| L2 | Low | `SttBloc` transcription guard only checks `SttTranscribing`; `SttTranscribeFile` while in `SttRecording` bypasses the guard. | `lib/features/stt/stt_bloc.dart:15-18` | Code Reviewer |

### Info — 5 (no action required)

| ID | Finding | Source |
|---|---|---|
| I1 | BLoC patterns consistent and well-implemented (sealed classes, Equatable, try/catch, error states). | Code Reviewer |
| I2 | API keys never touch plaintext hydrated storage; excluded from `SettingsModel`/`HydratedBloc`. | Code Reviewer + Security |
| I3 | `SecureStorage` is injectable for testing (constructor injection of `FlutterSecureStorage`). | Code Reviewer |
| I4 | `LlmBloc` sanitizes error messages (Bearer tokens, `apiKey=`, URLs). | Code Reviewer |
| I5 | Localization delegates correctly configured; ARB files match generated getters. | Code Reviewer |

---

### Untested changed units

| Unit | File | Status |
|---|---|---|
| `task_model.dart` (Modified) | `lib/home_tab/data/models/task_model.dart` | No dedicated `task_model_test.dart`; only touched indirectly by widget tests | Test Coverage Analyst |

`lib/main.dart` is also untested by design (app entry point).

---

## Spec Compliance (tasks 3.1–3.16)

**Tally: 8 compliant / 8 deviating (50% compliance)**

| Task | Spec Item | Status | Deviation |
|---|---|---|---|
| 3.1 | `SettingsModel` + `groqApiKey`/`googleAiApiKey` fields + `copyWith`/`toMap`/`fromMap`/`props` | ❌ DEVIATION | Fields missing entirely; deliberate security choice — keys kept only in SecureStorage, never in plaintext hydrated model |
| 3.2 | `SettingsSaveApiKeys` event | ✅ COMPLIANT | — |
| 3.3 | `SettingsBloc` save handler via `SecureStorage` | ❌ DEVIATION | Emits `SettingsApiKeysSaved(model:)` instead of `SettingsUpdateState` with `copyWith` |
| 3.4 | `ApiKeySection` widget (`required SecureStorage storage`) | ❌ DEVIATION | `storage` is optional/nullable, not `required` |
| 3.5 | Wire `ApiKeySection` into `SettingsTab` wrapped in `BlocProvider<SettingsBloc>` | ❌ DEVIATION | Not wrapped in per-section `BlocProvider` (relies on app-level provider in `main.dart`) |
| 3.6 | `MicFab` widget | ✅ COMPLIANT | — |
| 3.7 | Wire `SttBloc` into `HomeTab` | ✅ COMPLIANT | — |
| 3.8 | `AiActionChip` widget (`required VoidCallback onTap`) | ❌ DEVIATION | `onTap` is optional/nullable (`VoidCallback?`) |
| 3.9 | Wire `LlmBloc` into `HomeTab` | ❌ DEVIATION | No chip dispatching `LlmParseTask` (only breakdown + prioritize chips) |
| 3.10 | `EmptyTasks` widget | ✅ COMPLIANT | — |
| 3.11 | Replace Lottie with `EmptyTasks` in `TasksList` | ✅ COMPLIANT | — |
| 3.12 | `PriorityChip` widget | ✅ COMPLIANT | — |
| 3.13 | Priority chip on `TaskTile` | ✅ COMPLIANT | — |
| 3.14 | Haptic feedback on toggle/delete | ✅ COMPLIANT | — |
| 3.15 | Pull-to-refresh (`RefreshIndicator` in `home_tab.dart`) | ❌ DEVIATION | `RefreshIndicator` lives in `tasks_list.dart`, wraps only non-empty `ListView` |
| 3.16 | 10 ARB keys in both `intl_en.arb` and `intl_ar.arb` | ❌ DEVIATION | `save_api_keys` missing from both ARBs (9/10 present) |

Global constraints: **No `print`/`debugPrint` outside tests — PASS.** **No committed API key literals/secrets — PASS.**

---

## Test Coverage

| Category | Status |
|---|---|
| New widget tests (MicFab, AiActionChip, EmptyTasks, PriorityChip, ApiKeySection) | ✅ All 5 exist with meaningful assertions |
| New service/bloc tests (STT, LLM, SecureStorage) | ✅ Direct + integration coverage |
| Modified screen/view-model/widget tests | ✅ Matched |
| Untested changed unit: `task_model.dart` | ❌ No dedicated test file |
| Skipped disposal test in `home_tab_test.dart` | Documented (timeout, TODO present) |

---

## Decision Matrix — Recommended Fix Order

| Priority | ID | Fix | Effort | Owner | Gate Impact |
|---|---|---|---|---|---|
| 1 | H1 | Sanitize STT error messages (mirror `LlmBloc._sanitizeError`); don't embed `response.body` in exceptions | Small | Developer | Removes 1 High |
| 2 | M5 | Add `RECORD_AUDIO` to `AndroidManifest.xml` + `NSMicrophoneUsageDescription` to `Info.plist`; handle permission-denied in `SttBloc`/`MicFab` | Small | Developer | Removes 1 Medium |
| 3 | M3 | Dispose fallback `http.Client` in `HomeTab.dispose()` when `_ownsSttBloc` | Small | Developer | Removes 1 Medium |
| 4 | M2 | Add API key format validation in `SettingsBloc` before persisting | Small | Developer | Removes 1 Medium |
| 5 | M4 | Harden `LlmBloc._sanitizeError` to redact known key value itself | Small | Developer | Removes 1 Medium |
| 6 | M1 | Decouple `HomeTab` from concrete bloc/service construction (factory/DI) | Medium | Developer | Removes 1 Medium |
| 7 | L1 | Use `as String?` + descriptive exception for missing `text` field | Trivial | Developer | Removes 1 Low |
| 8 | L2 | Broaden `SttBloc` guard to also ignore `SttTranscribeFile` in `SttRecording` | Trivial | Developer | Removes 1 Low |
| 9 | Untested unit | Add `task_model_test.dart` for `task_model.dart` | Small | Developer | Removes 1 untested unit |
| 10 | Spec deviations (3.1, 3.3, 3.4, 3.5, 3.8, 3.9, 3.15, 3.16) | Align interfaces with spec (add key fields to `SettingsModel`, required `storage`, `required onTap`, parse chip, `RefreshIndicator` in `home_tab.dart`, `save_api_keys` ARB key) | Medium | Developer | Improves compliance |

**Notes:**
- Task 3.1 deviation is a deliberate security decision (keys never in plaintext hydrated storage). If the user wants `SettingsModel` to carry key fields, that reverses the security posture — confirm before changing.
- M1 (DI decoupling) is the largest fix; consider deferring to a follow-up if the gate passes without it.
- The skipped `home_tab_test` disposal test remains skipped; disposal is covered by widget + bloc tests.

---

## Next Step — Halt for User Approval

**The quality gate is FAILING.** Per the `implement-review-ship` workflow, I am halting here before applying any fixes.

**Please approve which fixes to apply.** Recommended: apply all Priority 1–8 fixes (H1, M5, M3, M2, M4, M1, L1, L2) plus the `task_model.dart` test (Priority 9), then re-run the gate. Spec deviations (Priority 10) can be addressed in this round or a follow-up depending on your preference for task 3.1 (security trade-off).

Once approved, I will:
1. Apply the approved fixes (fix loop round 1)
2. Re-run the FAST gate (format, analyze, tests)
3. Re-run QA gate evaluation
4. If gate passes → open PR with `gh pr create --base development`
5. If gate fails → fix loop round 2 (max 3 rounds total)

**Please confirm: proceed with Priority 1–9 fixes? Any deviations from the recommended order?**