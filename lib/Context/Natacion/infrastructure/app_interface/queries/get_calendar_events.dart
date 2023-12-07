import '../../../application/TrainingDate/GetTrainingBoundariesResponse.dart';
import '../query_interface.dart';

class GetCalendarEvents
    implements QueryInterface<Future<GetTrainingBoundariesResponse>> {
  @override
  Future<GetTrainingBoundariesResponse> call() {
    return AppGetTrainingDatesBoundaries.GetTrainingDatesBoundaries()();
  }
}
