import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:file_picker/file_picker.dart';

// https://pub.dev/packages/amplify_storage_s3/example
// https://pub.dev/documentation/amplify_core/latest/amplify_core/StorageCategory-class.html
// https://docs.aws.amazon.com/AmazonS3/latest/userguide/intelligent-tiering-managing.html#restore-data-from-int-tier-archive
Future<void> uploadImage() async {
  // Select a file from the device
  final result = await FilePicker.platform.pickFiles(
    allowMultiple: true,
    type: FileType.custom,
    withData: false,
    // Ensure to get file stream for better performance
    withReadStream: true,
    allowedExtensions: ['svg'],
  );

  if (result == null) {
    safePrint('No file selected');
    return;
  }
  for (PlatformFile file in result.files) {
    if (file.extension != 'svg') {
      safePrint("not a svg file");
      return;
    }
    try {
      final result = await Amplify.Storage.uploadFile(
        localFile: AWSFile.fromStream(
          file.readStream!,
          size: file.size,
        ),
        path: StoragePath.fromString(file.name),
        onProgress: (progress) {
          safePrint('Fraction completed: ${progress.fractionCompleted}');
        },
        
      ).result;
      safePrint('Successfully uploaded file: ${result.uploadedItem.path}');
      safePrint('Successfully uploaded file: ${result.uploadedItem.eTag}');
    } on StorageException catch (e) {
      safePrint('Error uploading file: $e');
      rethrow;
    }
  }
}

Future<String> getUrl(String path) async {
  try {
    final result = await Amplify.Storage.getUrl(
      path: StoragePath.fromString(path),
      options: const StorageGetUrlOptions(
        pluginOptions: S3GetUrlPluginOptions(
          validateObjectExistence: true,
          expiresIn: Duration(minutes: 1),
        ),
      ),
    ).result;
    return result.url.toString();
  } on StorageException catch (e) {
    safePrint('Get URL error - ${e.message}');
    rethrow;
  }
}

Future<void> removeFile(String path) async {
  try {
    await Amplify.Storage.remove(
      path: StoragePath.fromString(path),
    ).result;
  } on StorageException catch (e) {
    safePrint('Delete error - ${e.message}');
  }
}

Future<void> downloadFileWeb(String path) async {
  try {
    await Amplify.Storage.downloadFile(
      path: StoragePath.fromString(path),
      localFile: AWSFile.fromPath(path),
      onProgress: (p0) => safePrint(
          'Progress: ${(p0.transferredBytes / p0.totalBytes) * 100}%'),
    ).result;
  } on StorageException catch (e) {
    safePrint('Download error - ${e.message}');
  }
}

Future<void> getFileProperties(String path) async {
  try {
    final result = await Amplify.Storage.getProperties(
      path: StoragePath.fromString(path),
    ).result;

    safePrint('File size: ${result.storageItem.size}');
    safePrint('eTag: ${result.storageItem.eTag}');
    safePrint('Last Modified: ${result.storageItem.lastModified}');
  } on StorageException catch (e) {
    safePrint('Could not retrieve properties: ${e.message}');
    rethrow;
  }
}
