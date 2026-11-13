class SubjectModel {


  final String? id;

  final String subjectCode;

  final String subjectName;

  final int credit;

  final String department;

  final String semester;



  SubjectModel({

    this.id,

    required this.subjectCode,

    required this.subjectName,

    required this.credit,

    required this.department,

    required this.semester,

  });



  Map<String,dynamic> toMap(){


    return {


      "subjectCode":
      subjectCode,


      "subjectName":
      subjectName,


      "credit":
      credit,


      "department":
      department,


      "semester":
      semester,


    };


  }




  factory SubjectModel.fromMap(

      Map<String,dynamic> map,

      String id

      ){


    return SubjectModel(


      id:id,


      subjectCode:
      map["subjectCode"] ?? "",


      subjectName:
      map["subjectName"] ?? "",


      credit:
      map["credit"] ?? 0,


      department:
      map["department"] ?? "",


      semester:
      map["semester"] ?? "",


    );


  }


}