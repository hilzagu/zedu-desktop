/// The origin the public web build is published from. `web/sitemap.xml` and
/// `web/robots.txt` point at the same host, so a canonical URL written here
/// and a sitemap entry can never disagree.
const String kZeduPublicOrigin = 'https://zedu.chat';

/// A cohort page that anyone can read without signing in.
///
/// The page is content for people who have not joined Zedu yet, so it carries
/// only what marketing has approved for publication: a name, a focus, a short
/// summary, a description and the participation requirements.
class ApprovedCohort {
  const ApprovedCohort({
    required this.slug,
    required this.name,
    required this.focus,
    required this.summary,
    required this.description,
    required this.requirements,
  });

  /// The last path segment of the page, for example `zedu-foundations`.
  final String slug;

  /// The cohort or programme name shown as the page heading.
  final String name;

  /// The subject or learning focus, shown as the page's tag line.
  final String focus;

  /// One or two sentences; also the page's meta description.
  final String summary;

  /// The full description of the learning opportunity.
  final String description;

  /// What a participant needs before joining, in the order they are listed.
  final List<String> requirements;

  /// The route that publishes this cohort.
  String get path => '/cohorts/$slug';

  /// The browser tab title for the page.
  String get title => '$name | Zedu';

  /// The canonical URL of the page, used for Open Graph and the sitemap.
  String get url => '$kZeduPublicOrigin$path';
}

/// The cohorts approved for publication.
///
/// This list is the whole publication surface: a slug that is not here renders
/// the not-found state instead of any cohort data, so private cohort
/// information can never leak through the public route.
const List<ApprovedCohort> approvedCohorts = [
  ApprovedCohort(
    slug: 'zedu-foundations',
    name: 'Zedu Foundations',
    focus: 'Team messaging and collaboration',
    summary:
        'Learn how Zedu brings a team together with channels, direct messages '
        'and shared workspaces, and publish your first cohort page that '
        'search engines can find.',
    description:
        'Zedu Foundations is the introductory cohort for teams starting on '
        'Zedu. Over the course of the cohort you set up a workspace, organise '
        'work into channels, hold conversations in direct messages and share '
        'files in context, so your team has one place to talk and work. '
        'Sessions are hands-on: every participant leaves with a workspace '
        'their team can keep using.',
    requirements: [
      'A computer with Zedu Desktop installed, or a modern web browser.',
      'An email address to sign up with.',
      'A team or study group you can invite while you practise.',
    ],
  ),
];

/// The published cohort for [slug], or `null` when it is not approved for
/// publication.
ApprovedCohort? approvedCohortFor(String slug) {
  for (final cohort in approvedCohorts) {
    if (cohort.slug == slug) return cohort;
  }
  return null;
}
