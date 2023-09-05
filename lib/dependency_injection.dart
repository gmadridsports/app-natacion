import 'package:flutter/material.dart';
import 'package:gmadrid_natacion/domain/DateTimeRepository.dart';
import 'package:gmadrid_natacion/domain/user/UserRepository.dart';

import 'domain/TrainingRepository.dart';

class DependencyInjection extends InheritedWidget {
  final TrainingRepository trainingRepository;
  final DateTimeRepository dateTimeRepository;
  final UserRepository userRepository;

  const DependencyInjection.hydrateWithInstances(
      this.trainingRepository, this.dateTimeRepository, this.userRepository,
      {super.key, required super.child});

  @override
  bool updateShouldNotify(_) => false;

  static DependencyInjection? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DependencyInjection>();
}
