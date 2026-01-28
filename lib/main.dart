import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

void main() {
  // Ensures the framework is ready before any platform messages arrive.
  // This can prevent harmless-but-noisy lifecycle channel buffer warnings,
  // especially on web/Chrome during startup/hot restart. 
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: SpencesApp()));
}
