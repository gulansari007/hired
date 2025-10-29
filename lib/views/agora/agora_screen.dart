import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hired/controllers/callController.dart';
import 'package:hired/views/agora/constant.dart';
import 'package:permission_handler/permission_handler.dart';

class AgoraScreen extends StatefulWidget {
  final String channelId;

  final String callerId;
  final String receiverId;
  const AgoraScreen({
    super.key,
    required this.channelId,
    required this.callerId,
    required this.receiverId,
  });

  @override
  State<AgoraScreen> createState() => _AgoraScreenState();
}

class _AgoraScreenState extends State<AgoraScreen> {
  final callController = Get.put(CallController());

  late RtcEngine _engine;
  bool localUserJoined = false;
  int? remoteUserJoined;

  @override
  void initState() {
    initAgora();
    super.initState();
  }

  Future<void> initAgora() async {
    await [Permission.microphone, Permission.camera].request();

    if (await Permission.microphone.isGranted &&
        await Permission.camera.isGranted) {
      _engine = createAgoraRtcEngine();
      await _engine.initialize(
        RtcEngineContext(
          appId: appId,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ),
      );
      await _engine.enableVideo();
      await _engine.startPreview();

      _engine.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            print(
              "Local user ${connection.localUid} joined channel ${connection.channelId}",
            );
            setState(() {
              localUserJoined = true;
            });
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            print(
              "Remote user $remoteUid joined channel ${connection.channelId}",
            );
            setState(() {
              remoteUserJoined = remoteUid;
            });
          },
          onUserOffline: (
            RtcConnection connection,
            int remoteUid,
            UserOfflineReasonType reason,
          ) {
            print(
              "Remote user $remoteUid left channel ${connection.channelId}",
            );
            setState(() {
              remoteUserJoined = null;
            });
          },
        ),
      );

      await _engine.joinChannel(
        token: token,
        channelId: widget.channelId,
        uid: 0,
        options: ChannelMediaOptions(
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
        ),
      );
    } else {
      print("Permissions not granted");
    }
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agora')),
      body: Stack(
        children: [
          Center(child: remoteVideo()),
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 100,
              height: 150,
              child: Center(
                child:
                    localUserJoined
                        ? AgoraVideoView(
                          controller: VideoViewController(
                            rtcEngine: _engine,
                            canvas: const VideoCanvas(uid: 0),
                          ),
                        )
                        : const CircularProgressIndicator(),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: FloatingActionButton(
                onPressed: () async {
                  final callCtrl = Get.find<CallController>();
                  await callCtrl.endCall(widget.callerId, widget.receiverId);

                  await _engine.leaveChannel();
                  Navigator.pop(context);
                },

                backgroundColor: Colors.red,
                child: const Icon(Icons.call_end, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget remoteVideo() {
    if (remoteUserJoined != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: remoteUserJoined!),
          connection: RtcConnection(channelId: widget.channelId),
        ),
      );
    } else {
      return const Center(child: Text('Waiting for remote user to join...'));
    }
  }
}
