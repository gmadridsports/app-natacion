import '../../../../shared/dependency_injection.dart';
import '../../domain/TrainingDate.dart';
import '../../domain/TrainingRepository.dart';
import 'IsATrainingWeekResponse.dart';

class IsATrainingWeek {
  final TrainingRepository _trainingRepository;

  IsATrainingWeek()
      : _trainingRepository =
            DependencyInjection().getInstanceOf<TrainingRepository>();

  Future<IsATrainingWeekResponse> call(DateTime dateWithinQueryingWeek) async {
    final response = await _trainingRepository.trainingExistsForWeek(
        TrainingDate.fromDateTime(dateWithinQueryingWeek)
            .firstTrainingDateWithinTheWeek());

    return IsATrainingWeekResponse(response);
  }
}
