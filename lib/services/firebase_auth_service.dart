import 'package:firebase_auth/firebase_auth.dart';
class FirebaseAuthService {
  final FirebaseAuth _auth =
      FirebaseAuth.instance;
  // Register User

  Future<User?> registerUser(

      String email,

      String password,

      ) async {

    try{

      UserCredential result =

      await _auth
          .createUserWithEmailAndPassword(

        email: email,

        password: password,

      );

      return result.user;

    }catch(e){


      throw Exception(
          e.toString()
      );

    }

  }


  // Login User

  Future<User?> loginUser(

      String email,

      String password,

      ) async{

    try{

      UserCredential result =

      await _auth
          .signInWithEmailAndPassword(

        email: email,

        password: password,

      );

      return result.user;

    }catch(e){

      throw Exception(
          e.toString()
      );

    }

  }

  // Logout

  Future<void> logout() async{


    await _auth.signOut();


  }

  // Current User

  User? get currentUser{


    return _auth.currentUser;

  }

}