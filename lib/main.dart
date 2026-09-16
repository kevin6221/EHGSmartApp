import 'app/app_bootstrap.dart';
import 'core/config/app_config.dart';

/// Default application entry point: boots the DEVELOPMENT environment.
void main() {
  bootstrap(AppConfig.dev());
}
