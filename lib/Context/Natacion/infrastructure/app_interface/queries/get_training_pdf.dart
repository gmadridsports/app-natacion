import 'package:gmadrid_natacion/Context/Natacion/application/Training/GetTrainingPDFResponse.dart';

import '../../../application/Training/GetTrainingPDF.dart' as AppGetTrainingPDF;
import '../query_interface.dart';

class GetTrainingPDF implements QueryInterface<Future<GetTrainingPDFResponse>> {
  @override
  Future<GetTrainingPDFResponse> call(DateTime forTrainingDay) {
    return AppGetTrainingPDF.GetTrainingPDF()(forTrainingDay);
  }
}
