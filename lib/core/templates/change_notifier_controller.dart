/// ChangeNotifier Controller Template
///
/// P-04: Standard template for creating controllers that manage state
/// and side effects, keeping UI widgets clean and focused on presentation.
///
/// USAGE:
/// 1. Copy this file to your feature's controllers/ directory
/// 2. Rename the class to match your feature (e.g., CouncilController)
/// 3. Add your state fields and methods
/// 4. Register in your ChangeNotifierProvider
///
/// PATTERN:
/// - Widgets handle "how it LOOKS" (layout, styling, animations)
/// - Controllers handle "how it BEHAVES" (state, side effects, business logic)
///
/// RULES:
/// - NO BuildContext stored as field (pass to methods that need it)
/// - NO Widget references (controllers are UI-agnostic)
/// - ALL state changes go through notifyListeners()
/// - DISPOSE resources in dispose() override

import 'package:flutter/foundation.dart';

/// Template controller demonstrating the ChangeNotifier pattern.
/// Copy and customize for your specific feature.
class FeatureController extends ChangeNotifier {
  // ========== STATE FIELDS ==========
  // Declare private fields for all state this controller manages

  bool _isLoading = false;
  String? _errorMessage;
  // Add your feature-specific state here

  // ========== GETTERS (Read-only access) ==========
  // Expose state through getters, not public fields

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  // ========== CONSTRUCTOR ==========
  // Inject dependencies here, NOT BuildContext

  FeatureController({
    // required YourRepository repository,
  }) {
    // _repository = repository;
    _init();
  }

  // ========== INITIALIZATION ==========

  Future<void> _init() async {
    // Load initial data, set up listeners, etc.
    // Called once when controller is created
  }

  // ========== PUBLIC METHODS ==========
  // These are called by UI in response to user actions

  /// Example: Load data from repository
  Future<void> loadData() async {
    _setLoading(true);
    _clearError();

    try {
      // await _repository.fetchData();
      // _data = result;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load data: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Example: Handle user action
  void handleUserAction(String input) {
    // Validate input
    if (input.isEmpty) {
      _setError('Input cannot be empty');
      return;
    }

    // Process action
    // Update state
    notifyListeners();
  }

  /// Reset controller to initial state
  void reset() {
    _isLoading = false;
    _errorMessage = null;
    // Reset your feature-specific state
    notifyListeners();
  }

  // ========== PRIVATE HELPERS ==========

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    // Don't notify here - caller will notify after their operation
  }

  // ========== DISPOSAL ==========

  @override
  void dispose() {
    // Cancel subscriptions, close streams, release resources
    // Example: _subscription?.cancel();
    super.dispose();
  }
}

// ========== USAGE EXAMPLE ==========
/*

// In your widget tree (e.g., main.dart or feature module):

ChangeNotifierProvider(
  create: (_) => FeatureController(),
  child: const FeatureScreen(),
)

// In your widget:

class FeatureScreen extends StatelessWidget {
  const FeatureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FeatureController>(
      builder: (context, controller, child) {
        if (controller.isLoading) {
          return const CircularProgressIndicator();
        }

        if (controller.hasError) {
          return Text('Error: ${controller.errorMessage}');
        }

        return YourUIWidget(
          onAction: () => controller.handleUserAction('value'),
        );
      },
    );
  }
}

// Or using context.read/watch:

class FeatureScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FeatureController>();

    return ElevatedButton(
      onPressed: () => context.read<FeatureController>().loadData(),
      child: Text('Load'),
    );
  }
}

*/
