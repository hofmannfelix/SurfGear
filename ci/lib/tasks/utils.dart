import 'package:ci/domain/element.dart';
import 'package:ci/exceptions/exceptions.dart';
import 'package:ci/exceptions/exceptions_strings.dart';
import 'package:ci/services/parsers/command_parser.dart';
import 'package:ci/services/runner/shell_runner.dart';

/// Получить модули, помеченные как stable.
List<Element> getStableModules(List<Element> elements) {
  return elements.where((e) => e.isStable).toList();
}

/// Ищет изменения в указанных модулях, опираясь на разницу
/// между двумя последними коммитами.
Future<List<Element>> findChangedElements(List<Element> elements) async {
  await markChangedElements(elements);

  return filterChangedElements(elements);
}

/// Возвращает элеметны из списка, которые имеют отметку об изменении.
Future<List<Element>> filterChangedElements(List<Element> elements) async {
  return elements.where((e) => e.changed).toList();
}

/// Возвращает элеметны из списка, которые удовлетворяют переданным
/// параметрам команды.
///
/// Речь идет про стандартный набор параметров определения какой именно модуль
/// затронет команда, с опциями --all или --name.
/// В случае если имя было указано, но не было найдено -
/// будет пораждено исключение.
Future<List<Element>> filterElementsByCommandParams(
  List<Element> elements,
  Map<String, dynamic> arguments,
) async {
  var targetList = <Element>[];
  var isAll = arguments[CommandParser.defaultAllFlag];
  if (isAll) {
    targetList.addAll(elements);
  } else {
    var name = arguments[CommandParser.defaultNameOption];

    var element = elements.firstWhere(
      (e) => e.name == name,
      orElse: () => null,
    );

    if (element == null) {
      return Future.error(
        ElementNotFoundException(
          getElementNotFoundExceptionText(name),
        ),
      );
    }

    targetList.add(element);
  }

  return targetList;
}

/// Валидирует переданные параметры как параметры перечисления необходимых
/// элементов для команды.
Future<bool> validateCommandParamForElements(
  Map<String, dynamic> arguments,
) async {
  var isAll = arguments[CommandParser.defaultAllFlag] ?? false;
  if (!isAll) {
    var name = arguments[CommandParser.defaultNameOption];

    if (name == null) {
      return false;
    }
  }

  return true;
}

/// Помечает измененные модули, опираясь на разницу
/// между двумя последними коммитами.
Future<void> markChangedElements(List<Element> elements) async {
  final result = await sh('git diff --name-only HEAD HEAD~');
  final diff = result.stdout as String;

  print('Файлы, изменённые в последнем коммите:\n$diff');

  elements
      .where((e) => diff.contains(e.directoryName))
      .forEach((e) => e.changed = true);
}