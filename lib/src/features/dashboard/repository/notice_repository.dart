import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

import '../../../models/notice_model.dart';
import '../../../providers/firebase_providers.dart';
import '../../../providers/utils_providers.dart';

final noticeRepositoryProvider = Provider(
  (ref) => NoticeRepository(
      firebaseStorage: ref.watch(storageProvider),
      roll: ref.watch(userProvider)?.roll ?? '',
      department: ref.watch(userProvider)?.dept ?? '',
      session: ref.watch(userProvider)?.session ?? ''),
);

class NoticeRepository {
  final Reference _noticesRef;
  final String roll, department, session;
  NoticeRepository({
    required FirebaseStorage firebaseStorage,
    required this.roll,
    required this.department,
    required this.session,
  }) : _noticesRef = firebaseStorage.ref('$department/$session/Notice');

  Future<List<Notice>> getAllNotices() async {
    List<Notice> notices = [];
    notices.addAll(await getFBNotices());
    notices.addAll(await getWebNotices());
    // await getWebNotices();
    notices = notices
        .sortWithDate((instance) => instance.timeCreated ?? DateTime.now())
        .reversed
        .toList();
    return notices;
  }

  Future<List<Notice>> getFBNotices() async {
    List<Notice> fbNotices = [];
    try {
      ListResult result = await _noticesRef.listAll();
      for (var fileRef in result.items) {
        await fileRef.getMetadata().then((value) async => fbNotices.add(Notice(
            name: fileRef.name.split('.pdf')[0],
            downloadUrl: await fileRef.getDownloadURL(),
            timeCreated: value.timeCreated)));
      }
    } finally {}
    return fbNotices;
  }

  Future<List<Notice>> getWebNotices() async {
    List<Notice> webNotices = [];
    final url = Uri.parse('https://jgec.ac.in/announcement/1');
    try {
      final Response response = await get(url);
      var document = parse(response.body);
      webNotices = document.querySelectorAll('div.notice-info').map((e) {
        return Notice(
            name: e.querySelector('a')?.innerHtml.trim() ?? '',
            downloadUrl: e.querySelector('a')?.attributes['href']?.trim() ?? '',
            timeCreated: DateFormat('dd MMMM yyyy')
                .parse(e.querySelector('span')!.innerHtml.trim()));
      }).toList();
    } finally {}
    return webNotices;
  }
}
