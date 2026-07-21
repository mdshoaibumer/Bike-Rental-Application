import 'package:integration_test/integration_test.dart';

import 'customer_flow_test.dart' as customer_flow;
import 'admin_flow_test.dart' as admin_flow;
import 'demo_validation_test.dart' as demo_validation;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Run all E2E flows
  customer_flow.main();
  admin_flow.main();
  demo_validation.main();
}
