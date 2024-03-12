import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:webview/main.dart';

import 'model_Class.dart';



class providerClass with ChangeNotifier{
  var webkey = GlobalKey();
  TextEditingController searchController = TextEditingController();
  InAppWebViewController? webController;
  PullToRefreshController? pullToRefreshController;

  ConnectivityResult connectionStatus = ConnectivityResult.none;
  final Connectivity connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> connectivitySubscription;


  Status s1 = Status.google;
  List<modelclass> bookMark=[];

  setValue(value){
    s1=value;
    notifyListeners();
  }
  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      // developer.log('Couldn\'t check connectivity status', error: e);
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    // if (!mounted) {
    //   return Future.value(null);
    // }

    return updateConnectionStatus(result);
  }

  Future<void> updateConnectionStatus(ConnectivityResult result) async {
      connectionStatus = result;
      notifyListeners();
  }
  addListdata(model){
    bookMark.add(model);
  }
  delateListdata(index){
    bookMark.removeAt(index);
    notifyListeners();
  }

}