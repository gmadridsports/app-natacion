import 'package:flutter/material.dart';

import 'models/TrainingRepository.dart';

class AppConfig extends InheritedWidget {
  final TrainingRepository trainingRepository;

  const AppConfig(this.trainingRepository, {super.key, required super.child});

  @override
  bool updateShouldNotify(_) => false;

  static AppConfig? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppConfig>();
}
