import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:hired/views/logins/login_screen.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomeController extends GetxController {
  RxBool isLiked = false.obs;
  RxInt likeCount = 0.obs;
  RxBool isComment = false.obs;
  RxInt commentCount = 0.obs;
  bool isSearching = false;
  final TextEditingController searchController = TextEditingController();
  final List<String> searchHistory = [
    'Flutter Developer',
    'UI Designer',
    'Remote Jobs',
  ];

  RxBool isLogin = true.obs;
  final obj = Hive.box('myBox');

  // Logout function
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLogin', false);
    isLogin.value = false;

    Get.offAll(() => LoginScreen());
  }

  // comments
  Future comments(String comm, String postId) async {
    if (comm.isEmpty) {
      Get.snackbar("Error", "Description cannot be empty");
      return;
    }

    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Get.snackbar("Error", "No user is logged in");
      return;
    }

    try {
      final comments = {
        'postId': postId,
        'comments': comm,
        'timestamp': FieldValue.serverTimestamp(),
        // 'username': user.displayName ?? 'Anonymous',
        'user': obj.get('name') ?? 'Anonymous',
        'userImage': user.photoURL ?? '',
        'uid': user.uid,
      };

      await FirebaseFirestore.instance
          .collection('comments')
          .add(comments); // use `.add()` for auto-generated ID

      await updateCommentCount(postId);

      Get.back();
    } catch (error) {
      print('${error}');
    }
  }

  // update comments
  Future<void> updateCommentCount(String postId) async {
    final query =
        await FirebaseFirestore.instance
            .collection('comments')
            .where('postId', isEqualTo: postId)
            .get();

    final count = query.docs.length;

    await FirebaseFirestore.instance.collection('posts').doc(postId).update({
      'commentCount': count,
    });
  }

  // likes
  Future like(int like, String postId) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Get.snackbar("Error", "No user is logged in");
      return;
    }

    try {
      final likes = {
        'postId': postId,
        'likes': like,
        'user': obj.get('name') ?? 'Anonymous',
        'uid': user.uid,
      };

      await FirebaseFirestore.instance
          .collection('likes')
          .add(likes); // use `.add()` for auto-generated ID

      Get.back();
    } catch (error) {
      print('${error}');
    }
  }
}

//
class ShortMessages implements timeago.LookupMessages {
  @override
  String prefixAgo() => '';
  @override
  String prefixFromNow() => '';
  @override
  String suffixAgo() => '';
  @override
  String suffixFromNow() => '';
  @override
  String lessThanOneMinute(int seconds) => 'now';
  @override
  String aboutAMinute(int minutes) => '1m';
  @override
  String minutes(int minutes) => '${minutes}m';
  @override
  String aboutAnHour(int minutes) => '1h';
  @override
  String hours(int hours) => '${hours}h';
  @override
  String aDay(int hours) => '1d';
  @override
  String days(int days) => '${days}d';
  @override
  String aboutAMonth(int days) => '1mo';
  @override
  String months(int months) => '${months}mo';
  @override
  String aboutAYear(int year) => '1y';
  @override
  String years(int years) => '${years}y';
  @override
  String wordSeparator() => ' ';
}
