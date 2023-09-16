import 'package:gmadrid_natacion/app/screens/training-week/training-week.dart';
import 'package:gmadrid_natacion/shared/dependency_injection.dart';

import '../../../Shared/application/Query.dart';
import '../../domain/TrainingDate.dart';
import '../../domain/TrainingRepository.dart';
import 'GetTrainingBoundariesResponse.dart';

class GetTrainingDatesBoundaries implements Query {
  final TrainingRepository _trainingRepository;
  GetTrainingDatesBoundaries()
      : _trainingRepository =
            DependencyInjection().getInstanceOf<TrainingRepository>();

  Future<GetTrainingBoundariesResponse> call() async {
    TrainingDate? firstTrainingDate =
        (await _trainingRepository.getFirstTrainingDate())
            ?.firstTrainingDateWithinTheWeek();

    final lastTrainingDate = (await _trainingRepository.getLastTrainingDate());

    if (firstTrainingDate == null || lastTrainingDate == null) {
      return GetTrainingBoundariesNegativeResponse();
    }

    TrainingDate lastUsefulTrainingDate =
        lastTrainingDate.lastTrainingDateWithinTheWeek();

    return GetTrainingBoundariesPositiveResponse(firstTrainingDate.toDateTime(),
        lastUsefulTrainingDate.toDateTime(), lastTrainingDate.toDateTime());
  }
}
