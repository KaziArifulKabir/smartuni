import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final nameController = TextEditingController();
  final universityIdController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final bloodController = TextEditingController();
  final batchController = TextEditingController();
  final sectionController = TextEditingController();

  String? selectedDepartment;
  String? selectedSemester;

  bool loading = false;

  final departments = [
    "Computer Science & Engineering",
    "Business Administration",
    "Electrical Engineering",
  ];

  final semesters = [
    "1st Semester",
    "2nd Semester",
    "3rd Semester",
    "4th Semester",
    "5th Semester",
    "6th Semester",
    "7th Semester",
    "8th Semester",
  ];

  Future<void> registerUser() async {
    if (nameController.text.trim().isEmpty ||
        universityIdController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty ||
        selectedDepartment == null ||
        selectedSemester == null) {
      showMessage("Please fill all required fields");
      return;
    }

    if (passwordController.text.length < 6) {
      showMessage("Password must be at least 6 characters");
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      // STEP 1: Create account in Firebase Authentication.
      final UserCredential userCredential =
      await auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final User? user = userCredential.user;

      if (user == null) {
        showMessage("Account creation failed");
        return;
      }

      final String uid = user.uid;

      // STEP 2: Save student profile in Firestore.
      await firestore.collection("users").doc(uid).set({
        "user_id": uid,
        "university_id": universityIdController.text.trim(),
        "name": nameController.text.trim(),
        "email": emailController.text.trim(),
        "phone": phoneController.text.trim(),
        "blood_group": bloodController.text.trim(),
        "department": selectedDepartment,
        "semester": selectedSemester,
        "batch": batchController.text.trim(),
        "section": sectionController.text.trim(),
        "role": "Student",
        "created_at": FieldValue.serverTimestamp(),
      });

      // STEP 3: Send email verification link.
      try {
        await user.sendEmailVerification();
      } on FirebaseAuthException {
        await auth.signOut();

        if (!mounted) return;

        showMessage(
          "Account created, but verification email could not "
              "be sent. Please try logging in to request it again.",
        );
        return;
      }

      // STEP 4: Sign out until email is verified.
      await auth.signOut();

      if (!mounted) return;

      // STEP 5: Show confirmation to the student.
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text("Verify Your Email"),
            content: Text(
              "Your account has been created successfully.\n\n"
                  "A verification link has been sent to "
                  "${emailController.text.trim()}.\n\n"
                  "Please open your email, click the verification "
                  "link, and then log in.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      // Return to Login Screen.
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message = e.message ?? "Registration Failed";

      if (e.code == "email-already-in-use") {
        message = "This email is already registered";
      } else if (e.code == "weak-password") {
        message = "Please choose a stronger password";
      } else if (e.code == "invalid-email") {
        message = "Please enter a valid email address";
      }

      showMessage(message);
    } on FirebaseException {
      if (!mounted) return;

      showMessage(
        "Could not save your profile. Please check your "
            "Firebase connection and try again.",
      );
    } catch (e) {
      if (!mounted) return;

      showMessage("Registration failed. Please try again.");
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Account"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 45,
              child: Icon(
                Icons.person,
                size: 50,
              ),
            ),

            const SizedBox(height: 25),

            buildField(
              nameController,
              "Full Name",
              Icons.person,
            ),

            buildField(
              universityIdController,
              "University ID",
              Icons.badge,
            ),

            buildField(
              emailController,
              "Email",
              Icons.email,
              email: true,
            ),

            buildField(
              passwordController,
              "Password",
              Icons.lock,
              password: true,
            ),

            buildField(
              phoneController,
              "Phone",
              Icons.phone,
              phone: true,
            ),

            buildField(
              bloodController,
              "Blood Group",
              Icons.bloodtype,
            ),

            DropdownButtonFormField<String>(
              value: selectedDepartment,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: "Department",
                border: OutlineInputBorder(),
              ),
              items: departments.map((department) {
                return DropdownMenuItem<String>(
                  value: department,
                  child: Text(
                    department,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: loading
                  ? null
                  : (value) {
                setState(() {
                  selectedDepartment = value;
                });
              },
            ),

            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
              value: selectedSemester,
              decoration: const InputDecoration(
                labelText: "Semester",
                border: OutlineInputBorder(),
              ),
              items: semesters.map((semester) {
                return DropdownMenuItem<String>(
                  value: semester,
                  child: Text(semester),
                );
              }).toList(),
              onChanged: loading
                  ? null
                  : (value) {
                setState(() {
                  selectedSemester = value;
                });
              },
            ),

            const SizedBox(height: 15),

            buildField(
              batchController,
              "Batch",
              Icons.groups,
            ),

            buildField(
              sectionController,
              "Section",
              Icons.class_,
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: loading ? null : registerUser,
                child: loading
                    ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : const Text("Register"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildField(
      TextEditingController controller,
      String label,
      IconData icon, {
        bool password = false,
        bool email = false,
        bool phone = false,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        obscureText: password,
        keyboardType: email
            ? TextInputType.emailAddress
            : phone
            ? TextInputType.phone
            : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    universityIdController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    bloodController.dispose();
    batchController.dispose();
    sectionController.dispose();

    super.dispose();
  }
}