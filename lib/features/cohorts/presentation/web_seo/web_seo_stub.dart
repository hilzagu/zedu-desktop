/// Publishing page metadata. There is no document outside the web build, so
/// the native apps keep the title they were built with.
void setPageSeo({
  required String title,
  required String description,
  required String url,
}) {}

/// Restores the metadata the page was opened with.
void restorePageSeo() {}
