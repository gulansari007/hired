import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hired/controllers/callController.dart';
import 'package:hired/views/modal/call_modal.dart';

import 'agora_screen.dart';

class IncomingCallScreen extends StatelessWidget {
  final Call call;
  final CallController _controller = Get.put(CallController());

  IncomingCallScreen({super.key, required this.call});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.video_call, size: 100, color: Colors.white),
            const SizedBox(height: 20),
            Text(
              'Incoming Video Call',
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
            Text(
              'from ${call.callerId}',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  heroTag: 'accept',
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.call),
                  onPressed: () {
                    _controller.firestore
                        .collection("calls")
                        .doc(call.receiverId)
                        .update({'isPicked': true});
                    Get.off(
                      () => AgoraScreen(
                        channelId: call.channelId,
                        callerId: '',
                        receiverId: '',
                      ),
                    );
                  },
                ),
                const SizedBox(width: 40),
                FloatingActionButton(
                  heroTag: 'decline',
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.call_end),
                  onPressed: () {
                    _controller.endCall(call.callerId, call.receiverId);
                    Get.back();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
