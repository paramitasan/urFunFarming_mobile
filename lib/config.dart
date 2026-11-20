/// Address of the urFunFarming Django site (Django REST Framework API).
///
/// Override at build time:
///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://paramita-santoso-urfunfarming.pws.cs.ui.ac.id',
);

/// Whether the app is previewed as a grower (shows the grower tools).
// TODO: replace with the real role from the logged-in user once login exists.
const bool previewAsGrower = true;
