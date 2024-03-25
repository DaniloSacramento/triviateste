import 'package:intl/date_symbol_data_local.dart';

import 'flavors.dart';

import 'main.dart' as runner;

Future<void> main() async {
  await initializeDateFormatting();
  F.appFlavor = Flavor.acessonovo;
  await runner.main();
}
