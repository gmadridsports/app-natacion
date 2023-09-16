import 'package:gmadrid_natacion/Context/Natacion/application/Training/GetTrainingPDFResponse.dart';

import '../../../../shared/dependency_injection.dart';
import '../../domain/TrainingDate.dart';
import '../../domain/TrainingRepository.dart';

class GetTrainingPDF {
  final TrainingRepository _trainingRepository;

  GetTrainingPDF()
      : _trainingRepository =
            DependencyInjection().getInstanceOf<TrainingRepository>();

  Future<GetTrainingPDFResponse> call(DateTime forTrainingDay) async {
    final trainingDate = TrainingDate.fromDateTime(forTrainingDay)
        .firstTrainingDateWithinTheWeek();
    final response = await _trainingRepository.getTrainingPDF(trainingDate);

    return GetTrainingPDFResponse(response);
  }
}
