# Doist — AI + UI/UX Enhancements Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` (recommended) or `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add AI (Groq Whisper Large V3 Turbo STT via HTTP API + Google AI Studio Gemini LLM) and UI/UX enhancements to the Doist Flutter todo app, with user-entered API keys stored securely per-device via `flutter_secure_storage` and input fields in the Settings screen.

**Architecture:** Three new layers under `lib/features/`: `stt/` (Groq Whisper REST API via `record` for mic capture + `http` for upload), `llm/` (Google AI Studio Gemini via `google_generative_ai`), and shared `core/storage/` (secure key vault). Each exposes a BLoC consumed by `HomeTab` UI and `SettingsTab` (API-key input). LLM powers: (1) natural-language task parsing (title + due date + priority), (2) task breakdown into subtasks, (3) smart prioritization of today's tasks. No on-device STT plugin, no key persistence in hydrated_bloc, no keys committed to git. Daily summary (item 4) explicitly deferred.

**Tech Stack:** Flutter 3.47.6 / Dart 3.13.5; `google_generative_ai: ^1.0.0` (Gemini), `http: ^1.3.0` (Groq Whisper REST), `record: ^5.4.0` (microphone audio capture), `flutter_secure_storage: ^9.0.0` (API-key vault), `flutter_animate` (already present), `bloc_test` + `mocktail` (existing test stack).

**Spec:** No existing spec file. This plan is the spec. Per SOUL §5, no out-of-scope features beyond the three LLM capabilities, Groq STT, secure key storage in Settings, and the listed UI/UX items.

---

## Current Context / Assumptions

- Repository root: `/home/omaradel/doist`; Flutter channel stable, `flutter analyze` currently green (verify before committing anything).
- Architecture: `lib/{feature}/` split into `data/models`, `view_model` (BLoC events/states/bloc), `view/screens`, `view/widgets`. State managed with `flutter_bloc`/`hydrated_bloc`. Equatable for models/events/states. `uuid` for IDs.
- Routes: `onGenerateRoute` in `lib/main.dart` maps `/home`, `/on-boarding`, `/splash`. HomeScreen owns bottom nav and tabs `HomeTab` + `SettingsTab`.
- Tests: only `test/home_tab/view_model/home_tab_view_model_test.dart` exists (bloc_test + mocktail). No widget/integration tests.
- Existing deps relevant: `flutter_slidable` (delete), `flutter_animate` (transitions), `hydrated_bloc` (persistence).
- No CI workflow for lint/analyze/test on non-master branches (`.github/workflows/` has only `cd.yml`, `shorebird_ci.yaml`, `dependabot.yml`).
- `pubspec.yaml` SDK: `^3.9.2`. Android/iOS present but not yet configured for microphone permissions (needed for audio recording).
- API key strategy: user enters Groq + Google AI keys in Settings screen; stored in `flutter_secure_storage` (Keychain/EncryptedSharedPreferences); never in source, never committed, never in hydrated_bloc.

Assumptions to confirm with user (open questions at end):
- Groq endpoint: `https://api.groq.com/openai/v1/audio/transcriptions` — confirm or correct.
- Google AI Studio model: `gemini-1.5-flash` — confirm.
- Should CI lint/analyze/test workflow be added.

---

## Review Focus (inputs/failure modes most likely to bite)

1. Missing microphone permission → audio recording crashes; handle `record` permission errors gracefully with fallback UI.
2. Missing/invalid Groq or Google AI key → corresponding AI feature disabled silently, app still usable (no hard crash, no key leaked).
3. Groq returns non-200 or malformed transcript → `SttBloc` emits `SttError`, UI shows retry + "add key in Settings" hint.
4. LLM returns unparseable JSON → fallback to raw text, never crash the task parser.
5. Empty task list after delete/all-checked → empty-state widget must render instead of blank screen.
6. `flutter_secure_storage` reads are async — UI must handle loading state before showing AI features.
7. API keys lost on app uninstall — acceptable; user re-enters in Settings.

---

## File Map (create / modify)

