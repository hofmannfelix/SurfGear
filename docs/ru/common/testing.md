[Главная](../main.md)

# Тестирование

## Тестирование виджетов

Файлы с тестами принято располагать в подкаталоге `test` проекта.
По умолчанию исполняются тесты из всех файлов, с маской `*_test.dart` из подкаталога `test`.

Тест описывается с помощью функции `testWidgets`. Для взаимодействия с виджетом
пользователю предоставляется WidgetTester.
```dart
  testWidgets('Название теста', (WidgetTester tester) async {
    // Код теста
  });
```

Тесты можно объединять в группы с помощью `group`:
```dart
  group('Название группы тестов', () {
    testWidgets('Название теста', (WidgetTester tester) async {
        // Код теста
      });
    
    testWidgets('Название теста', (WidgetTester tester) async {
        // Код теста
      });    
  });
```

Функции `setUp` и `tearDown` позволяют выполнить какой-либо код до и после каждого теста.
```dart
  setUp(() {
    // код инициализации теста
  });
  tearDown(() {
    // код финализации теста
  });
```

### Взаимодействие с тестируемым виджетом

Класс `WidgetTester` предоставляет функции для создания тестируемого виджета и ожидания смены его состояний,
а также выполнять некоторые действия над виджетами.

* `pumpWidget` — создание тестируемого виджета
* `pump` — ожидание смены состояния тестируемого виджета в течение заданного времени (100 мс по умолчанию)
* `pumpAndSettle` — вызывает `pump` в цикле для смены состояний в течение заданного времени (100 мс по умолчанию)
* `tap` — отправить виджету нажатие
* `longPress` — длинное нажатие
* `fling` — смахивание/свайп
* `drag` — перенос
* `enterText` — ввод текста


### Поиск виджетов

Чтобы выполнить какие-либо действия над вложенным виджетом, его нужно найти в дереве виджетов.
Для этого есть глобальный объект `find`, который позволяет найти виджеты:

* в дереве по тексту — `find.text`, `find.widgetWithText`
* по ключу — `find.byKey`
* по иконке — `find.byIcon`, `find.widgetWithIcon`
* по типу — `find.byType`
* по положению в дереве — `find.descendant` и `find.ancestor`
* с помощью функции, которая анализирует виджеты по списку — `find.byWidgetPredicate`


### Макеты

Моки зависимостей создаются как наследники класса `Mock` и реализуют интерфейс зависимости.
```dart
class AuthInteractorMock extends Mock implements AuthInteractor {}
```

Для определения функциональности мока используется функция `when`, 
которая позволяет определить ответ мока на вызов той или иной функции.
```dart
when(authInteractor.checkAccess(any))
  .thenAnswer((_) => Future.value(true));
```


### Проверки

В процессе выполнения теста можно проверить наличие виджетов на экране:
```dart
expect(find.text('Номер телефона'), findsOneWidget);
expect(find.text('Код из СМС'), findsNothing);
```

После выполнения теста можно проверить как макет был использован виджетом:
```dart
verify(appComponent.authInteractor).called(1);
verify(authInteractor.checkAccess(any)).called(1);
verifyNever(appComponent.profileInteractor);
```


### Отладка

Тесты выполняются в консоли без какой либо графики.
Можно запускать тесты в debug режиме и ставить точки останова в коде виджета.

Для того чтобы получить представление о том, что происходит в дереве виджетов, можно использовать
функцию `debugDumpApp()`, которая выводит в консоль текстовое представление иерархии всего дерева виджетов.

Для получения представления о том, как виджет использует моки, используется функция `logInvocations([])`.
Функция принимает список моков, и выдает в консоль последовательность вызовов
методов у этих моков, которые совершал тестируемый виджет.

### Подготовка

Все интеракторы и прочие зависимости должны передаваться в тестируемый виджет в виде мока:
```dart
class AppComponentMock extends Mock implements AppComponent {}
class AuthInteractorMock extends Mock implements AuthInteractor {}
```

