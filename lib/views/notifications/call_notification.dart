// lib/widgets/call_popup.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hired/controllers/callController.dart';

class CallPopup extends StatelessWidget {
  final CallController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    final isVideo = controller.callType.value == 'video';

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.95),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 25,
              backgroundImage: AssetImage('assets/images/caller.jpg'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(
                    () => Text(
                      controller.callerName.value,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  Text(
                    isVideo ? 'Incoming video call' : 'Incoming audio call',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.call_end, color: Colors.red),
              onPressed: controller.rejectCall,
            ),
            IconButton(
              icon: Icon(
                isVideo ? Icons.videocam : Icons.call,
                color: Colors.green,
              ),
              onPressed: controller.acceptCall,
            ),
          ],
        ),
      ),
    );
  }
}
