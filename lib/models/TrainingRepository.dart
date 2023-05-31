import 'TrainingURL.dart';
import 'TrainingDate.dart';

abstract class TrainingRepository {
  Future<TrainingURL> getTrainingURL(TrainingDate date);
}
