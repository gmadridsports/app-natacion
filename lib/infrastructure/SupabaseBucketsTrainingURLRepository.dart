import 'package:gmadrid_natacion/models/TrainingURL.dart';
import 'package:gmadrid_natacion/models/TrainingRepository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/TrainingDate.dart';

class SupabaseBucketsTrainingURLRepository implements TrainingRepository {
  static const _trainingsFolder = 'trainings';
  static const _trainingsBucket = 'general';

  @override
  Future<TrainingURL> getTrainingURL(TrainingDate date) async =>
      Supabase.instance.client.storage
          .from(_trainingsBucket)
          .getPublicUrl('${_trainingsFolder}/2023-04-24.pdf');
}
