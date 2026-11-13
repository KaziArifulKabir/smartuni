import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'profile_screen.dart';
import 'courses_screen.dart';
import 'notice_screen.dart';
import 'login_screen.dart';

class StudentDashboard extends StatelessWidget {
const StudentDashboard({super.key});

@override
Widget build(BuildContext context) {
final User? currentUser = FirebaseAuth.instance.currentUser;

// If user is not logged in
if (currentUser == null) {
return const LoginScreen();
}

return Scaffold(
backgroundColor: const Color(0xffF5F7FB),

// ================= APP BAR =================
appBar: AppBar(
backgroundColor: const Color(0xff1565C0),
foregroundColor: Colors.white,
elevation: 0,

title: const Text(
"SmartUni Companion",
style: TextStyle(
fontWeight: FontWeight.bold,
),
),

actions: [
IconButton(
icon: const Icon(Icons.logout),
onPressed: () async {
await FirebaseAuth.instance.signOut();

if (!context.mounted) return;

Navigator.pushAndRemoveUntil(
context,
MaterialPageRoute(
builder: (context) => const LoginScreen(),
),
(route) => false,
);
},
),
],
),

// ================= BODY =================
body: StreamBuilder<DocumentSnapshot>(
stream: FirebaseFirestore.instance
    .collection("users")
    .doc(currentUser.uid)
    .snapshots(),

builder: (context, snapshot) {
// Loading
if (snapshot.connectionState == ConnectionState.waiting) {
return const Center(
child: CircularProgressIndicator(),
);
}

// Error
if (snapshot.hasError) {
return Center(
child: Text(
"Error: ${snapshot.error}",
),
);
}

// User data not found
if (!snapshot.hasData || !snapshot.data!.exists) {
return const Center(
child: Text(
"User data not found",
style: TextStyle(
fontSize: 16,
),
),
);
}

final Map<String, dynamic> data =
snapshot.data!.data() as Map<String, dynamic>;

final String name =
data["name"]?.toString() ?? "Student";

final String department =
data["department"]?.toString() ?? "";

final String semester =
data["semester"]?.toString() ?? "";

final String batch =
data["batch"]?.toString() ?? "";

return SingleChildScrollView(
padding: const EdgeInsets.only(bottom: 30),

child: Column(
crossAxisAlignment: CrossAxisAlignment.start,

children: [

// =====================================================
// STUDENT HEADER
// =====================================================

Container(
width: double.infinity,
padding: const EdgeInsets.all(20),

decoration: const BoxDecoration(
color: Color(0xff1565C0),

borderRadius: BorderRadius.only(
bottomLeft: Radius.circular(30),
bottomRight: Radius.circular(30),
),
),

child: Column(
crossAxisAlignment: CrossAxisAlignment.start,

children: [

// Profile row
Row(
children: [

CircleAvatar(
radius: 30,
backgroundColor: Colors.white,

child: Text(
name.isNotEmpty
? name[0].toUpperCase()
    : "S",

style: const TextStyle(
color: Color(0xff1565C0),
fontSize: 24,
fontWeight: FontWeight.bold,
),
),
),

const SizedBox(width: 15),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,

children: [
const Text(
"Welcome back,",
style: TextStyle(
color: Colors.white70,
fontSize: 14,
),
),

const SizedBox(height: 3),

Text(
name,
maxLines: 1,
overflow: TextOverflow.ellipsis,

style: const TextStyle(
color: Colors.white,
fontSize: 21,
fontWeight: FontWeight.bold,
),
),
],
),
),
],
),

const SizedBox(height: 20),

// Department
if (department.isNotEmpty)
Row(
children: [
const Icon(
Icons.school,
color: Colors.white,
size: 18,
),

const SizedBox(width: 8),

Text(
department,
style: const TextStyle(
color: Colors.white,
fontSize: 14,
),
),
],
),

const SizedBox(height: 8),

// Semester
if (semester.isNotEmpty)
Row(
children: [
const Icon(
Icons.menu_book,
color: Colors.white,
size: 18,
),

const SizedBox(width: 8),

Text(
semester,
style: const TextStyle(
color: Colors.white,
fontSize: 14,
),
),
],
),

const SizedBox(height: 8),

// Batch
if (batch.isNotEmpty)
Row(
children: [
const Icon(
Icons.badge,
color: Colors.white,
size: 18,
),

const SizedBox(width: 8),

Text(
"Batch: $batch",
style: const TextStyle(
color: Colors.white,
fontSize: 14,
),
),
],
),
],
),
),

const SizedBox(height: 25),

// =====================================================
// QUICK ACCESS
// =====================================================

const Padding(
padding: EdgeInsets.symmetric(horizontal: 20),

child: Text(
"Quick Access",
style: TextStyle(
fontSize: 21,
fontWeight: FontWeight.bold,
),
),
),

const SizedBox(height: 15),

Padding(
padding:
const EdgeInsets.symmetric(horizontal: 20),

child: GridView.count(
crossAxisCount: 2,

crossAxisSpacing: 15,
mainAxisSpacing: 15,

shrinkWrap: true,

physics:
const NeverScrollableScrollPhysics(),

childAspectRatio: 1.2,

children: [

dashboardCard(
context,
Icons.person,
"My Profile",
"View your profile",
const Color(0xffE3F2FD),
const Color(0xff1565C0),
const ProfileScreen(),
),

dashboardCard(
context,
Icons.menu_book,
"Courses",
"View your courses",
const Color(0xffF3E5F5),
const Color(0xff7B1FA2),
const CoursesScreen(),
),

dashboardCard(
context,
Icons.notifications,
"Notices",
"Latest notices",
const Color(0xfffff3e0),
const Color(0xffEF6C00),
const NoticeScreen(),
),
],
),
),

const SizedBox(height: 30),

// =====================================================
// RECENT NOTICE TITLE
// =====================================================

Padding(
padding:
const EdgeInsets.symmetric(horizontal: 20),

child: Row(
mainAxisAlignment:
MainAxisAlignment.spaceBetween,

children: [

const Text(
"Recent Notices",
style: TextStyle(
fontSize: 21,
fontWeight: FontWeight.bold,
),
),

TextButton(
onPressed: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (context) =>
const NoticeScreen(),
),
);
},

child: const Text("View All"),
),
],
),
),

const SizedBox(height: 10),

// =====================================================
// NOTICE LIST
// =====================================================

StreamBuilder<QuerySnapshot>(
stream: FirebaseFirestore.instance
    .collection("notices")
    .orderBy(
"date",
descending: true,
)
    .limit(1)
    .snapshots(),

builder: (context, noticeSnapshot) {

// Loading
if (noticeSnapshot.connectionState ==
ConnectionState.waiting) {
return const Center(
child: Padding(
padding: EdgeInsets.all(20),
child:
CircularProgressIndicator(),
),
);
}

// Error
if (noticeSnapshot.hasError) {
return Padding(
padding:
const EdgeInsets.symmetric(
horizontal: 20,
),

child: Text(
"Notice error: "
"${noticeSnapshot.error}",
),
);
}

// Empty
if (!noticeSnapshot.hasData ||
noticeSnapshot.data!.docs.isEmpty) {

return Padding(
padding:
const EdgeInsets.symmetric(
horizontal: 20,
),

child: Container(
width: double.infinity,

padding:
const EdgeInsets.all(20),

decoration: BoxDecoration(
color: Colors.white,

borderRadius:
BorderRadius.circular(18),

border: Border.all(
color: Colors.grey.shade200,
),
),

child: const Column(
children: [

Icon(
Icons.notifications_none,
size: 45,
color: Colors.grey,
),

SizedBox(height: 10),

Text(
"No new notices",
style: TextStyle(
fontWeight:
FontWeight.bold,
fontSize: 16,
),
),

SizedBox(height: 5),

Text(
"New notices will appear here.",
textAlign:
TextAlign.center,
),
],
),
),
);
}

// Notice list
return Padding(
padding:
const EdgeInsets.symmetric(
horizontal: 20,
),

child: Column(
children:
noticeSnapshot.data!.docs.map(
(doc) {

final Map<String, dynamic>
notice =
doc.data()
as Map<String, dynamic>;

final String title =
notice["title"]
    ?.toString() ??
"";

final String description =
notice["description"]
    ?.toString() ??
"";
String date = "";

if (notice["date"] is Timestamp) {
  final Timestamp timestamp = notice["date"];

  final DateTime dateTime = timestamp.toDate();

  date =
  "${dateTime.day} ${_monthName(dateTime.month)} ${dateTime.year}";
}

return Container(
width: double.infinity,

margin:
const EdgeInsets.only(
bottom: 12,
),

padding:
const EdgeInsets.all(16),

decoration: BoxDecoration(
color: Colors.white,

borderRadius:
BorderRadius.circular(
18,
),

boxShadow: [
BoxShadow(
color: Colors.black
    .withOpacity(0.05),
blurRadius: 8,
offset:
const Offset(0, 3),
),
],
),

child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,

children: [

// Title
Row(
crossAxisAlignment:
CrossAxisAlignment.start,

children: [

Container(
width: 40,
height: 40,

decoration:
BoxDecoration(
color:
const Color(
0xffE3F2FD,
),

borderRadius:
BorderRadius
    .circular(
12,
),
),

child:
const Icon(
Icons.campaign,
color:
Color(
0xff1565C0,
),
),
),

const SizedBox(
width: 12),

Expanded(
child: Text(
title,

style:
const TextStyle(
fontSize: 16,
fontWeight:
FontWeight.bold,
),
),
),
],
),

const SizedBox(
height: 10),

// Date
Row(
children: [
const Icon(
Icons
    .calendar_today,
size: 14,
color: Colors.grey,
),

const SizedBox(
width: 5),

Text(
date,

style: const TextStyle(
fontSize: 12,
color: Colors.grey,
),
),
],
),

const SizedBox(
height: 10),

// Description
Text(
description,

maxLines: 3,

overflow:
TextOverflow.ellipsis,

style:
const TextStyle(
fontSize: 14,
color: Colors.black87,
height: 1.4,
),
),
],
),
);
},
).toList(),
),
);
},
),
],
),
);
},
),
);
}
String _monthName(int month) {
  const months = [
    "",
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
  ];

  return months[month];
}
// ==========================================================
// DASHBOARD CARD
// ==========================================================

Widget dashboardCard(
BuildContext context,
IconData icon,
String title,
String subtitle,
Color backgroundColor,
Color iconColor,
Widget page,
) {
return InkWell(
borderRadius: BorderRadius.circular(18),

onTap: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (context) => page,
),
);
},

child: Container(
padding: const EdgeInsets.all(16),

decoration: BoxDecoration(
color: Colors.white,

borderRadius: BorderRadius.circular(18),

boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.05),
blurRadius: 8,
offset: const Offset(0, 3),
),
],
),

child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,

children: [

Container(
width: 48,
height: 48,

decoration: BoxDecoration(
color: backgroundColor,
borderRadius:
BorderRadius.circular(14),
),

child: Icon(
icon,
color: iconColor,
size: 25,
),
),

const SizedBox(height: 12),

Text(
title,

style: const TextStyle(
fontSize: 16,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 5),

Text(
subtitle,

style: const TextStyle(
fontSize: 12,
color: Colors.grey,
),
),
],
),
),
);
}
}
