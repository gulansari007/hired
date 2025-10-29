import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class InternetController extends GetxController {
  var hasInternet = true.obs;
  late final Connectivity _connectivity;

  @override
  void onInit() {
    super.onInit();
    _connectivity = Connectivity();
    _checkInternet();

    _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> resultList,
    ) {
      hasInternet.value =
          resultList.isNotEmpty &&
          !resultList.contains(ConnectivityResult.none);
    });
  }

  Future<void> _checkInternet() async {
    var resultList = await _connectivity.checkConnectivity();
    hasInternet.value =
        resultList.isNotEmpty && !resultList.contains(ConnectivityResult.none);
  }
}
