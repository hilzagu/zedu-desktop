import 'dart:io';

import 'package:zedu/core/core.dart';
import 'package:zedu/features/features.dart';

import '../../../../../helpers/helpers.dart';

// The default test font draws every glyph as a box, so load the app's real
// fonts — including the Material Icons font the check marks need — before
// capturing anything.
Future<void> loadAppFonts() async {
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

/// The signed-up destination the page's call to action points at, so the test
/// can tell the button navigated instead of only rendering.
class _SignUpDestination extends StatelessWidget {
  const _SignUpDestination();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('sign-up destination')));
}

Widget _pumpAt(String location) {
  final router = GoRouter(
    initialLocation: location,
    routes: [
      GoRoute(
        path: '/cohorts/:slug',
        builder: (context, state) =>
            PublicCohortView(slug: state.pathParameters['slug'] ?? ''),
      ),
      GoRoute(
        path: AppRouter.signup,
        builder: (context, state) => const _SignUpDestination(),
      ),
      GoRoute(
        path: AppRouter.login,
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('login destination'))),
      ),
    ],
  );
  // The outlined/filled button labels carry no font family of their own, and
  // the test font draws boxes, so the capture pins the app's body font on
  // them. Nothing else about the theme is changed.
  final elevated = AppTheme.light.elevatedButtonTheme.style!;
  final outlined = AppTheme.light.outlinedButtonTheme.style!;
  final theme = AppTheme.light.copyWith(
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: elevated.copyWith(
        textStyle: WidgetStatePropertyAll(
          elevated.textStyle!
              .resolve(const <WidgetState>{})!
              .copyWith(fontFamily: FontFamily.lato),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: outlined.copyWith(
        textStyle: WidgetStatePropertyAll(
          outlined.textStyle!
              .resolve(const <WidgetState>{})!
              .copyWith(fontFamily: FontFamily.lato),
        ),
      ),
    ),
  );

  return MaterialApp.router(
    debugShowCheckedModeBanner: false,
    theme: theme,
    routerConfig: router,
  );
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('renders the approved cohort for its slug', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_pumpAt('/cohorts/zedu-foundations'));
    await tester.pumpAndSettle();

    expect(find.text('Zedu Foundations'), findsOneWidget);
    expect(find.text('Team messaging and collaboration'), findsOneWidget);
    expect(find.text('What you need to take part'), findsOneWidget);
    expect(find.text('An email address to sign up with.'), findsOneWidget);
    expect(find.text('Cohort not found'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the call to action opens sign up', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_pumpAt('/cohorts/zedu-foundations'));
    await tester.pumpAndSettle();

    final cta = find.text('Create your free account');
    await tester.ensureVisible(cta);
    await tester.pumpAndSettle();

    await tester.tap(cta);
    await tester.pumpAndSettle();

    expect(find.text('sign-up destination'), findsOneWidget);
  });

  testWidgets('an unknown slug shows the not-found state, not content', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_pumpAt('/cohorts/not-a-cohort'));
    await tester.pumpAndSettle();

    expect(find.text('Cohort not found'), findsOneWidget);
    expect(find.text('Zedu Foundations'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('captures the published cohort page', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_pumpAt('/cohorts/zedu-foundations'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/public_cohort_view.png'),
    );
  });
}
