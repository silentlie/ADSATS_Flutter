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
          apiName: 'AmplifyDocumentsAPI', body: HttpPayload.json(body));

      final response = await restOperation.response;
      String jsonStr = response.decodeBody();
      int documentID = jsonDecode(jsonStr);
      debugPrint("document_id: $documentID");

      String pathStr = "${documentID}_${file.name}";
      Map<String, String>? metadata = getMetadata(pathStr);

      debugPrint(getMetadata(pathStr).toString());

      final options = metadata != null
          ? StorageUploadFileOptions(
              metadata: metadata,
            )
          : const StorageUploadFileOptions();

      final result = await Amplify.Storage.uploadFile(
        localFile: AWSFile.fromStream(
          file.readStream!,
          size: file.size,
        ),
        path: StoragePath.fromString(pathStr),
        options: options,
        onProgress: (progress) {
          // debugPrint('Fraction completed: ${progress.fractionCompleted}');
        },
      ).result;
      debugPrint('Successfully uploaded file: ${result.uploadedItem.path}');
    } on StorageException catch (e) {
      debugPrint(e.message);
    } on ApiException catch (e) {
      debugPrint('POST request failed: $e');
    } on Error catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }

  Future<void> uploadFiles() async {
    await Future.wait(filePickerResult!.files.map((file) => uploadFile(file)));
  }
}

// Function to get metadata based on file type
Map<String, String>? getMetadata(String fileName) {
  String extension = p.extension(fileName).toLowerCase();

  switch (extension) {
    case '.png':
      return {'Content-Type': 'image/png'};
    case '.svg':
      return {'Content-Type': 'image/svg+xml'};
    case '.jpg':
    case '.jpeg':
      return {'Content-Type': 'image/jpeg'};
    case '.pdf':
      return {'Content-Type': 'application/pdf'};
    case '.doc':
    case '.docx':
      return {'Content-Type': 'application/msword'};
    default:
      return null;
  }
}
