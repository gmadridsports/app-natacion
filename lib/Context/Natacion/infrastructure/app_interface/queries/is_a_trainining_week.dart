import '../../../application/TrainingDate/IsATrainingWeek.dart'
    as AppIsATrainingWeek;
import '../../../application/TrainingDate/IsATrainingWeekResponse.dart';
import '../query_interface.dart';

class IsATrainingWeek
    implements QueryInterface<Future<IsATrainingWeekResponse>> {
  @override
  Future<IsATrainingWeekResponse> call(DateTime dateWithinQueryingWeek) {
    return AppIsATrainingWeek.IsATrainingWeek()(dateWithinQueryingWeek);
  }
}
