import 'package:zedu/core/core.dart';
import 'package:zedu/features/features.dart';

/// The sign-in-free page for one approved cohort.
///
/// Anyone can open it: the route sits in [AppRouter]'s public paths, so a
/// visitor who has not signed in reads the page instead of being sent to the
/// login wall. Only slugs in [approvedCohorts] render content; anything else
/// shows the not-found state, so the page can never expose a cohort that
/// marketing has not approved.
class PublicCohortView extends StatefulWidget {
  const PublicCohortView({super.key, required this.slug});

  /// The slug from the URL, for example `zedu-foundations`.
  final String slug;

  @override
  State<PublicCohortView> createState() => _PublicCohortViewState();
}

class _PublicCohortViewState extends State<PublicCohortView> {
  ApprovedCohort? get _cohort => approvedCohortFor(widget.slug);

  @override
  void initState() {
    super.initState();
    final cohort = _cohort;
    if (cohort != null) {
      setPageSeo(
        title: cohort.title,
        description: cohort.summary,
        url: cohort.url,
      );
    }
  }

  @override
  void dispose() {
    restorePageSeo();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cohort = _cohort;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AuthHeaderStrip(
          promptText: 'Already have an account? ',
          actionText: 'Sign in',
          onActionTap: () => context.go(AppRouter.login),
        ),
      ),
      body: SingleChildScrollView(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 56),
              child: cohort == null
                  ? _NotFound(onSignUp: () => context.go(AppRouter.signup))
                  : _CohortBody(cohort: cohort),
            ),
          ),
        ),
      ),
    );
  }
}

class _CohortBody extends StatelessWidget {
  const _CohortBody({required this.cohort});

  final ApprovedCohort cohort;

  @override
  Widget build(BuildContext context) {
    final text = context.textTheme;
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Zedu cohort',
          style: text.labelMedium?.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(cohort.name, style: text.headlineMedium),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colors.primaryBg,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            cohort.focus,
            style: text.labelMedium?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          cohort.summary,
          style: text.titleMedium?.copyWith(
            color: colors.textSecondary,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 24),
        Text(cohort.description, style: text.bodyMedium?.copyWith(height: 1.7)),
        const SizedBox(height: 32),
        Text('What you need to take part', style: text.titleMedium),
        const SizedBox(height: 16),
        for (final requirement in cohort.requirements)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 20,
                  color: colors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    requirement,
                    style: text.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 32),
        AppButton(
          label: 'Create your free account',
          expand: false,
          onPressed: () => context.go(AppRouter.signup),
        ),
        const SizedBox(height: 12),
        Text(
          'Already use Zedu? Sign in from the top of this page.',
          style: text.bodySmall?.copyWith(color: colors.textHint),
        ),
      ],
    );
  }
}

class _NotFound extends StatelessWidget {
  const _NotFound({required this.onSignUp});

  final VoidCallback onSignUp;

  @override
  Widget build(BuildContext context) {
    final text = context.textTheme;
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Cohort not found', style: text.headlineMedium),
        const SizedBox(height: 16),
        Text(
          'This cohort page does not exist, or it is not open for '
          'registration yet. Create a free account to see the cohorts that '
          'are running now.',
          style: text.bodyMedium?.copyWith(
            color: colors.textSecondary,
            height: 1.7,
          ),
        ),
        const SizedBox(height: 32),
        AppButton(
          label: 'Create your free account',
          expand: false,
          onPressed: onSignUp,
        ),
      ],
    );
  }
}
