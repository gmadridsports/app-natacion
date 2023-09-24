import 'dart:async';
import 'dart:io';
import 'package:supabase/supabase.dart';
import 'package:path/path.dart' as p;

void main() async {
  print('Uploading the trainings...');
  await upload();
  print('Uploaded.');

  exit(0);
}

Future<List<File>> getAllFilesWithExtension(
    String path, String extension) async {
  final List<FileSystemEntity> entities = await Directory(path).list().toList();
  return entities
      .whereType<File>()
      .where((element) => p.extension(element.path) == extension)
      .toList();
}

Future<List<String>> getBuckets(String path) async {
  final List<FileSystemEntity> entities = await Directory(path).list().toList();
  return entities
      .whereType<Directory>()
      .map((e) => p.basename(e.path))
      .toList();
}

Future<void> upload() async {
  Map<String, String> envVars = Platform.environment;
  final supabase = await SupabaseClient(
      (envVars['SUPABASE_URL'] ?? 'http://localhost:54321'),
      (envVars['SUPABASE_PRIVATE_KEY'] ??
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU'));

  final context = p.Context();

  final buckets = await getBuckets(
      (Platform.script.path.replaceFirst('populate_buckets.dart', 'buckets')));

  await Future.forEach(buckets, (String bucket) async {
    String localBucketDirectoryBase = await Directory(
            '${Platform.script.path.replaceFirst('/populate_buckets.dart', '')}/buckets/${bucket}/')
        .path
        .toString();

    Stream<FileSystemEntity> entityList =
        await Directory(localBucketDirectoryBase)
            .list(recursive: true, followLinks: false);

    await for (FileSystemEntity entityToUpload in entityList) {
      if (entityToUpload is File) {
        final entityToUploadBasename = context.basename(entityToUpload.path);
        final entityToUploadPathWithinBucket = entityToUpload.path
            .replaceFirst(localBucketDirectoryBase, '')
            .replaceFirst(entityToUploadBasename, '');

        final trainingFiles = await supabase.storage.from(bucket).list(
            path: entityToUploadPathWithinBucket,
            searchOptions: SearchOptions(search: entityToUploadBasename));

        if (trainingFiles
            .any((element) => element.name == entityToUploadBasename)) {
          print(
              'Updating ${entityToUploadPathWithinBucket}/${entityToUploadBasename}');
          await supabase.storage.from(bucket).update(
              "/${entityToUploadPathWithinBucket}/${entityToUploadBasename}",
              entityToUpload);
          print(
              'Updated ${entityToUploadPathWithinBucket}/${entityToUploadBasename}');
        } else {
          print(
              'Uploading ${entityToUploadPathWithinBucket}/${entityToUploadBasename}');
          await supabase.storage.from(bucket).upload(
              "/${entityToUploadPathWithinBucket}/${entityToUploadBasename}",
              entityToUpload);
          print('Uploaded.');
        }
      }
    }
  });
}
