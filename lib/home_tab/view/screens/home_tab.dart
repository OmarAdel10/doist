import 'package:doist/core/storage/secure_storage.dart';
import 'package:doist/core/storage/secure_storage_keys.dart';
import 'package:doist/features/stt/groq_stt_service.dart';
import 'package:doist/features/stt/stt_bloc.dart';
import 'package:doist/features/stt/stt_event.dart';
import 'package:doist/features/stt/stt_state.dart';
import 'package:doist/generated/l10n.dart';
import 'package:doist/home_tab/view/widgets/custom_text_field.dart';
import 'package:doist/home_tab/view/widgets/mic_fab.dart';
import 'package:doist/home_tab/view/widgets/tasks_list.dart';
import 'package:doist/home_tab/view_model/home_tab_events.dart';
import 'package:doist/home_tab/view_model/home_tab_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:record/record.dart';

/// Home tab: task entry (manual + voice), AI actions and the task list.
///
/// The [SttBloc] is created after the Groq API key is read from
/// [SecureStorage]; until then a loading placeholder is shown so AI
/// features are never offered without their key being available.
class HomeTab extends StatefulWidget {
  const HomeTab({super.key, this.secureStorage, this.sttBloc, this.httpClient});

  /// Injectable for tests; defaults to the real secure storage.
  final SecureStorage? secureStorage;

  /// Injectable for tests; when provided the tab does not build its own
  /// [SttBloc] and skips reading the API key.
  final SttBloc? sttBloc;

  /// Injectable for tests.
  final http.Client? httpClient;

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  SttBloc? _sttBloc;
  bool _ownsSttBloc = false;
  String _groqApiKey = '';

  @override
  void initState() {
    super.initState();
    final injected = widget.sttBloc;
    if (injected != null) {
      _sttBloc = injected;
    } else {
      _ownsSttBloc = true;
      _initSttBloc();
    }
  }

  Future<void> _initSttBloc() async {
    final storage =
        widget.secureStorage ?? SecureStorage(const FlutterSecureStorage());
    final key = await storage.read(SecureStorageKeys.groqApiKey) ?? '';
    if (!mounted) return;
    setState(() {
      _groqApiKey = key;
      _sttBloc = SttBloc(
        sttService: GroqSttService(
          apiKey: key,
          httpClient: widget.httpClient ?? http.Client(),
          audioRecorder: AudioRecorder(),
        ),
      );
    });
  }

  @override
  void dispose() {
    if (_ownsSttBloc) {
      _sttBloc?.close();
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

  @override
  Widget build(BuildContext context) {
    final sttBloc = _sttBloc;
    if (sttBloc == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return BlocProvider<SttBloc>.value(
      value: sttBloc,
      child: BlocListener<SttBloc, SttState>(
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
        child: Scaffold(
          floatingActionButton: MicFab(
            sttBloc: sttBloc,
            onTap: _groqApiKey.isEmpty ? _onMicTap : null,
          ),
          body: Column(
            children: [
              CustomTextField(),
              const SizedBox(height: 10),
              TasksList(),
            ],
          ),
        ),
      ),
    );
  }
}
