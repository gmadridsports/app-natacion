import 'dart:typed_data';

import 'TrainingURL.dart';
import 'TrainingDate.dart';

abstract class TrainingRepository {
  Future<TrainingURL> getTrainingURL(TrainingDate date);
  Future<Uint8List> getTrainingPDF(TrainingDate date);
}
