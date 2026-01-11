/// Callback for validating a string input.
/// Should return an error message as [String] if invalid, or null if valid.
typedef ValidatorCallback = String? Function(String? value);

/// Callback to handle a string input value, e.g., when a user types or submits text.
typedef InputCallback = void Function(String? value);

/// Callback to handle deletion actions for an item with an integer ID.
typedef DeleteCallback = void Function(int id);
