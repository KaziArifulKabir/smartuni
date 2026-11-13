import 'package:cloud_firestore/cloud_firestore.dart';
class NoticeModel {


  final String? id;


  final String title;


  final String description;


  final DateTime date;

  final String postedBy;


  final String department;




  NoticeModel({


    this.id,


    required this.title,


    required this.description,


    required this.date,


    required this.postedBy,


    required this.department,


  });





  Map<String,dynamic> toMap(){


    return{


      "title":
      title,


      "description":
      description,


      "date": Timestamp.fromDate(date),


      "postedBy":
      postedBy,


      "department":
      department,


    };


  }




  factory NoticeModel.fromMap(

      Map<String,dynamic> map,

      String id

      ){


    return NoticeModel(


      id:id,


      title:
      map["title"] ?? "",


      description:
      map["description"] ?? "",

      date: (map["date"] as Timestamp).toDate(),


      postedBy:
      map["postedBy"] ?? "",


      department:
      map["department"] ?? "",


    );


  }


}