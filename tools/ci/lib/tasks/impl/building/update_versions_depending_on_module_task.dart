// import 'package:ci/domain/dependency.dart';
// import 'package:ci/domain/element.dart';
// import 'package:ci/tasks/core/task.dart';
//
// /// Обновляет Element в зависимых модулях
// class UpdateVersionsDependingOnModuleTask implements Action {
//   final List<Element> _elements;
//
//   UpdateVersionsDependingOnModuleTask(this._elements);
//
//   @override
//   Future<void> run() async {
//     _elements.forEach((Element element) {
//       element = _updateDependence(element);
//     });
//   }
//
//   Element _updateDependence(Element element) {
//     // _elements.forEach((Element dep) {
//     //   dep.dependencies.forEach((Dependency dependence) {
//     //     if (dependence.element.name == element.name &&
//     //         dependence.element.version != element.version) {
//     //       List<Dependency> dependency = element.dependencies;
//     //       dependency.
//     //       Element.byTemplate(element);
//     //       // dependence.element = element;
//     //     }
//     //   });
//     // });
//   }
// }
