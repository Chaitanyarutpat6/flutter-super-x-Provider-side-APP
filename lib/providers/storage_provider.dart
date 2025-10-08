import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class StorageProvider with ChangeNotifier {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // --- Reusable method to upload an image ---
  Future<String?> uploadImage(XFile imageFile, String folderName, String fileName) async {
    try {
      // 1. Create a reference to the location you want to upload to
      Reference ref = _storage.ref().child(folderName).child(fileName);

      // 2. Upload the file
      UploadTask uploadTask = ref.putFile(File(imageFile.path));

      // 3. Wait for the upload to complete
      TaskSnapshot snapshot = await uploadTask;

      // 4. Get the download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      print('File uploaded successfully. URL: $downloadUrl');
      return downloadUrl;

    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
}