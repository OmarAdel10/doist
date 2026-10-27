import 'package:doist/core/storage/secure_storage.dart';
import 'package:doist/generated/l10n.dart';
import 'package:doist/settings_tab/view/screens/settings_tab.dart';
import 'package:doist/settings_tab/view/widgets/api_key_section.dart';
import 'package:doist/settings_tab/view_model/settings_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';

class _MockHydratedStorage extends Mock implements Storage {}

/// Composition test for SettingsTab: the API-key section must render
/// alongside the theme/language/about sections.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const secureStorageChannel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );

  setUp(() {
    final hydratedStorage = _MockHydratedStorage();
    when(
      () => hydratedStorage.write(any(), any<dynamic>()),
    ).thenAnswer((_) async {});
    when(() => hydratedStorage.read(any())).thenAnswer((_) async => null);
    HydratedBloc.storage = hydratedStorage;

    // ApiKeySection is built with its default (real) storage inside
    // SettingsTab, so answer the platform channel directly.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, (call) async {
          switch (call.method) {
            case 'read':
              return 'sk-test';
            case 'readAll':
              return <String, String>{};
            default:
              return null;
          }
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, null);
  });

  testWidgets('SettingsTab renders the API key section with both fields', (
    tester,
  ) async {
    await tester.pumpWidget(
      BlocProvider<SettingsBloc>(
        create: (_) =>
            SettingsBloc(SecureStorage(const FlutterSecureStorage())),
        child: MaterialApp(
          localizationsDelegates: [S.delegate],
          supportedLocales: S.delegate.supportedLocales,
          home: const Scaffold(
            body: SingleChildScrollView(child: SettingsTab()),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(ApiKeySection), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text(S().ai_api_keys), findsOneWidget);
  });
}
