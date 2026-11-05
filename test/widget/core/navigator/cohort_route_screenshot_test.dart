import 'dart:io';

import 'package:zedu/core/core.dart';
import 'package:zedu/features/features.dart';

import '../../../helpers/helpers.dart';

// Minimal signed-out auth state, so LoginView (the fallback when a cohort
// page is not published) renders without GetIt/locator setup.
class _FakeAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => const AuthState(status: AuthStatus.unauthenticated);
}

// The default test font draws every glyph as a box, so load the app's real
// fonts — including the Material Icons font the check marks need — before
// capturing anything.
Future<void> _loadAppFonts() async {
  for (final family in ['Lato', 'Roboto']) {
    final loader = FontLoader(family);
    for (final weight in ['Regular', 'Bold']) {
      final bytes = File('assets/fonts/$family/$family-$weight.ttf');
      if (bytes.existsSync()) {
        loader.addFont(
          Future.value(ByteData.sublistView(bytes.readAsBytesSync())),
        );
      }
    }
    await loader.load();
  }

  var flutterRoot = File(Platform.resolvedExecutable).parent;
  File? iconFont;
  while (flutterRoot.path != flutterRoot.parent.path) {
    for (final name in [
      'MaterialIcons-Regular.otf',
      'materialicons-regular.otf',
    ]) {
      final candidate = File(
        [
          flutterRoot.path,
          'bin',
          'cache',
          'artifacts',
          'material_fonts',
          name,
        ].join(Platform.pathSeparator),
      );
      if (candidate.existsSync()) {
        iconFont = candidate;
        break;
      }
    }
    if (iconFont != null) break;
    flutterRoot = flutterRoot.parent;
  }
  if (iconFont == null || !iconFont.existsSync()) {
    throw StateError('Flutter Material Icons font was not found.');
  }
  await (FontLoader('MaterialIcons')..addFont(
        Future.value(ByteData.sublistView(iconFont.readAsBytesSync())),
      ))
      .load();
}

// The filled button label carries no font family of its own, and the test
// font draws boxes, so the capture pins the app's body font on it. Nothing
// else about the theme is changed.
ThemeData _themeWithReadableButton() {
  final elevated = AppTheme.light.elevatedButtonTheme.style!;
  return AppTheme.light.copyWith(
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: elevated.copyWith(
        textStyle: WidgetStatePropertyAll(
          elevated.textStyle!
              .resolve(const <WidgetState>{})!
              .copyWith(fontFamily: FontFamily.lato),
        ),
      ),
    ),
  );
}

/// Opens [location] signed out through the app's real router and captures
/// whatever the visitor sees.
///
/// The file only uses router APIs that exist on the destination branch, so it
/// also runs there to produce the "before" picture: without the public route
/// the URL redirects to the login wall.
// Golden files are compared on CI's Linux runner while the committed images
// were captured on Windows, where fonts rasterise slightly differently. The
// repo's invite CTA test allows a small pixel difference for this reason;
// this does the same, at the same 5% tolerance.
class _TolerantGoldenComparator extends LocalFileComparator {
  _TolerantGoldenComparator(super.testFile, {this.tolerance = 0.05});

  final double tolerance;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final ComparisonResult result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );

    final passed = result.passed || result.diffPercent <= tolerance;
    if (passed) {
      result.dispose();
      return true;
    }

    final String error = await generateFailureOutput(result, golden, basedir);
    result.dispose();
    throw FlutterError(error);
  }
}

void _useTolerantGoldenComparator(String testFileName) {
  final currentComparator = goldenFileComparator;
  if (currentComparator is LocalFileComparator) {
    goldenFileComparator = _TolerantGoldenComparator(
      currentComparator.basedir.resolve(testFileName),
      tolerance: 0.05,
    );
  }
}

void main() {
  setUpAll(() async {
    await _loadAppFonts();
    _useTolerantGoldenComparator('cohort_route_screenshot_test.dart');
  });

  tearDown(() {
    AppRouter.authStatus.value = AuthStatus.unknown;
  });

  testWidgets('a signed-out visit to a cohort URL', (tester) async {
    tester.view.physicalSize = const Size(1440, 1024);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    AppRouter.authStatus.value = AuthStatus.unauthenticated;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authNotifierProvider.overrideWith(() => _FakeAuthNotifier()),
        ],
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: _themeWithReadableButton(),
          routerConfig: AppRouter.router,
        ),
      ),
    );
    AppRouter.router.go('/cohorts/zedu-foundations');
    await tester.pumpAndSettle();

    expect(find.byType(Scaffold), findsOneWidget);
    expect(tester.takeException(), isNull);

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/cohort_route.png'),
    );
  });
}