| File | Action | Responsibility |
|------|--------|----------------|
| `pubspec.yaml` | Modify | Add `google_generative_ai`, `http`, `record`, `flutter_secure_storage` |
| `lib/core/storage/secure_storage_keys.dart` | Create | Key name constants (`groqApiKey`, `googleAiApiKey`) |
| `lib/core/storage/secure_storage.dart` | Create | `flutter_secure_storage` wrapper (get/set/delete) |
| `lib/features/stt/stt_service.dart` | Create | Abstract `SttService` (record + transcribe) |
| `lib/features/stt/groq_stt_service.dart` | Create | Concrete: record via `record`, POST audio to Groq Whisper |
| `lib/features/stt/stt_bloc.dart` | Create | `SttBloc` + `SttEvent`/`SttState` |
| `lib/features/stt/stt_event.dart` | Create | `SttStartRecording`, `SttStopRecording`, `SttTranscribeFile` |
| `lib/features/stt/stt_state.dart` | Create | `SttInitial`, `SttRecording`, `SttTranscribing`, `SttResult`, `SttError` |
| `lib/features/llm/llm_service.dart` | Create | Abstract `LlmService` + data classes (`ParsedTask`, `TaskSuggestion`) |
| `lib/features/llm/gemini_llm_service.dart` | Create | Concrete: Gemini calls for parse/breakdown/prioritize |
| `lib/features/llm/llm_bloc.dart` | Create | `LlmBloc` orchestrating 3 capabilities |
| `lib/features/llm/llm_event.dart` | Create | `LlmParseTask`, `LlmBreakdownTask`, `LlmPrioritizeTasks`, `LlmClear` |
| `lib/features/llm/llm_state.dart` | Create | States per capability + error |
| `lib/home_tab/data/models/task_model.dart` | Modify | Add `dueDate`, `priority`; backward-compatible hydration |
| `lib/home_tab/view_model/home_tab_events.dart` | Modify | Add `HomeTabEditTask`, `HomeTabSetPriority`, `HomeTabAddAiTask`, `HomeTabPrioritizeTasks` |
| `lib/home_tab/view_model/home_tab_view_model.dart` | Modify | Handle new events; hydration intact |
| `lib/home_tab/view/screens/home_tab.dart` | Modify | Mic FAB, pull-to-refresh, empty state, AI action chips, priority chips |
| `lib/home_tab/view/widgets/task_tile.dart` | Modify | Priority chip, due date, edit on tap |
| `lib/home_tab/view/widgets/empty_tasks.dart` | Create | Empty-state illustration + hint |
| `lib/home_tab/view/widgets/priority_chip.dart` | Create | Colored priority chip |
| `lib/home_tab/view/widgets/ai_action_chip.dart` | Create | "Break down task" / "Prioritize my day" chips |
| `lib/settings_tab/view/screens/settings_tab.dart` | Modify | Add API-key section (Groq + Google AI input fields) |
| `lib/settings_tab/view/widgets/api_key_section.dart` | Create | Two secure text fields + save via `SecureStorage` |
| `lib/settings_tab/view_model/settings_events.dart` | Modify | Add `SettingsSaveApiKeys` |
| `lib/settings_tab/view_model/settings_states.dart` | Modify | Add API-key state fields |
| `lib/settings_tab/view_model/settings_view_model.dart` | Modify | Handle key save via `SecureStorage` |
| `lib/l10n/intl_en.arb` + `intl_ar.arb` | Modify | New localized strings |
| `android/app/src/main/AndroidManifest.xml` | Modify | `RECORD_AUDIO` permission |
| `ios/Runner/Info.plist` | Modify | `NSMicrophoneUsageDescription` |
| `.github/workflows/ci.yml` | Create | lint + analyze + test on push/PR (optional) |
| `test/core/storage/secure_storage_test.dart` | Create | Mock `FlutterSecureStorage` |
| `test/features/stt/groq_stt_service_test.dart` | Create | Mock http client, verify Groq request |
| `test/features/stt/stt_bloc_test.dart` | Create | bloc_test for recording/transcribe flow |
| `test/features/llm/gemini_llm_service_test.dart` | Create | Mock `GenerativeModel`, verify JSON parsing |
| `test/features/llm/llm_bloc_test.dart` | Create | bloc_test for parse/breakdown/prioritize |
| `test/home_tab/view_model/home_tab_view_model_test.dart` | Modify | Add edit/priority/AI-add/prioritize tests |

