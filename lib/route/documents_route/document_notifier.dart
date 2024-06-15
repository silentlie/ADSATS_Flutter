part of 'document_class.dart';

class DocumentNotifier extends ChangeNotifier {
  FilePickerResult? filePickerResult;
  Map<String, String> results = {};

  Future<void> uploadFile(PlatformFile file) async {
    try {
      Map<String, dynamic> body = {
        'file_name': file.name,
        'archived': false,
      };
      body.addAll(results);
      debugPrint(body.toString());
      final restOperation = Amplify.API.post('/documents',
          apiName: 'AmplifyAviationAPI', body: HttpPayload.json(body));

      final response = await restOperation.response;
      String jsonStr = response.decodeBody();
      int documentID = jsonDecode(jsonStr);
      debugPrint("document_id: $documentID");
      String pathStr = "${documentID}_${file.name}";
      final result = await Amplify.Storage.uploadFile(
        localFile: AWSFile.fromStream(
          file.readStream!,
          size: file.size,
        ),
        path: StoragePath.fromString(pathStr),
        onProgress: (progress) {
          // debugPrint('Fraction completed: ${progress.fractionCompleted}');
        },
      ).result;
      debugPrint('Successfully uploaded file: ${result.uploadedItem.path}');
    } on StorageException catch (e) {
      debugPrint(e.message);
    } on ApiException catch (e) {
      debugPrint('GET call failed: $e');
    } on Error catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }

  Future<void> uploadFiles() async {
  await Future.wait(filePickerResult!.files.map((file) => uploadFile(file)));
}
}
