import 'package:flutter/material.dart';
import 'login_screen.dart';


class AdminDashboard extends StatelessWidget {

  const AdminDashboard({super.key});


  @override
  Widget build(BuildContext context) {


    return Scaffold(


      appBar:
      AppBar(

        title:
        const Text(
          "Admin Dashboard",
        ),


        actions:[


          IconButton(

            icon:
            const Icon(
              Icons.logout,
            ),


            onPressed:(){


              Navigator.pushAndRemoveUntil(

                context,

                MaterialPageRoute(

                  builder:
                      (_) =>
                  const LoginScreen(),

                ),

                    (route)=>false,

              );


            },

          )

        ],


      ),



      body:
      SingleChildScrollView(


        padding:
        const EdgeInsets.all(20),



        child:
        Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,


          children:[



            Container(

              width:
              double.infinity,


              padding:
              const EdgeInsets.all(22),



              decoration:
              BoxDecoration(

                gradient:
                const LinearGradient(

                  colors:[

                    Color(0xff4527A0),

                    Color(0xff7E57C2),

                  ],

                ),


                borderRadius:
                BorderRadius.circular(20),

              ),



              child:
              const Column(

                crossAxisAlignment:
                CrossAxisAlignment.start,


                children:[


                  Text(

                    "Welcome Admin 👋",

                    style:
                    TextStyle(

                      color:
                      Colors.white,

                      fontSize:
                      24,

                      fontWeight:
                      FontWeight.bold,

                    ),

                  ),



                  SizedBox(height:10),



                  Text(

                    "Manage SmartUni Companion System",

                    style:
                    TextStyle(

                      color:
                      Colors.white70,

                    ),

                  ),


                ],

              ),

            ),



            const SizedBox(height:30),



            const Text(

              "Management",

              style:
              TextStyle(

                fontSize:
                22,

                fontWeight:
                FontWeight.bold,

              ),

            ),



            const SizedBox(height:15),



            GridView.count(

              shrinkWrap:
              true,


              physics:
              const NeverScrollableScrollPhysics(),


              crossAxisCount:
              2,


              crossAxisSpacing:
              15,


              mainAxisSpacing:
              15,



              children:[



                adminCard(

                  icon:
                  Icons.people,

                  title:
                  "Students",

                ),



                adminCard(

                  icon:
                  Icons.account_balance,

                  title:
                  "Departments",

                ),



                adminCard(

                  icon:
                  Icons.calendar_month,

                  title:
                  "Semesters",

                ),



                adminCard(

                  icon:
                  Icons.menu_book,

                  title:
                  "Subjects",

                ),



                adminCard(

                  icon:
                  Icons.notifications,

                  title:
                  "Notices",

                ),

              ],


            ),



          ],

        ),

      ),

    );

  }





  Widget adminCard({

    required IconData icon,

    required String title,

  }){


    return Container(


      decoration:
      BoxDecoration(

        color:
        Colors.white,


        borderRadius:
        BorderRadius.circular(20),


        boxShadow:[


          BoxShadow(

            color:
            Colors.black12,

            blurRadius:
            8,

          )


        ],


      ),



      child:
      Column(

        mainAxisAlignment:
        MainAxisAlignment.center,


        children:[



          CircleAvatar(

            radius:
            28,


            backgroundColor:
            Colors.deepPurple.shade50,


            child:
            Icon(

              icon,

              size:
              32,

              color:
              Colors.deepPurple,

            ),

          ),



          const SizedBox(height:12),



          Text(

            title,

            style:
            const TextStyle(

              fontSize:
              16,

              fontWeight:
              FontWeight.bold,

            ),

          )


        ],

      ),


    );

  }

}