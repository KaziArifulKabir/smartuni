import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'register_screen.dart';
import 'student_dashboard.dart';
import 'admin_dashboard.dart';

Future<void>? _googleInitialization;

Future<void> initializeGoogleSignIn() {
  return _googleInitialization ??=
      GoogleSignIn.instance.initialize();
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool hidePassword = true;
  bool loading = false;

  final List<String> departments = const [
    'Computer Science & Engineering',
    'Business Administration',
    'Electrical Engineering',
  ];

  final List<String> semesters = const [
    '1st Semester',
    '2nd Semester',
    '3rd Semester',
    '4th Semester',
    '5th Semester',
    '6th Semester',
    '7th Semester',
    '8th Semester',
  ];

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // ==================================================
  // EMAIL AND PASSWORD LOGIN
  // ==================================================

  Future<void> loginUser() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      showMessage('Enter email and password.');
      return;
    }

    setState(() => loading = true);

    try {
      final UserCredential credential =
      await auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final signedInUser = credential.user;

      if (signedInUser == null) {
        await auth.signOut();
        showMessage('Login failed. Please try again.');
        return;
      }

      // Refresh the latest email verification status.
      await signedInUser.reload();

      final user = auth.currentUser;

      // Block email/password login when email is unverified.
      if (user == null || !user.emailVerified) {
        bool? resend = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Email Not Verified'),
            content: const Text(
              'Please verify your email before logging in. '
                  'You can request another verification email below.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext, false);
                },
                child: const Text('Later'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext, true);
                },
                child: const Text('Resend Email'),
              ),
            ],
          ),
        );

        if (resend == true && user != null) {
          await user.sendEmailVerification();
        }

        await auth.signOut();

        showMessage(
          resend == true
              ? 'Verification email sent. Check your Inbox and Spam folder.'
              : 'Verify your email before logging in.',
        );

        return;
      }

      // Verified user: read Firestore profile and check role.
      await openDashboard(
        user,
        allowGoogleProfileCreation: false,
      );
    } on FirebaseAuthException catch (e) {
      await auth.signOut();

      String message = 'Login failed.';

      if (e.code == 'user-not-found') {
        message = 'No account found with this email.';
      } else if (e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        message = 'Incorrect email or password.';
      } else if (e.code == 'invalid-email') {
        message = 'Please enter a valid email address.';
      } else if (e.code == 'too-many-requests') {
        message = 'Too many attempts. Please try again later.';
      }

      showMessage(message);
    } catch (e) {
      await auth.signOut();

      showMessage(
        'Login failed. Check your connection and Firebase settings.',
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  // ==================================================
  // GOOGLE LOGIN
  // ==================================================

  Future<void> loginWithGoogle() async {
    setState(() => loading = true);

    try {
      await initializeGoogleSignIn();

      final GoogleSignInAccount googleUser =
      await GoogleSignIn.instance.authenticate();

      final GoogleSignInAuthentication googleAuth =
          googleUser.authentication;

      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Google ID token was not available.');
      }

      final OAuthCredential credential =
      GoogleAuthProvider.credential(
        idToken: idToken,
      );

      final UserCredential result =
      await auth.signInWithCredential(credential);

      final user = result.user;

      if (user == null) {
        throw Exception('Google sign-in failed.');
      }

      // Google provider has its own email verification.
      // New Google users receive a Student profile.
      await openDashboard(
        user,
        allowGoogleProfileCreation: true,
      );
    } on FirebaseAuthException catch (e) {
      String message = e.message ?? 'Google login failed.';

      if (e.code == 'account-exists-with-different-credential') {
        message =
        'This email is already registered using another sign-in method. '
            'Sign in with your existing method first.';
      }

      showMessage(message);
    } catch (e) {
      print('Google Sign-In Error: $e');
      showMessage(
        'Google login failed. Check Google provider, SHA-1 and connection settings.',
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  // ==================================================
  // FIRST-TIME GOOGLE PROFILE
  // ==================================================

  Future<Map<String, String>?> collectGoogleProfile(
      User user,
      ) async {
    String? selectedDepartment;
    String? selectedSemester;
    String? validationError;

    final studentIdController = TextEditingController();
    final phoneController = TextEditingController();
    final batchController = TextEditingController();
    final bloodController = TextEditingController();
    final sectionController = TextEditingController();

    try {
      return await showDialog<Map<String, String>>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Complete Student Profile'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Welcome ${user.displayName ?? 'Student'}! '
                            'Complete your information to continue.',
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: studentIdController,
                        decoration: const InputDecoration(
                          labelText: 'University ID',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: batchController,
                        decoration: const InputDecoration(
                          labelText: 'Batch',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: bloodController,
                        decoration: const InputDecoration(
                          labelText: 'Blood Group',
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextField(
                        controller: sectionController,
                        decoration: const InputDecoration(
                          labelText: 'Section',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Department',
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
                        onChanged: (value) {
                          setDialogState(() {
                            selectedDepartment = value;
                            validationError = null;
                          });
                        },
                      ),
                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Semester',
                          border: OutlineInputBorder(),
                        ),
                        items: semesters.map((semester) {
                          return DropdownMenuItem<String>(
                            value: semester,
                            child: Text(semester),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            selectedSemester = value;
                            validationError = null;
                          });
                        },
                      ),

                      if (validationError != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          validationError!,
                          style: const TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (studentIdController.text.trim().isEmpty ||
                          selectedDepartment == null ||
                          selectedSemester == null) {
                        setDialogState(() {
                          validationError =
                          'Enter University ID and select department and semester.';
                        });
                        return;
                      }

                      Navigator.pop(
                        dialogContext,
                        {
                          'university_id':
                          studentIdController.text.trim(),
                          'phone':
                          phoneController.text.trim(),
                          'batch':
                          batchController.text.trim(),
                          'department': selectedDepartment!,
                          'semester': selectedSemester!,
                          'blood_group': bloodController.text.trim(),
                          'section': sectionController.text.trim(),
                        },
                      );
                    },
                    child: const Text('Continue'),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      studentIdController.dispose();
      phoneController.dispose();
      batchController.dispose();
      bloodController.dispose();
      sectionController.dispose();
    }
  }

  // ==================================================
  // FIRESTORE PROFILE AND ROLE CHECK
  // ==================================================

  Future<void> openDashboard(
      User user, {
        required bool allowGoogleProfileCreation,
      }) async {
    final userRef = firestore.collection('users').doc(user.uid);
    final userDoc = await userRef.get();

    if (!userDoc.exists) {
      if (!allowGoogleProfileCreation) {
        await auth.signOut();

        showMessage(
          'Your Firestore profile was not found. Please register first.',
        );
        return;
      }

      // First-time Google sign-in: create a Student profile.
      final profile = await collectGoogleProfile(user);

      if (!mounted) return;

      if (profile == null) {
        await auth.signOut();
        await GoogleSignIn.instance.signOut();
        return;
      }

      await userRef.set({
        'user_id': user.uid,
        'university_id': profile['university_id'] ?? '',
        'name': user.displayName ?? 'Student',
        'email': user.email ?? '',
        'phone': profile['phone'] ?? '',
        'blood_group': profile['blood_group'] ?? '',
        'department': profile['department'] ?? '',
        'semester': profile['semester'] ?? '',
        'batch': profile['batch'] ?? '',
        'section': profile['section'] ?? '',
        'role': 'Student',
        'created_at': FieldValue.serverTimestamp(),
      });
    }

    // Read profile after creation or for an existing user.
    final updatedDoc = await userRef.get();

    if (!updatedDoc.exists) {
      await auth.signOut();
      showMessage('User profile could not be loaded.');
      return;
    }

    final data = updatedDoc.data()!;
    final role = (data['role'] ?? 'Student')
        .toString()
        .trim()
        .toLowerCase();

    if (!mounted) return;

    if (role == 'admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const AdminDashboard(),
        ),
      );
    } else if (role == 'student') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const StudentDashboard(),
        ),
      );
    } else {
      await auth.signOut();
      showMessage('This account has an unsupported role.');
    }
  }

  // ==================================================
  // FORGOT PASSWORD
  // ==================================================

  Future<void> forgotPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      showMessage('Enter your email address first.');
      return;
    }

    setState(() => loading = true);

    try {
      await auth.sendPasswordResetEmail(email: email);

      showMessage(
        'If the account exists, a password reset email has been sent.',
      );
    } on FirebaseAuthException {
      showMessage(
        'Could not send the reset email. Check the email address and Firebase settings.',
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  // ==================================================
  // LOGIN SCREEN UI
  // ==================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),

              Center(
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.school,
                    size: 55,
                    color: Colors.blue,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Center(
                child: Text(
                  'SmartUni Companion',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              const Center(
                child: Text(
                  'Student Management System',
                  style: TextStyle(color: Colors.grey),
                ),
              ),

              const SizedBox(height: 50),

              const Text(
                'Login',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 25),

              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 18),

              TextField(
                controller: passwordController,
                obscureText: hidePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      hidePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        hidePassword = !hidePassword;
                      });
                    },
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: loading ? null : forgotPassword,
                  child: const Text('Forgot Password?'),
                ),
              ),

              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: loading ? null : loginUser,
                  child: loading
                      ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : const Text('Login'),
                ),
              ),

              const SizedBox(height: 16),

              const Center(
                child: Text(
                  'OR',
                  style: TextStyle(color: Colors.grey),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: loading ? null : loginWithGoogle,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'G',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text('Continue with Google'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  TextButton(
                    onPressed: loading
                        ? null
                        : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text('Register'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}