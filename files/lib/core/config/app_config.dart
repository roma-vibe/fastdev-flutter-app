import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppConfig {
  const AppConfig({required this.name, required this.slug});
  factory AppConfig.fromEnvironment() {
    const name = String.fromEnvironment('APP_NAME');
    const slug = String.fromEnvironment('APP_SLUG');
    if (name.isEmpty || slug.isEmpty) {
      throw StateError(
        'APP_NAME and APP_SLUG are required. Run through tool/project.dart.',
      );
    }
    return const AppConfig(name: name, slug: slug);
  }
  final String name;
  final String slug;
}

final appConfigProvider = Provider<AppConfig>(
  (ref) => AppConfig.fromEnvironment(),
);