В корне дерева виджетов должен быть `Injector` и `MaterialApp`.
```dart
    await tester.pumpWidget(
      Injector<AppComponent>(
        component: appComponentMock,
        builder: (context) {
          return MaterialApp(
            home: PhoneInputScreen(),
          );
        },
      ),
    );
    await tester.pumpAndSettle();
```
В примере кода `PhoneInputScreen` — это тестируемый виджет.
Также видно, что `Injector` в качестве параметра получает мок `AppComponent`
и как обычно извлекает из него необходимые зависимости, которые нужно предварительно создать
и поместить в мок `AppComponent` с помощью `when`.

После создания тестового виджета и после любых действий с ним нужно вызывать `tester.pumpAndSettle()`
для смены состояний.


### Тестирование

Для проверки виджета мы можем моделировать поведение сервисного слоя и отслеживать реакцию тестируемого виджета.

Моки могут возвращать ошибки или ошибочные данные:
```dart
when(authInteractor.checkAccess(any)).thenAnswer((_) => Future.error(UnknownHttpStatusCode(null)));
```

В тесте можно и нужно нажимать куда не надо, и вводить не то что требуется,
и проверять, что это не приводит к фатальным последствиям
```dart
await tester.enterText(find.byKey(Key('phoneField')), 'bla-bla-bla');
```

После любых действий с виджетами нужно вызывать `tester.pumpAndSettle()` для смены состояний.


## Интеграционное тестирование

Этот метод тестирования может хорошо заменить ручное тестирование.
Процесс тестирования можно наглядно наблюдать в эмуляторе или на устройстве.

Из недостатков этого подхода можно отметить то, что нет возможности взаимодействовать с системными диалогами платформы.
Но, например, запросы привилегий можно подавлять так, как описано в [этом тикете](https://github.com/flutter/flutter/issues/12561).

### Общие сведения

В отличие от виджет тестов, процесс работы интеграционного теста можно наблюдать в симуляторе или на экране устройства.

Файлы с интеграционными тестами располагаются в подкаталоге `test_driver` проекта.

Приложение запускается после старта специального плагина, который позволяет управлять нашим приложением.

Выглядит это следующим образом:
```dart
import 'package:flutter_driver/driver_extension.dart';
import 'package:park_flutter/main.dart' as app;
void main() {
  enableFlutterDriverExtension();
  app.main();
}
```

Запуск тестов осуществляется из командной строки.
Если запуск приложения описан в файле `app.dart`, а тестовый сценарий называется `app_test.dart`,
то достаточно следующей комманды:
```text
$ flutter drive --target=test_driver/app.dart
```

Если тестовый сценарий имеет другое имя, тогда его нужно указать явно:
```text
flutter drive --target=test_driver/app.dart --driver=test_driver/home_test.dart
```

Тест создается функцией `test`, и группируются функцией `group`.

```dart
group('park-flutter app', () {
    // драйвер, через который мы подключаемся к устройству
    FlutterDriver driver;

    // создаем подключение к драйверу
    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    // закрываем подключение к драйверу
    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    test('Имя теста', () async {
      // код теста
    });
    
    test('Другой тест', () async {
      // код теста
    });
}
```


### Взаимодействие с тестируемым приложением

Инструмент `FlutterDriver` позволяет взаимодействовать с тестируемым приложением через следующие методы:

* tap — отправить нажатие виджету
* waitFor — ждать появление виджета на экране
* waitForAbsent — ждать исчезновения виджета
* scroll, scrollIntoView, scrollUntilVisible — прокрутить экран на заданное смещение или к требуемому виджету
* enterText, getText — ввести текст или взять текст виджета
* screenshot — получить скриншот экрана
* requestData — более сложное взаимодействие через вызов функции внутри тестируемого приложения
* и много другое

В приложении можно задать обработчик запросов, к которому можно обращаться через вызов `driver.requestData('login')`
```dart
void main() {
  Future<String> dataHandler(String msg) async {
    if (msg == "login") {
      // какая то обработка вызова в приложении с возвратом результата
      return 'some result';
    }
  }

  enableFlutterDriverExtension(handler: dataHandler);
  app.main();
}
```


### Поиск виджетов

Поиск виджетов при интеграционном тестировании незначительно отличается от аналогичной функциональности при тестировании виджетов:

* в дереве по тексту — `find.text`, `find.widgetWithText`
* по ключу — `find.byValueKey`
* по типу — `find.byType`
* по подсказке — `find.byTooltip`
* по семантической метке — `find.bySemanticsLabel`
* по положению в дереве — `find.descendant` и `find.ancestor`