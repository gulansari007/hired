class Call {
  final String callerId;
  final String receiverId;
  final String channelId;
  final bool hasDialled;
  final bool isPicked;

  Call({
    required this.callerId,
    required this.receiverId,
    required this.channelId,
    required this.hasDialled,
    required this.isPicked,
  });

  Map<String, dynamic> toMap() {
    return {
      'callerId': callerId,
      'receiverId': receiverId,
      'channelId': channelId,
      'hasDialled': hasDialled,
      'isPicked': isPicked,
    };
  }

  factory Call.fromMap(Map<String, dynamic> map) {
    return Call(
      callerId: map['callerId'],
      receiverId: map['receiverId'],
      channelId: map['channelId'],
      hasDialled: map['hasDialled'],
      isPicked: map['isPicked'],
    );
  }
}
