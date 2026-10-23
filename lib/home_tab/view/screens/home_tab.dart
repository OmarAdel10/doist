import 'package:doist/core/storage/secure_storage.dart';
import 'package:doist/core/storage/secure_storage_keys.dart';
import 'package:doist/features/llm/gemini_llm_service.dart';
import 'package:doist/features/llm/llm_bloc.dart';
import 'package:doist/features/llm/llm_event.dart';
import 'package:doist/features/llm/llm_state.dart';
import 'package:doist/features/stt/groq_stt_service.dart';
import 'package:doist/features/stt/stt_bloc.dart';
import 'package:doist/features/stt/stt_event.dart';
import 'package:doist/features/stt/stt_state.dart';
import 'package:doist/generated/l10n.dart';
import 'package:doist/home_tab/view/widgets/ai_action_chip.dart';
import 'package:doist/home_tab/view/widgets/custom_text_field.dart';
import 'package:doist/home_tab/view/widgets/mic_fab.dart';
import 'package:doist/home_tab/view/widgets/tasks_list.dart';
import 'package:doist/home_tab/view_model/home_tab_events.dart';
import 'package:doist/home_tab/view_model/home_tab_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:record/record.dart';

/// Home tab: task entry (manual + voice), AI actions and the task list.
///
/// The [SttBloc] and [LlmBloc] are created after the Groq / Google AI API
/// keys are read from [SecureStorage]; until then a loading placeholder is
/// shown so AI features are never offered before their keys are known.
class HomeTab extends StatefulWidget {
  const HomeTab({
    super.key,
    this.secureStorage,
    this.sttBloc,
    this.llmBloc,
    this.httpClient,
  });

  /// Injectable for tests; defaults to the real secure storage.
  final SecureStorage? secureStorage;

  /// Injectable for tests; when provided the tab keeps it instead of
  /// building its own [SttBloc].
  final SttBloc? sttBloc;

  /// Injectable for tests; when provided the tab keeps it instead of
  /// building its own [LlmBloc].
  final LlmBloc? llmBloc;

  /// Injectable for tests.
  final http.Client? httpClient;

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  SttBloc? _sttBloc;
  LlmBloc? _llmBloc;
  bool _ownsSttBloc = false;
  bool _ownsLlmBloc = false;
  String _groqApiKey = '';
  String _googleApiKey = '';

  @override
  void initState() {
    super.initState();
    _sttBloc = widget.sttBloc;
    _ownsSttBloc = widget.sttBloc == null;
    _llmBloc = widget.llmBloc;
    _ownsLlmBloc = widget.llmBloc == null;
    _initBlocs();
  }

  /// Always reads the keys (so missing-key gates work even with injected
  /// blocs), then builds whichever blocs were not injected.
  Future<void> _initBlocs() async {
    final storage =
        widget.secureStorage ?? SecureStorage(const FlutterSecureStorage());
    final groqKey = await storage.read(SecureStorageKeys.groqApiKey) ?? '';
    final googleKey =
        await storage.read(SecureStorageKeys.googleAiApiKey) ?? '';
    if (!mounted) return;
    setState(() {
      _groqApiKey = groqKey;
      _googleApiKey = googleKey;
      _sttBloc ??= SttBloc(
        sttService: GroqSttService(
          apiKey: groqKey,
          httpClient: widget.httpClient ?? http.Client(),
          audioRecorder: AudioRecorder(),
        ),
      );
      _llmBloc ??= LlmBloc(
        llmService: GeminiLlmService.real(apiKey: googleKey),
      );
    });
  }

