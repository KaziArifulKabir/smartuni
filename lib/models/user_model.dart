class UserModel {

  final String? id;

  final String name;

  final String universityId;

  final String email;

  final String phone;

  final String bloodGroup;

  final String department;

  final String semester;

  final String batch;

  final String section;

  final String role;


  UserModel({

    this.id,

    required this.name,

    required this.universityId,

    required this.email,

    required this.phone,

    required this.bloodGroup,

    required this.department,

    required this.semester,

    required this.batch,

    required this.section,

    required this.role,

  });



  // Convert Object → Firebase Document

  Map<String,dynamic> toMap(){

    return {

      "name": name,

      "universityId": universityId,

      "email": email,

      "phone": phone,

      "bloodGroup": bloodGroup,

      "department": department,

      "semester": semester,

      "batch": batch,

      "section": section,

      "role": role,

    };

  }



  // Firebase Document → Object

  factory UserModel.fromMap(
      Map<String,dynamic> map,
      String id
      ){

    return UserModel(

      id:id,

      name: map["name"] ?? "",

      universityId:
      map["universityId"] ?? "",

      email:
      map["email"] ?? "",

      phone:
      map["phone"] ?? "",

      bloodGroup:
      map["bloodGroup"] ?? "",

      department:
      map["department"] ?? "",

      semester:
      map["semester"] ?? "",

      batch:
      map["batch"] ?? "",

      section:
      map["section"] ?? "",

      role:
      map["role"] ?? "Student",

    );

  }

}