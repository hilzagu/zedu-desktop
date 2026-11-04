import 'package:web/web.dart' as web;

/// The title and description `web/index.html` ships with, so leaving a public
/// page puts the document back the way the app was built.
const String _defaultTitle = 'Zedu | Team Messaging & Collaboration';
const String _defaultDescription =
    'Bring your team together in Zedu with team messaging, organized channels, '
    'and shared workspaces for collaboration.';

/// Marks the tags a public page added, so [restorePageSeo] can remove exactly
/// them and leave the tags `index.html` already had alone.
const String _addedAttribute = 'data-zedu-page-seo';

/// Publishes [title], [description] and the canonical [url] of the page the
/// visitor is on: the browser tab, the meta description, the Open Graph tags a
/// shared link renders with, and the Twitter card.
void setPageSeo({
  required String title,
  required String description,
  required String url,
}) {
  final document = web.document;
  document.title = title;
  _setMeta(document, 'name', 'description', description);
  _setMeta(document, 'property', 'og:title', title);
  _setMeta(document, 'property', 'og:description', description);
  _setMeta(document, 'name', 'twitter:title', title);
  _setMeta(document, 'name', 'twitter:description', description);
  // `index.html` has no canonical URL or Open Graph URL yet, so these two are
  // created here and removed again in [restorePageSeo].
  _setMeta(document, 'property', 'og:url', url, added: true);
  _setCanonical(document, url);
}

/// Puts the document metadata back to the values the app was built with.
void restorePageSeo() {
  final document = web.document;
  document.title = _defaultTitle;
  _setMeta(document, 'name', 'description', _defaultDescription);
  _setMeta(document, 'property', 'og:title', _defaultTitle);
  _setMeta(document, 'property', 'og:description', _defaultDescription);
  _setMeta(document, 'name', 'twitter:title', _defaultTitle);
  _setMeta(document, 'name', 'twitter:description', _defaultDescription);

  final added = document.querySelectorAll('[$_addedAttribute]');
  for (var i = 0; i < added.length; i++) {
    final node = added.item(i);
    if (node != null) node.parentNode?.removeChild(node);
  }
}

void _setMeta(
  web.Document document,
  String attribute,
  String key,
  String value, {
  bool added = false,
}) {
  var meta = document.querySelector('meta[$attribute="$key"]');
  if (meta == null) {
    meta = document.createElement('meta');
    meta.setAttribute(attribute, key);
    if (added) meta.setAttribute(_addedAttribute, '');
    document.head?.appendChild(meta);
  }
  meta.setAttribute('content', value);
}

void _setCanonical(web.Document document, String url) {
  var link = document.querySelector('link[rel="canonical"]');
  if (link == null) {
    link = document.createElement('link');
    link.setAttribute('rel', 'canonical');
    link.setAttribute(_addedAttribute, '');
    document.head?.appendChild(link);
  }
  link.setAttribute('href', url);
}
