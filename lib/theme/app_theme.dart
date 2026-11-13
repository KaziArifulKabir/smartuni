import 'package:flutter/material.dart';

class AppTheme {

  static ThemeData lightTheme = ThemeData(

    useMaterial3: true,

    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xff1565C0),
    ),


    scaffoldBackgroundColor:
    const Color(0xffF5F7FB),


    inputDecorationTheme:
    InputDecorationTheme(

      filled: true,

      fillColor: Colors.white,

      border: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(14),

        borderSide:
        BorderSide.none,
      ),


      enabledBorder:
      OutlineInputBorder(

        borderRadius:
        BorderRadius.circular(14),

        borderSide:
        const BorderSide(
          color: Colors.black12,
        ),
      ),


      focusedBorder:
      OutlineInputBorder(

        borderRadius:
        BorderRadius.circular(14),

        borderSide:
        const BorderSide(
          color: Colors.blue,
          width: 2,
        ),
      ),
    ),


    elevatedButtonTheme:
    ElevatedButtonThemeData(

      style:
      ElevatedButton.styleFrom(

        minimumSize:
        const Size(
          double.infinity,
          55,
        ),

        shape:
        RoundedRectangleBorder(

          borderRadius:
          BorderRadius.circular(14),
        ),

        textStyle:
        const TextStyle(
          fontSize: 17,
          fontWeight:
          FontWeight.bold,
        ),
      ),
    ),
  );
}