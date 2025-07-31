import 'dart:math';

/// Game PIN entity for session identification
/// Handles PIN generation, validation, and formatting
class GamePin {
  final String value;

  const GamePin._(this.value);

  /// Create a GamePin from string with validation
  factory GamePin.fromString(String pin) {
    if (!isValidPin(pin)) {
      throw ArgumentError('Invalid PIN format. Must be 6 digits.');
    }
    return GamePin._(pin);
  }

  /// Generate a new random 6-digit PIN
  factory GamePin.generate() {
    final random = Random.secure();
    final pin = (100000 + random.nextInt(900000)).toString();
    return GamePin._(pin);
  }

  /// Validate PIN format (6 digits)
  static bool isValidPin(String pin) {
    return RegExp(r'^[0-9]{6}$').hasMatch(pin);
  }

  /// Format PIN for display (e.g., "123 456")
  String get formatted => '${value.substring(0, 3)} ${value.substring(3)}';

  /// Get PIN as integer
  int get asInt => int.parse(value);

  @override
  String toString() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GamePin &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}

/// PIN validation result for detailed error handling
class PinValidationResult {
  final bool isValid;
  final String? errorMessage;
  final PinValidationError? error;

  const PinValidationResult._({
    required this.isValid,
    this.errorMessage,
    this.error,
  });

  factory PinValidationResult.valid() {
    return const PinValidationResult._(isValid: true);
  }

  factory PinValidationResult.invalid(
    PinValidationError error,
    String message,
  ) {
    return PinValidationResult._(
      isValid: false,
      error: error,
      errorMessage: message,
    );
  }
}

/// PIN validation error types
enum PinValidationError {
  tooShort,
  tooLong,
  invalidCharacters,
  notFound,
  sessionFull,
  sessionInProgress,
  sessionCompleted;

  String get message {
    switch (this) {
      case PinValidationError.tooShort:
        return 'PIN must be 6 digits';
      case PinValidationError.tooLong:
        return 'PIN must be 6 digits';
      case PinValidationError.invalidCharacters:
        return 'PIN can only contain numbers';
      case PinValidationError.notFound:
        return 'Game not found. Check the PIN and try again.';
      case PinValidationError.sessionFull:
        return 'This game is full';
      case PinValidationError.sessionInProgress:
        return 'Game has already started';
      case PinValidationError.sessionCompleted:
        return 'This game has ended';
    }
  }
}

/// PIN generator configuration
class PinGeneratorConfig {
  final int maxRetries;
  final Duration retryDelay;
  final List<String> blacklistedPins;

  const PinGeneratorConfig({
    this.maxRetries = 10,
    this.retryDelay = const Duration(milliseconds: 100),
    this.blacklistedPins = const [
      '000000',
      '111111',
      '222222',
      '333333',
      '444444',
      '555555',
      '666666',
      '777777',
      '888888',
      '999999',
      '123456',
      '654321',
      '123123',
      '696969',
      '420420',
    ],
  });

  /// Check if PIN is blacklisted
  bool isBlacklisted(String pin) => blacklistedPins.contains(pin);

  /// Generate a non-blacklisted PIN
  GamePin generateSafePin() {
    GamePin pin;
    int attempts = 0;

    do {
      pin = GamePin.generate();
      attempts++;

      if (attempts >= maxRetries) {
        throw Exception(
          'Failed to generate unique PIN after $maxRetries attempts',
        );
      }
    } while (isBlacklisted(pin.value));

    return pin;
  }
}

/// PIN input formatter for UI
class PinInputFormatter {
  /// Format partial PIN input for display
  static String format(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleaned.length <= 3) {
      return cleaned;
    }

    return '${cleaned.substring(0, 3)} ${cleaned.substring(3, cleaned.length.clamp(0, 6))}';
  }

  /// Clean formatted input back to raw PIN
  static String clean(String formatted) {
    return formatted.replaceAll(RegExp(r'[^0-9]'), '');
  }

  /// Check if input is complete (6 digits)
  static bool isComplete(String input) {
    final cleaned = clean(input);
    return cleaned.length == 6;
  }
}
