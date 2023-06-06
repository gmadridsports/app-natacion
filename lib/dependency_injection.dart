import 'package:flutter/material.dart';
import 'package:gmadrid_natacion/models/DateTimeRepository.dart';

import 'models/TrainingRepository.dart';

class DependencyInjection extends InheritedWidget {
  final TrainingRepository trainingRepository;
  final DateTimeRepository dateTimeRepository;

  const DependencyInjection.hydrateWithInstances(
      this.trainingRepository, this.dateTimeRepository,
      {super.key, required super.child});

  @override
  bool updateShouldNotify(_) => false;

  static DependencyInjection? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DependencyInjection>();
}
