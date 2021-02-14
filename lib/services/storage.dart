import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage storage = FirebaseStorage.instance;

  Future<String> getWeaponImage(String imageURL) async {
    // StorageReference test = await storage.getReferenceFromUrl(imageURL);
    // var data = await test.getDownloadURL();
    // String dataURL = data.toString();
    var dataURL = await storage.refFromURL(imageURL).getDownloadURL();
    return dataURL;
  }
}
