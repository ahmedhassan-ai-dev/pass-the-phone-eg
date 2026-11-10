import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/services/app_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = AppStore();
  await store.load();
  runApp(PassThePhoneApp(store: store));
}
