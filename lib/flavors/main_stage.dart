import '../app/app_bootstrap.dart';
import '../core/config/app_config.dart';

/// Entry point for the STAGING flavor.
void main() {
  bootstrap(AppConfig.stage());
}
