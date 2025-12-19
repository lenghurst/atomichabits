// tool/setup_secrets.dart
//
// Phase 27.2: Green Light Automator - Secret Generator
//
// This script creates a properly formatted secrets.json file
// by prompting the user for each API key interactively.
//
// Usage: dart run tool/setup_secrets.dart

import 'dart:io';
import 'dart:convert';

void main() {
  print('╔═══════════════════════════════════════════════════════════════╗');
  print('║           THE PACT - SECURE KEY INJECTION PROTOCOL            ║');
  print('╚═══════════════════════════════════════════════════════════════╝');
  print('');
  print('⚠️  Keys entered here are saved locally to secrets.json only.');
  print('⚠️  secrets.json is git-ignored and safe.');
  print('');
  print('📋 You will need the following keys:');
  print('   - Supabase URL & Anon Key (from Supabase Dashboard > Settings > API)');
  print('   - DeepSeek API Key (from platform.deepseek.com)');
  print('   - Gemini API Key (from aistudio.google.com)');
  print('');

  final secrets = <String, String>{};

  // Supabase Configuration
  print('─── SUPABASE CONFIGURATION ───');
  secrets['SUPABASE_URL'] = _prompt(
    '1. Enter SUPABASE_URL',
    hint: 'https://your-project-id.supabase.co',
    validator: (v) => v.startsWith('https://') && v.contains('supabase'),
    errorMsg: 'URL must start with https:// and contain "supabase"',
  );
  
  secrets['SUPABASE_ANON_KEY'] = _prompt(
    '2. Enter SUPABASE_ANON_KEY',
    hint: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
    validator: (v) => v.startsWith('eyJ'),
    errorMsg: 'Anon key should be a JWT starting with "eyJ"',
  );

  // AI Configuration
  print('');
  print('─── AI MODEL CONFIGURATION ───');
  secrets['DEEPSEEK_API_KEY'] = _prompt(
    '3. Enter DEEPSEEK_API_KEY',
    hint: 'sk-...',
    validator: (v) => v.startsWith('sk-'),
    errorMsg: 'DeepSeek key should start with "sk-"',
  );
  
  secrets['GEMINI_API_KEY'] = _prompt(
    '4. Enter GEMINI_API_KEY',
    hint: 'AIza...',
    validator: (v) => v.length > 20,
    errorMsg: 'Gemini key seems too short',
  );

  // Optional: OpenAI for TTS fallback
  print('');
  print('─── OPTIONAL CONFIGURATION ───');
  final openAiKey = _promptOptional(
    '5. Enter OPENAI_API_KEY (optional, for TTS fallback)',
    hint: 'sk-... or press Enter to skip',
  );
  if (openAiKey != null && openAiKey.isNotEmpty) {
    secrets['OPENAI_API_KEY'] = openAiKey;
  }

  // Write the file
  final file = File('secrets.json');
  const encoder = JsonEncoder.withIndent('  ');
  file.writeAsStringSync(encoder.convert(secrets));

  print('');
  print('╔═══════════════════════════════════════════════════════════════╗');
  print('║                    ✅ SUCCESS                                  ║');
  print('╚═══════════════════════════════════════════════════════════════╝');
  print('');
  print('📁 secrets.json created at: ${file.absolute.path}');
  print('');
  print('👉 NEXT STEPS:');
  print('   1. Run the Green Light test:');
  print('      flutter test integration_test/green_light_test.dart --dart-define-from-file=secrets.json');
  print('');
  print('   2. Or launch the app in VS Code:');
  print('      Select "The Pact (Dev)" configuration and press F5');
  print('');
}

String _prompt(
  String text, {
  String? hint,
  bool Function(String)? validator,
  String? errorMsg,
}) {
  while (true) {
    if (hint != null) {
      stdout.write('👉 $text\n   (e.g., $hint)\n   > ');
    } else {
      stdout.write('👉 $text: ');
    }
    
    final input = stdin.readLineSync();
    
    if (input == null || input.trim().isEmpty) {
      print('   ❌ Error: Value cannot be empty.\n');
      continue;
    }
    
    final trimmed = input.trim();
    
    if (validator != null && !validator(trimmed)) {
      print('   ❌ Error: ${errorMsg ?? "Invalid input."}\n');
      continue;
    }
    
    return trimmed;
  }
}

String? _promptOptional(String text, {String? hint}) {
  if (hint != null) {
    stdout.write('👉 $text\n   ($hint)\n   > ');
  } else {
    stdout.write('👉 $text: ');
  }
  
  final input = stdin.readLineSync();
  return input?.trim();
}