---

## Global Constraints

- Dart SDK `^3.9.2`; Flutter 3.47.6.
- Every commit via `emoji-commit` skill; every commit passes FAST gate (`dart format --set-exit-if-changed lib test`, `flutter analyze` exit 0, no `print`/`debugPrint` outside tests, no secrets).
- No direct commits to `development`/`master`; work on feature branch.
- **No API keys committed** — keys live only in `flutter_secure_storage` at runtime, entered by user in Settings UI. Code contains no key literals.
- YAGNI: STT (Groq Whisper), LLM (Gemini: parse/breakdown/prioritize), secure key storage, six UI/UX items. No chat history, no TTS, no daily summary (#4), no cloud sync.
- Audio recording requires platform mic permissions (AndroidManifest + Info.plist).

---

## Step-by-Step Tasks

### Phase 0 — Setup (dependencies + secure storage)

#### Task 0.1: Create feature branch

**Files:** none (git operation)

- [ ] **Step 1:** `git checkout -b feature/ai-ux-enhancements`
  - Expected: `Switched to a new branch 'feature/ai-ux-enhancements'`
- [ ] **Step 2:** `git branch --show-current`
  - Expected: `feature/ai-ux-enhancements`

#### Task 0.2: Add AI + STT + secure storage dependencies

**Files:** Modify: `pubspec.yaml`

- [ ] **Step 1:** Add under `dependencies:`:
  ```yaml
  google_generative_ai: ^1.0.0
  http: ^1.3.0
  record: ^5.4.0
  flutter_secure_storage: ^9.0.0
  ```
- [ ] **Step 2:** `flutter pub get`
  - Expected: exits 0, no solver errors; `pubspec.lock` updated.
- [ ] **Step 3:** `flutter analyze`
  - Expected: exit 0 (no new issues).

Commit: `git add pubspec.yaml pubspec.lock` → `emoji-commit` (feat(deps): add google_generative_ai, http, record, flutter_secure_storage).

#### Task 0.3: Secure storage key constants

**Files:**
- Create: `lib/core/storage/secure_storage_keys.dart`

**Interfaces:** Produces `SecureStorageKeys.groqApiKey`, `SecureStorageKeys.googleAiApiKey`.

- [ ] **Step 1:** Create file:
  ```dart
  class SecureStorageKeys {
    SecureStorageKeys._();

    static const String groqApiKey = 'groq_api_key';
    static const String googleAiApiKey = 'google_ai_api_key';
  }
  ```
- [ ] **Step 2:** `flutter analyze lib/core/storage/` → exit 0.
- [ ] **Step 3:** Commit.

#### Task 0.4: Secure storage wrapper (TDD)

**Files:**
- Create: `lib/core/storage/secure_storage.dart`
- Create: `test/core/storage/secure_storage_test.dart`

**Interfaces:** `class SecureStorage { Future<String?> read(String key); Future<void> write(String key, String value); Future<void> delete(String key); }` backed by `FlutterSecureStorage`.

- [ ] **Step 1:** Write failing test:
  ```dart
  // test/core/storage/secure_storage_test.dart
  import 'package:doist/core/storage/secure_storage.dart';
  import 'package:flutter_test/flutter_test.dart';
  import 'package:mocktail/mocktail.dart';
  import 'package:flutter_secure_storage/flutter_secure_storage.dart';

  class _MockStorage extends Mock implements FlutterSecureStorage {}

  void main() {
    late SecureStorage storage;
    late FlutterSecureStorage mock;

    setUp(() {
      mock = _MockStorage();
      storage = SecureStorage(mock);
    });

    test('read returns null when key missing', () async {
      when(() => mock.read(key: anyNamed('key'))).thenAnswer((_) async => null);
      final result = await storage.read(SecureStorageKeys.groqApiKey);
      expect(result, isNull);
    });

    test('write calls underlying storage with key and value', () async {
      when(() => mock.write(key: anyNamed('key'), value: anyNamed('value')))
          .thenAnswer((_) async => {});
      await storage.write(SecureStorageKeys.googleAiApiKey, 'secret');
      verify(() => mock.write(key: SecureStorageKeys.googleAiApiKey, value: 'secret')).called(1);
    });
  }
  ```
  Run: `flutter test test/core/storage/secure_storage_test.dart`
  Expected: FAIL — `SecureStorage` not found.
- [ ] **Step 2:** Create `lib/core/storage/secure_storage.dart`:
  ```dart
  import 'package:flutter_secure_storage/flutter_secure_storage.dart';
  import 'secure_storage_keys.dart';

  class SecureStorage {
    final FlutterSecureStorage _storage;
    SecureStorage(this._storage);

    Future<String?> read(String key) => _storage.read(key: key);

    Future<void> write(String key, String value) =>
        _storage.write(key: key, value: value);

    Future<void> delete(String key) => _storage.delete(key: key);
  }
  ```
- [ ] **Step 3:** Run test — PASS (2 tests). `flutter analyze lib/core/storage/` → exit 0.
- [ ] **Step 4:** Commit.

### Phase 1 — STT: Groq Whisper Large V3 Turbo

#### Task 1.1: SttService abstract + Groq implementation

**Files:**
- Create: `lib/features/stt/stt_service.dart`
- Create: `lib/features/stt/groq_stt_service.dart`

**Interfaces:**
- `abstract class SttService { Future<String> recordAndTranscribe(); }`
- `class GroqSttService implements SttService` — constructor `{required this.apiKey, required this.httpClient, required this.audioRecorder}`. Uses `record` to record to a temp file, then `http.MultipartRequest` POST to `https://api.groq.com/openai/v1/audio/transcriptions` with fields `model: whisper-large-v3-turbo`, `response_format: json`, and the audio file.

- [ ] **Step 1:** Write failing test:
  ```dart
  // test/features/stt/groq_stt_service_test.dart
  import 'package:doist/features/stt/groq_stt_service.dart';
  import 'package:http/http.dart' as http;
  import 'package:mocktail/mocktail.dart';
  import 'package:test/test.dart';
  import 'package:record/record.dart';

  class _MockClient extends Mock implements http.Client {}
  class _MockAudioRecorder extends Mock implements AudioRecorder {}

  void main() {
    test('transcribes audio via Groq Whisper with model whisper-large-v3-turbo', () async {
      final client = _MockClient();
      when(() => client.send(any())).thenAnswer((_) async =>
          http.StreamedResponse(
            Stream.value(utf8.encode('{"text":"Buy milk"}')), 200,
          ));
      final recorder = _MockAudioRecorder();
      when(() => recorder.start(any(), anyNamed('path'))).thenAnswer((_) async {});
      when(() => recorder.stop()).thenAnswer((_) async => 'path/to/audio.wav');
      when(() => recorder.dispose()).thenAnswer((_) async {});

      final service = GroqSttService(
        apiKey: 'k',
        httpClient: client,
        audioRecorder: recorder,
      );
      final result = await service.recordAndTranscribe();
      expect(result, 'Buy milk');

      verify(() => client.send(captureAny)).called(1);
      final req = verify(() => client.send(captureAny)).captured.single as http.MultipartRequest;
      expect(req.fields['model'], 'whisper-large-v3-turbo');
    });
  }
  ```
  Run: `flutter test test/features/stt/groq_stt_service_test.dart`
  Expected: FAIL — `GroqSttService` not found.
- [ ] **Step 2:** Create `stt_service.dart` (abstract).
- [ ] **Step 3:** Create `groq_stt_service.dart` with `record` + `http` implementation.
- [ ] **Step 4:** Run test — PASS. `flutter analyze lib/features/stt/` → exit 0.
- [ ] **Step 5:** Commit.

#### Task 1.2: SttBloc + SttEvent/SttState

**Files:**
- Create: `lib/features/stt/stt_event.dart`
- Create: `lib/features/stt/stt_state.dart`
- Create: `lib/features/stt/stt_bloc.dart`

**Interfaces:**
- `SttEvent`: `SttStartRecording`, `SttStopRecording`, `SttTranscribeFile({required String filePath})`.
- `SttState`: `SttInitial`, `SttRecording`, `SttTranscribing`, `SttResult({required String text})`, `SttError({required String message})`.
- `SttBloc({required SttService sttService})`.

- [ ] **Step 1:** Write failing bloc_test.
- [ ] **Step 2:** Create the three files (equatable, sealed, following HomeTabBloc conventions).
- [ ] **Step 3:** Run test — PASS. `flutter analyze` → exit 0.
- [ ] **Step 4:** Commit.

#### Task 1.3: Wire STT + LLM Blocs into HomeTabBloc (add AI task)

**Files:** Modify: `lib/home_tab/view_model/home_tab_events.dart`, `lib/home_tab/view_model/home_tab_view_model.dart`

**Interfaces:** New events `HomeTabAddAiTask({required String taskTitle})`, `HomeTabPrioritizeTasks({required List<TaskModel> tasks})` → `HomeTabBloc` emits `HomeTabUpdate` with task prepended / reprioritized list.

- [ ] **Step 1:** Write failing test addition to existing bloc test:
  ```dart
  blocTest<HomeTabBloc, HomeTabState>(
    'emits [HomeTabUpdate] when HomeTabAddAiTask is added',
    build: () => homeTabBloc,
    act: (bloc) => bloc.add(const HomeTabAddAiTask(taskTitle: 'AI task')),
    expect: () => [
      isA<HomeTabUpdate>().having((s) => s.tasksList.length, 'len', 1),
    ],
  );
  ```
  Run: `flutter test test/home_tab/view_model/home_tab_view_model_test.dart`
  Expected: FAIL — `HomeTabAddAiTask` not found.
- [ ] **Step 2:** Add event classes to `home_tab_events.dart`:
  ```dart
  class HomeTabAddAiTask extends HomeTabEvents {
    final String taskTitle;
    const HomeTabAddAiTask({required this.taskTitle});
    @override
    List<Object?> get props => [taskTitle];
  }

  class HomeTabPrioritizeTasks extends HomeTabEvents {
    final List<TaskModel> tasks;
    const HomeTabPrioritizeTasks({required this.tasks});
    @override
    List<Object?> get props => [tasks];
  }
  ```
- [ ] **Step 3:** Add handlers to `home_tab_view_model.dart`:
  ```dart
  on<HomeTabAddAiTask>((event, emit) {
    final model = TaskModel(taskTitle: event.taskTitle);
    emit(HomeTabUpdate(tasksList: [model, ...state.tasksList]));
  });

  on<HomeTabPrioritizeTasks>((event, emit) {
    emit(HomeTabUpdate(tasksList: event.tasks));
  });
  ```
- [ ] **Step 4:** Run test — PASS. `flutter analyze lib/home_tab/` → exit 0.
- [ ] **Step 5:** Commit.

### Phase 2 — LLM: Google AI Studio Gemini

#### Task 2.1: LlmService abstract + Gemini implementation

**Files:**
- Create: `lib/features/llm/llm_service.dart`
- Create: `lib/features/llm/gemini_llm_service.dart`

**Interfaces:**
- `abstract class LlmService { Future<ParsedTask> parseNaturalLanguage(String input); Future<List<String>> breakdownTask(String title); Future<List<TaskSuggestion>> prioritizeTasks(List<TaskModel> tasks); }`
- Data classes: `ParsedTask({required String title, DateTime? dueDate, required TaskPriority priority})`, `TaskSuggestion({required String taskId, required String reason, required TaskPriority newPriority})`.
- `GeminiLlmService` — constructor `{required this.apiKey, GenerativeModel? model}`. Three methods with structured prompts asking Gemini for JSON output; parses with fallback to raw text.

- [ ] **Step 1:** Write failing test for `parseNaturalLanguage` with mocked `GenerativeModel` returning JSON.
- [ ] **Step 2:** Create `llm_service.dart` (abstract + data classes).
- [ ] **Step 3:** Create `gemini_llm_service.dart` (GenerativeModel constructor injection for testability).
- [ ] **Step 4:** Run test — PASS. `flutter analyze lib/features/llm/` → exit 0.
- [ ] **Step 5:** Commit.
    }

    void dispose() {
      _controller.close();
    }
  }
  ```
- [ ] **Step 4:** Run test — PASS. `flutter analyze lib/features/voice/` → exit 0.
- [ ] **Step 5:** Commit.

#### Task 2.2: VoiceBloc + VoiceEvent/VoiceState

**Files:**
- Create: `lib/features/voice/voice_event.dart`
- Create: `lib/features/voice/voice_state.dart`
- Create: `lib/features/voice/voice_bloc.dart`

**Interfaces:**
- `VoiceEvent`: `VoiceStartListening({required Locale locale})`, `VoiceStopListening`, `VoiceClearResult`.
- `VoiceState`: `VoiceInitial`, `VoiceListening`, `VoiceResult({required String text})`, `VoiceError({required String message})`.
- `VoiceBloc({required VoiceService voiceService})`.

- [ ] **Step 1:** Write failing bloc_test (listen/stop flow).
- [ ] **Step 2:** Create the three files following HomeTabBloc conventions (equatable, sealed).
- [ ] **Step 3:** Run test — PASS. `flutter analyze` → exit 0.
- [ ] **Step 4:** Commit.

### Phase 3 — Task model enrichment (priority, timestamps)

#### Task 3.1: Add priority + createdAt to TaskModel

**Files:** Modify: `lib/home_tab/data/models/task_model.dart`

#### Task 3.1: Add dueDate + priority to TaskModel

**Files:** Modify: `lib/home_tab/data/models/task_model.dart`

**Interfaces:** Add `TaskPriority priority` enum + `DateTime? dueDate`; update `copyWith`, `toMap`, `fromMap`, props. Hydration: store `priority.index` and `dueDate?.toIso8601String()`; backward-compatible for old entries (missing keys → defaults).

- [ ] **Step 1:** Write failing test additions.
- [ ] **Step 2:** Modify model:
  ```dart
  enum TaskPriority { low, medium, high }

  class TaskModel extends Equatable {
    final String id;
    final bool isChecked;
    final String taskTitle;
    final TaskPriority priority;
    final DateTime? dueDate;

    TaskModel({
      String? id,
      this.isChecked = false,
      required this.taskTitle,
      this.priority = TaskPriority.medium,
      this.dueDate,
    }) : id = id ?? const Uuid().v4();

    TaskModel copyWith({String? id, bool? isChecked, String? taskTitle,
                        TaskPriority? priority, DateTime? dueDate}) {...}
    Map<String, dynamic> toMap() => {...,
      'priority': priority.index,
      'dueDate': dueDate?.toIso8601String(),
    };
    factory TaskModel.fromMap(Map map) => TaskModel(
      id: map['id'] as String?,
      isChecked: map['isChecked'] as bool? ?? false,
      taskTitle: map['taskTitle'] as String,
      priority: TaskPriority.values[map['priority'] as int? ?? 1],
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate'] as String) : null,
    );
  }
  ```
- [ ] **Step 3:** Run model tests — PASS. `flutter analyze` → exit 0.
- [ ] **Step 4:** Commit.

#### Task 3.2: Edit task + set priority + AI-add + prioritize events

**Files:** Modify: `home_tab_events.dart`, `home_tab_view_model.dart`

**Interfaces:** `HomeTabEditTask`, `HomeTabSetPriority`, `HomeTabAddAiTask`, `HomeTabPrioritizeTasks`.

- [ ] **Step 1:** Write failing bloc_tests.
- [ ] **Step 2:** Add events + handlers.
- [ ] **Step 3:** Run tests — PASS. `flutter analyze` → exit 0.
- [ ] **Step 4:** Commit.

### Phase 4 — Platform mic permissions

#### Task 4.1: Android RECORD_AUDIO permission

**Files:** Modify: `android/app/src/main/AndroidManifest.xml`

- [ ] **Step 1:** Add `<uses-permission android:name="android.permission.RECORD_AUDIO" />` inside `<manifest>`.
- [ ] **Step 2:** Verify file contains the permission line.
- [ ] **Step 3:** Commit.

#### Task 4.2: iOS NSMicrophoneUsageDescription

**Files:** Modify: `ios/Runner/Info.plist`

- [ ] **Step 1:** Add `<key>NSMicrophoneUsageDescription</key><string>Doist needs microphone access to record voice input for tasks.</string>`.
- [ ] **Step 2:** Verify plist is valid XML (`plutil -lint ios/Runner/Info.plist`).
- [ ] **Step 3:** Commit.

### Phase 5 — Settings: API key input fields

#### Task 5.1: API key section widget

**Files:** Create: `lib/settings_tab/view/widgets/api_key_section.dart`

**Interfaces:** `ApiKeySection({required SecureStorage storage})` — two `TextField`s (Groq API Key, Google AI API Key), obscure text, Save button writes via `SecureStorage`, shows success snackbar.

- [ ] **Step 1:** Write widget test (entering text + save calls storage.write).
- [ ] **Step 2:** Create widget.
- [ ] **Step 3:** Run test — PASS. `flutter analyze` → exit 0.
- [ ] **Step 4:** Commit.

#### Task 5.2: Wire API key section into SettingsTab

**Files:** Modify: `lib/settings_tab/view/screens/settings_tab.dart`

- [ ] **Step 1:** Add `ApiKeySection` below AboutSection, gated by `BlocProvider<SettingsBloc>` providing `SecureStorage`.
- [ ] **Step 2:** `flutter analyze` → exit 0. `flutter test` (full suite) — all pass.
- [ ] **Step 3:** Commit.

### Phase 6 — UI/UX enhancements (HomeTab)

#### Task 6.1: Priority chip widget

**Files:** Create: `lib/home_tab/view/widgets/priority_chip.dart`

**Interfaces:** `PriorityChip({required TaskPriority priority})` — low=green, medium=amber, high=red; uses `AppTheme`/`FontManager`.

- [ ] **Step 1:** Write widget test.
- [ ] **Step 2:** Create widget.
- [ ] **Step 3:** Run test — PASS. `flutter analyze` → exit 0.
- [ ] **Step 4:** Commit.

#### Task 6.2: Empty tasks widget

**Files:** Create: `lib/home_tab/view/widgets/empty_tasks.dart`

**Interfaces:** `EmptyTasks()` — illustration/icon + "No tasks yet" + hint; `flutter_animate` fade-in.

- [ ] **Step 1:** Write widget test.
- [ ] **Step 2:** Create widget.
- [ ] **Step 3:** Run test — PASS.
- [ ] **Step 4:** Commit.

#### Task 6.3: AI action chip widget

**Files:** Create: `lib/home_tab/view/widgets/ai_action_chip.dart`

**Interfaces:** `AiActionChip({required String label, required VoidCallback onTap})` — chip for "Break down task" / "Prioritize my day".

- [ ] **Step 1:** Write widget test.
- [ ] **Step 2:** Create widget.
- [ ] **Step 3:** Run test — PASS.
- [ ] **Step 4:** Commit.

#### Task 6.4: HomeTab screen — mic FAB, pull-to-refresh, empty state, AI chips

**Files:** Modify: `lib/home_tab/view/screens/home_tab.dart`, `lib/home_tab/view/widgets/task_tile.dart`

**Interfaces:** HomeTab builds `RefreshIndicator` over `TasksList`, `EmptyTasks` when empty, mic FAB triggers `SttBloc`, `AiActionChip`s when LLM keys configured, `PriorityChip` + due date on each tile, tap tile → edit dialog (`HomeTabEditTask`).

- [ ] **Step 1:** Write widget tests (empty state, mic FAB opens recording).
- [ ] **Step 2:** Modify `task_tile.dart` (priority chip, due date, edit on tap).
- [ ] **Step 3:** Rewrite `home_tab.dart` with `BlocProvider<SttBloc>`/`BlocProvider<LlmBloc>`, `RefreshIndicator`, `EmptyTasks`, mic FAB.
- [ ] **Step 4:** Run widget tests — PASS. `flutter analyze lib/home_tab/` → exit 0. `flutter test` — all pass.
- [ ] **Step 5:** Commit.

#### Task 6.5: Haptic feedback on toggle/delete

**Files:** Modify: `lib/home_tab/view/widgets/task_tile.dart`

- [ ] **Step 1:** Add `HapticFeedback.lightImpact()` on check toggle; `mediumImpact()` on delete (`dart:ui`).
- [ ] **Step 2:** `flutter analyze` → exit 0.
- [ ] **Step 3:** Commit.

### Phase 7 — Localization

#### Task 7.1: Add new strings to ARB files

**Files:** Modify: `lib/l10n/intl_en.arb`, `lib/l10n/intl_ar.arb`

**Interfaces:** New keys: `stt_listening`, `stt_transcribing`, `groq_api_key`, `google_ai_api_key`, `save_api_keys`, `api_keys_saved`, `no_tasks_yet`, `add_first_task`, `priority_low/medium/high`, `break_down_task`, `prioritize_my_day`, `edit_task`.

- [ ] **Step 1:** Add entries to both ARB files.
- [ ] **Step 2:** `flutter gen-l10n` (or manually update `lib/generated/intl/messages_*.dart` + `l10n.dart`) — `flutter analyze` → exit 0.
- [ ] **Step 3:** Commit.

### Phase 8 — CI (optional but recommended)

#### Task 8.1: Add CI workflow

**Files:** Create: `.github/workflows/ci.yml`

**Interfaces:** Runs on push to all branches + PR; steps: checkout, flutter setup, `dart format --set-exit-if-changed lib test`, `flutter analyze`, `flutter test`.

- [ ] **Step 1:** Create workflow (copy structure from existing `cd.yml`).
- [ ] **Step 2:** Validate YAML.
- [ ] **Step 3:** Commit.

---

## Tests / Validation

TDD per task (write failing test → run → implement → run → commit), per SOUL §6:

- **Unit (BLoC/service):** `bloc_test` + `mocktail`, matching existing test pattern. Cover: initial states, each event → expected states, error paths (missing key → disabled, Groq 500 → `SttError`, Gemini parse failure → `LlmError`).
- **Widget:** `flutter_test` `testWidgets` for `PriorityChip`, `EmptyTasks`, `AiActionChip`, `ApiKeySection`, `HomeTab` (empty state, mic FAB).
- **Full gate before any merge:** `dart format --set-exit-if-changed lib test`; `flutter analyze` exit 0; `flutter test` all pass; `flutter build apk --debug` compiles.
- No `print`/`debugPrint` outside tests; no secrets in diff (review `git diff --staged` before commit via pre-commit leakage check, SOUL.md §3).

Exact verification commands:
- `flutter test` → all tests pass, exit 0.
- `flutter analyze` → exit 0 ("No issues found!").
- `dart format --set-exit-if-changed lib test` → exit 0.
- `flutter build apk --debug` → "Built build/app/outputs/flutter-apk/app-debug.apk".

---

## Risks, Tradeoffs, Open Questions

**Risks:**
- Groq Whisper requires microphone audio recorded locally (`record` package) then uploaded — Android `RECORD_AUDIO` + iOS `NSMicrophoneUsageDescription` required (Phase 4).
- Free-tier rate limits on Groq/Google AI — UI should show graceful degradation, not crash.
- LLM JSON parsing may fail — every LLM method must have a text fallback and never throw uncaught.
- `flutter_secure_storage` on iOS/Android uses Keychain/EncryptedSharedPreferences; must be mocked in tests (done via `mocktail`).
- API keys never leave device; if user uninstalls app, keys are lost (acceptable — re-enter in Settings).

**Tradeoffs:**
- Single `LlmBloc` for 3 capabilities vs. separate blocs — chosen for simplicity; events are disjoint.
- `GroqSttService` takes `http.Client` and `AudioRecorder` as constructor args for testability.
- Constructor-injected `GenerativeModel` for Gemini tests.
- `TaskPriority` stored as `index` in hydration map — stable as long as enum order doesn't change; document this.

**Open questions (confirm with user before execution):**
1. Groq endpoint: `https://api.groq.com/openai/v1/audio/transcriptions` — correct?
2. Google AI Studio model: `gemini-1.5-flash` — correct?
3. Should CI lint/analyze/test workflow be added (Task 8.1)?
4. Any additional localization beyond en/ar needed?

---

## Execution Handoff

Plan saved to `.hermes/plans/2026-10-20_205006-doist-ai-ux-enhancements.md`. Please review. Does it capture what you want? If yes, choose an execution approach:

- **Subagent-driven** (recommended — new BLoC/service boundaries mean interface mismatches between tasks are the main risk; fresh reviewer per task catches them early)
- **Native** (I implement every task in this session, one reviewer at the end)

Which approach should we use?