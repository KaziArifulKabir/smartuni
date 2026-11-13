import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class CoursesScreen extends StatelessWidget {

  const CoursesScreen({super.key});


  @override
  Widget build(BuildContext context) {


    User? user = FirebaseAuth.instance.currentUser;


    if(user == null){

      return const Scaffold(

        body: Center(

          child: Text(
            "User not logged in",
          ),

        ),

      );

    }



    return Scaffold(


      appBar: AppBar(

        title: const Text(
          "My Courses",
        ),

      ),



      body: StreamBuilder<DocumentSnapshot>(


        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .snapshots(),



        builder: (context, userSnapshot){



          if(userSnapshot.connectionState ==
              ConnectionState.waiting){

            return const Center(
              child: CircularProgressIndicator(),
            );

          }



          if(!userSnapshot.hasData ||
              !userSnapshot.data!.exists){


            return const Center(

              child: Text(
                "User data not found",
              ),

            );

          }



          Map<String,dynamic> userData =
          userSnapshot.data!.data()
          as Map<String,dynamic>;



          String department =
              userData["department"] ?? "";

          String semester =
              userData["semester"] ?? "";




          return StreamBuilder<QuerySnapshot>(



            stream: FirebaseFirestore.instance
                .collection("subjects")
                .where(
              "department",
              isEqualTo: department,
            )
                .where(
              "semester",
              isEqualTo: semester,
            )
                .snapshots(),




            builder:(context, subjectSnapshot){



              if(subjectSnapshot.connectionState ==
                  ConnectionState.waiting){


                return const Center(

                  child: CircularProgressIndicator(),

                );

              }




              if(!subjectSnapshot.hasData){


                return const Center(

                  child: Text(
                    "No subject data found",
                  ),

                );

              }




              final subjects =
                  subjectSnapshot.data!.docs;



              print("Total Subjects: ${subjects.length}");





              return SingleChildScrollView(


                padding:
                const EdgeInsets.all(20),




                child: Column(


                  crossAxisAlignment:
                  CrossAxisAlignment.start,



                  children:[



                    Card(

                      elevation:3,


                      shape:
                      RoundedRectangleBorder(

                        borderRadius:
                        BorderRadius.circular(20),

                      ),



                      child: Container(


                        width:
                        double.infinity,


                        padding:
                        const EdgeInsets.all(20),



                        decoration:
                        BoxDecoration(


                          gradient:
                          const LinearGradient(

                            colors:[

                              Color(0xff1565C0),

                              Color(0xff42A5F5),

                            ],

                          ),



                          borderRadius:
                          BorderRadius.circular(20),


                        ),



                        child: Column(


                          crossAxisAlignment:
                          CrossAxisAlignment.start,



                          children:[



                            Text(

                              department,

                              style:
                              const TextStyle(

                                color: Colors.white,

                                fontSize:18,

                                fontWeight:
                                FontWeight.bold,

                              ),

                            ),




                            const SizedBox(height:10),



                            Text(

                              "Semester: $semester",

                              style:
                              const TextStyle(

                                color: Colors.white,

                              ),

                            ),


                          ],


                        ),


                      ),


                    ),





                    const SizedBox(height:25),




                    const Text(

                      "Semester Subjects",

                      style:
                      TextStyle(

                        fontSize:22,

                        fontWeight:
                        FontWeight.bold,

                      ),

                    ),





                    const SizedBox(height:15),





                    if(subjects.isEmpty)



                      const Center(

                        child: Text(

                          "No subjects found",

                        ),

                      )



                    else



                      ListView.builder(


                        shrinkWrap:true,


                        physics:
                        const NeverScrollableScrollPhysics(),



                        itemCount:
                        subjects.length,



                        itemBuilder:(context,index){



                          Map<String,dynamic> data =

                          subjects[index].data()
                          as Map<String,dynamic>;




                          return Card(



                            margin:
                            const EdgeInsets.only(
                              bottom:15,
                            ),



                            elevation:3,



                            child: ListTile(



                              leading:
                              const CircleAvatar(

                                child:
                                Icon(
                                  Icons.book,
                                ),

                              ),




                              title:

                              Text(

                                data["name"] ?? "",

                                style:
                                const TextStyle(

                                  fontWeight:
                                  FontWeight.bold,

                                ),

                              ),





                              subtitle:

                              Text(

                                "${data["code"] ?? ""}\n"
                                    "${data["credit"] ?? ""} Credit",

                              ),



                            ),



                          );


                        },

                      ),




                  ],


                ),



              );


            },

          );


        },


      ),


    );


  }

}