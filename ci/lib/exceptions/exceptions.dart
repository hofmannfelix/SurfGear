/// Не найдены модули. Например, пользователь указал неправильный путь.
class ModulesNotFoundException implements Exception {
  final String message;

  ModulesNotFoundException(this.message);
}

/// Модуль, помеченный как stable, был изменён.
class StableModulesWasModifiedException implements Exception {
  final String message;

  StableModulesWasModifiedException(this.message);
}

/// Ошибка при сборке модуля.
///
/// Выбрасывается как в случае сборки единичного модуля так и списка модулей.
class PackageBuildException implements Exception {
  final String message;

  PackageBuildException(this.message);
}

/// Модуль не прошёл проверку статического анализатора
/// `flutter analyze`
class AnalyzerFailedException implements Exception {
  final String message;

  AnalyzerFailedException(this.message);
}


/// Не можем опубликовать модуль OpenSource
class ModuleNotPublishOpenSourceException implements Exception {
  final String message;

  /// Вызывается [PubDryRunTask]
  ModuleNotPublishOpenSourceException(this.message);
}
