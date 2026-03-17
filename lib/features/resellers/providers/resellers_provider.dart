import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/resellers_service.dart';

final resellersServiceProvider = Provider<ResellersService>((ref) {
  return ResellersService();
});

final resellersDataProvider = FutureProvider<List<Map<String, String>>>((ref) async {
  return ref.watch(resellersServiceProvider).fetchResellers();
});
