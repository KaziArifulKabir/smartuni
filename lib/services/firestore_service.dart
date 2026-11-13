import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';
import '../models/subject_model.dart';
import '../models/notice_model.dart';

class FirestoreService {

  final FirebaseFirestore _db =
      FirebaseFirestore.instance;

// Save User Profile

  Future<void> saveUser(
      UserModel user
      ) async{

    await _db
        .collection("users")
        .doc(user.id)
        .set(
        user.toMap()
    );

  }

// Get User Profile

  Stream<DocumentSnapshot> getUser(

      String uid

      ){

    return _db
        .collection("users")
        .doc(uid)
        .snapshots();


  }

// Add Subject

  Future<void> addSubject(

      SubjectModel subject

      ) async{

    await _db
        .collection("subjects")
        .add(
        subject.toMap()
    );

  }

// Get Subjects

  Stream<QuerySnapshot> getSubjects(){

    return _db
        .collection("subjects")
        .snapshots();

  }

// Add Notice

  Future<void> addNotice(

      NoticeModel notice

      ) async{

    await _db
        .collection("notices")
        .add(
        notice.toMap()
    );

  }

// Get Notices

  Stream<QuerySnapshot> getNotices(){

    return _db
        .collection("notices")
        .orderBy(
        "date",
        descending:true
    )
        .snapshots();


  }

}