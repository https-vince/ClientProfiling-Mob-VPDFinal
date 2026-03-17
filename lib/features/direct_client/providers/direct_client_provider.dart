import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/direct_client_data.dart';
import '../services/direct_client_service.dart';

final directClientServiceProvider = Provider<DirectClientService>((ref) {
  return DirectClientService();
});

final directClientDataProvider = FutureProvider<DirectClientData>((ref) async {
  return ref.watch(directClientServiceProvider).fetchData();
});
