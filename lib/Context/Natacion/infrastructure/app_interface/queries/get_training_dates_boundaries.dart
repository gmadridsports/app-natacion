import '../../../application/TrainingDate/GetTrainingBoundariesResponse.dart';
import '../../../application/TrainingDate/GetTrainingDatesBoundaries.dart'
    as AppGetTrainingDatesBoundaries;
import '../query_interface.dart';

class GetTrainingDatesBoundaries
    implements QueryInterface<Future<GetTrainingBoundariesResponse>> {
  @override
  Future<GetTrainingBoundariesResponse> call() {
    return AppGetTrainingDatesBoundaries.GetTrainingDatesBoundaries()();
  }
}
