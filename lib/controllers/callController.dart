// // lib/controllers/call_controller.dart
// import 'package:get/get.dart';

// class CallController extends GetxController {
//   var showPopup = false.obs;
//   var callerName = ''.obs;
//   var callType = 'audio'.obs;

//   void showCallPopup(String name, String type) {
//     callerName.value = name;
//     callType.value = type;
//     showPopup.value = true;

//     // Auto dismiss after 10 seconds if not handled
//     Future.delayed(const Duration(seconds: 10), () {
//       if (showPopup.value) dismissPopup();
//     });
//   }

//   void acceptCall() {
//     showPopup.value = false;
//     Get.snackbar('Accepted', 'Connected to ${callerName.value}');
//     // Navigate to call screen
//   }

//   void rejectCall() {
//     showPopup.value = false;
//     Get.snackbar('Call Rejected', 'You rejected the call');
//   }

//   void dismissPopup() {
//     showPopup.value = false;
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:hired/views/agora/agora_screen.dart';
import 'package:hired/views/agora/icomming_call_screen.dart';
import 'package:hired/views/modal/call_modal.dart';

class CallController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  void startCall(String callerId, String receiverId) async {
    final String channelId = DateTime.now().millisecondsSinceEpoch.toString();

    Call call = Call(
      callerId: callerId,
      receiverId: receiverId,
      channelId: channelId,
      hasDialled: true,
      isPicked: false,
    );

    await firestore.collection("calls").doc(callerId).set(call.toMap());
    await firestore.collection("calls").doc(receiverId).set(call.toMap());

    Get.to(
      () => AgoraScreen(
        channelId: call.channelId,
        callerId: call.callerId,
        receiverId: call.receiverId,
      ),
    );
  }

  void listenForCalls(String userId) {
    firestore.collection("calls").doc(userId).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        final data = Call.fromMap(snapshot.data()!);
        if (!data.hasDialled && !data.isPicked) {
          Get.to(() => IncomingCallScreen(call: data));
        }
      }
    });
  }

  Future<void> endCall(String callerId, String receiverId) async {
    await firestore.collection("calls").doc(callerId).delete();
    await firestore.collection("calls").doc(receiverId).delete();
  }

  /////////////
  var showPopup = false.obs;
  var callerName = ''.obs;
  var callType = 'audio'.obs;

  void showCallPopup(String name, String type) {
    callerName.value = name;
    callType.value = type;
    showPopup.value = true;

    // Auto dismiss after 10 seconds if not handled
    Future.delayed(const Duration(seconds: 10), () {
      if (showPopup.value) dismissPopup();
    });
  }

  void acceptCall() {
    showPopup.value = false;
    Get.snackbar('Accepted', 'Connected to ${callerName.value}');
    // Navigate to call screen
  }

  void rejectCall() {
    showPopup.value = false;
    Get.snackbar('Call Rejected', 'You rejected the call');
  }

  void dismissPopup() {
    showPopup.value = false;
  }
}
