import 'package:campuszone/app.dart';
import 'package:campuszone/core/core.dart';
import 'package:campuszone/core/config/env.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  SystemChrome.setSystemUIOverlayStyle(AppTheme.systemUiStyle);

  runApp(const CampusZoneApp());
}
