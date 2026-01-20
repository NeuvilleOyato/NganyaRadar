// Export the appropriate constants based on environment
// This file will import either dev or prod constants
// To build for production: flutter build apk --dart-define=ENVIRONMENT=production

export 'constants_dev.dart' if (dart.library.js) 'constants_prod.dart';