  @override
  void dispose() {
    if (_ownsSttBloc) {
      _sttBloc?.close();
    }
    if (_ownsLlmBloc) {
      _llmBloc?.close();
    }
    super.dispose();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _onMicTap() {
    // Only called when the Groq key is missing — gate the feature with a
    // hint instead of firing a doomed API call.
    _showSnack(S.of(context).missing_groq_key);
  }

  void _onBreakdownTap(LlmBloc llmBloc) {
    if (_googleApiKey.isEmpty) {
      _showSnack(S.of(context).missing_google_key);
      return;
    }
    final tasks = context.read<HomeTabBloc>().state.tasksList;
    if (tasks.isEmpty) {
      _showSnack(S.of(context).add_task_first);
      return;
    }
    llmBloc.add(LlmBreakdownTask(title: tasks.first.taskTitle));
  }

  void _onPrioritizeTap(LlmBloc llmBloc) {
    if (_googleApiKey.isEmpty) {
      _showSnack(S.of(context).missing_google_key);
      return;
    }
    final tasks = context.read<HomeTabBloc>().state.tasksList;
    if (tasks.isEmpty) {
      _showSnack(S.of(context).add_task_first);
      return;
    }
    llmBloc.add(LlmPrioritizeTasks(tasks: tasks));
  }

  @override
  Widget build(BuildContext context) {
    final sttBloc = _sttBloc;
    final llmBloc = _llmBloc;
    if (sttBloc == null || llmBloc == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final localization = S.of(context);
    return MultiBlocProvider(
      providers: [
        BlocProvider<SttBloc>.value(value: sttBloc),
        BlocProvider<LlmBloc>.value(value: llmBloc),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<SttBloc, SttState>(
            listener: (context, state) {
              if (state is SttResult) {
                context.read<HomeTabBloc>().add(
                  HomeTabAddAiTask(taskTitle: state.text),
                );
                sttBloc.add(const SttStopRecording());
              } else if (state is SttError) {
                _showSnack(state.message);
                sttBloc.add(const SttStopRecording());
              }
            },
          ),
          BlocListener<LlmBloc, LlmState>(
            listener: (context, state) {
              final homeTab = context.read<HomeTabBloc>();
              if (state is LlmBreakdown) {
                for (final subtask in state.subtasks) {
                  homeTab.add(HomeTabAddAiTask(taskTitle: subtask));
                }
                llmBloc.add(const LlmClear());
              } else if (state is LlmPrioritized) {
                final suggestions = {
                  for (final suggestion in state.suggestions)
                    suggestion.taskId: suggestion,
                };
                final reprioritized = homeTab.state.tasksList.map((task) {
                  final suggestion = suggestions[task.id];
                  return suggestion == null
                      ? task
                      : task.copyWith(priority: suggestion.newPriority);
                }).toList();
                homeTab.add(HomeTabReplaceTasks(tasks: reprioritized));
                llmBloc.add(const LlmClear());
              } else if (state is LlmParsedTask) {
                homeTab.add(HomeTabAddAiTask(taskTitle: state.task.title));
                llmBloc.add(const LlmClear());
              } else if (state is LlmError) {
                _showSnack(state.message);
                llmBloc.add(const LlmClear());
              }
            },
          ),
        ],
        child: Scaffold(
          floatingActionButton: MicFab(
            sttBloc: sttBloc,
            onTap: _groqApiKey.isEmpty ? _onMicTap : null,
          ),
          body: Column(
            children: [
              CustomTextField(),
              BlocBuilder<LlmBloc, LlmState>(
                builder: (context, state) {
                  final loading = state is LlmLoading;
                  return Row(
                    children: [
                      AiActionChip(
                        label: localization.break_down_task,
                        icon: Icons.auto_awesome,
                        onTap: loading ? null : () => _onBreakdownTap(llmBloc),
                      ),
                      const SizedBox(width: 8),
                      AiActionChip(
                        label: localization.prioritize_my_day,
                        icon: CupertinoIcons.sort_down,
                        onTap: loading ? null : () => _onPrioritizeTap(llmBloc),
                      ),
                      if (loading) ...[
                        const SizedBox(width: 8),
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 10),
              TasksList(),
            ],
          ),
        ),
      ),
    );
  }
}
