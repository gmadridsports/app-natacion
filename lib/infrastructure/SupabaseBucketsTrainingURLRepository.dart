import 'dart:typed_data';

import 'package:gmadrid_natacion/models/TrainingURL.dart';
import 'package:gmadrid_natacion/models/TrainingRepository.dart';
import 'package:gmadrid_natacion/screens/training-week/training-week.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/DateTimeRepository.dart';
import '../models/TrainingDate.dart';

class SupabaseBucketsTrainingURLRepository implements TrainingRepository {
  final DateTimeRepository _dateTimeRepository;
  static const _trainingsFolder = 'trainings';
  static const _trainingsBucket = 'general';

  const SupabaseBucketsTrainingURLRepository(this._dateTimeRepository);

  @override
  Future<TrainingURL> getTrainingURL(TrainingDate date) async =>
      Supabase.instance.client.storage
          .from(_trainingsBucket)
          .getPublicUrl('${_trainingsFolder}/${date.toString()}.pdf');

  @override
  Future<Uint8List> getTrainingPDF(TrainingDate date) async =>
      Supabase.instance.client.storage
          .from(_trainingsBucket)
          .download('${_trainingsFolder}/${date.toString()}.pdf');

  @override
  Future<TrainingDate?> getFirstTrainingDate() async {
    final results = await Supabase.instance.client.storage
        .from(_trainingsBucket)
        .list(
            path: '${_trainingsFolder}/',
            searchOptions: const SearchOptions(
                limit: 1, sortBy: const SortBy(column: 'name', order: 'asc')));

    if (results.firstOrNull == null) {
      return null;
    }

    return TrainingDate.fromString(
        results.firstOrNull!.name.replaceAll(RegExp('\.pdf\$'), ''));
  }

  @override
  Future<TrainingDate?> getLastTrainingDate() async {
    final results = await Supabase.instance.client.storage
        .from(_trainingsBucket)
        .list(
            path: '${_trainingsFolder}/',
            searchOptions: const SearchOptions(
                limit: 1, sortBy: const SortBy(column: 'name', order: 'desc')));

    if (results.firstOrNull == null) {
      return null;
    }

    return TrainingDate.fromString(
        results.firstOrNull!.name.replaceAll(RegExp('\.pdf\$'), ''));
  }

  @override
  Future<bool> trainingExistsForWeek(TrainingDate date) async {
    final dateSearch = date.toString();
    return ((await Supabase.instance.client
                .from('objects')
                .select('name', new FetchOptions(count: CountOption.exact))
                .eq('name', '${_trainingsFolder}/${dateSearch}.pdf'))
            .count ==
        1);
  }
}
