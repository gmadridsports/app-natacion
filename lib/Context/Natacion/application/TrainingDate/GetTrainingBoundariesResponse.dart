import '../../../Shared/application/QueryResponse.dart';

sealed class GetTrainingBoundariesResponse implements QueryResponse {
  final DateTime? lowerBound;
  final DateTime? upperBound;
  final DateTime? lastTrainingDate;

  GetTrainingBoundariesResponse(
      this.lowerBound, this.upperBound, this.lastTrainingDate);
}

class GetTrainingBoundariesPositiveResponse
    extends GetTrainingBoundariesResponse {
  bool hasTrainingDates = true;
  @override
  DateTime get lowerBound => super.lowerBound as DateTime;
  @override
  DateTime get upperBound => super.upperBound as DateTime;
  @override
  DateTime get lastTrainingDate => super.lastTrainingDate as DateTime;

  GetTrainingBoundariesPositiveResponse(
      DateTime lowerBound, DateTime upperBound, DateTime lastTrainingDate)
      : super(lowerBound, upperBound, lastTrainingDate);
}

class GetTrainingBoundariesNegativeResponse
    extends GetTrainingBoundariesResponse {
  bool hasTrainingDates = false;

  GetTrainingBoundariesNegativeResponse() : super(null, null, null);
}
