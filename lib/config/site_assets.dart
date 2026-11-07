import 'api_config.dart';

/// Static pictures from the yubko.com website, shown in the app.
///
/// These are the site's own public image files (logo, hero, category
/// and step photos). They are loaded from the website because image
/// binaries cannot be committed to the repo through the GitHub API
/// tools used for this project (they reject non-text files).
class SiteAssets {
  SiteAssets._();

  static String _site(String path) => '${ApiConfig.siteBaseUrl}$path';

  /// The Yubko logo (dark green wordmark) for light backgrounds.
  static final String logo = _site('/images/yubko-logo.png');

  /// The Yubko logo in white, for dark/green backgrounds.
  static final String logoWhite = _site('/images/yubko-logo-white.png');

  /// Homepage hero photo.
  static final String hero = _site('/images/hero.webp');

  /// Category card photos, as used on the website's homepage.
  static final String categoryHouses =
      'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?auto=format&fit=crop&w=800&q=80';
  static final String categoryApartments = _site(
    '/images/categories/apartments&flats.jpg',
  );
  static final String categoryCommercial =
      'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?auto=format&fit=crop&w=800&q=80';

  /// "Post a property" step photos.
  static final String step1 = _site('/images/how-it-works/step-1.jpg');
  static final String step2 = _site('/images/how-it-works/step-2.jpg');
  static final String step3 = _site('/images/how-it-works/step-3.jpg');

  /// Absolute URL for a city photo path returned by the API
  /// (e.g. "/images/cities/lahore.jpg").
  static String absolute(String path) =>
      path.startsWith('http') ? path : _site(path);
}
