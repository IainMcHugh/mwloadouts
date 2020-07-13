import 'dart:io';
import 'package:firebase_admob/firebase_admob.dart';

class AdMobService {

  String getAdMobAppId() {
    if (Platform.isIOS) {
      return null;
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-8463101557576443~1598806608';
    } else {
      return null;
    }
  }

  String getBannerAdId() {
    if (Platform.isIOS) {
      return null;
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-8463101557576443/8275416665';
    }
  }
}
