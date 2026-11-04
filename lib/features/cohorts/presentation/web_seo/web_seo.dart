// The document metadata a public page publishes: browser tab title, meta
// description, Open Graph and canonical URL.
//
// The web build has a DOM to update; the desktop and mobile builds have no
// document, so they use the no-op implementation.
export 'web_seo_stub.dart' if (dart.library.js_interop) 'web_seo_web.dart';
