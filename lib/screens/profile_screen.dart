import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _openEditProfile(BuildContext context, User user) async {
    try {
      final profileSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!context.mounted) return;

      if (!profileSnapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile data not found.')),
        );
        return;
      }

      final profileData = profileSnapshot.data() ?? <String, dynamic>{};

      final updated = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => EditProfileDialog(
          uid: user.uid,
          profileData: profileData,
        ),
      );

      if (updated == true && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully.')),
        );
      }
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open profile editor: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xff1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (currentUser != null)
            IconButton(
              tooltip: 'Edit Profile',
              onPressed: () => _openEditProfile(context, currentUser),
              icon: const Icon(Icons.edit_rounded),
            ),
        ],
      ),
      body: currentUser == null
          ? const Center(
        child: Text(
          'User not logged in',
          style: TextStyle(fontSize: 16),
        ),
      )
          : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text(
                'Profile data not found',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final Map<String, dynamic> data =
              snapshot.data!.data() ?? <String, dynamic>{};

          final String name = data['name']?.toString() ?? 'Student';
          final String universityId =
              data['university_id']?.toString() ?? '';
          final String email =
              data['email']?.toString() ?? currentUser.email ?? '';
          final String phone = data['phone']?.toString() ?? '';
          final String department =
              data['department']?.toString() ?? '';
          final String semester = data['semester']?.toString() ?? '';
          final String batch = data['batch']?.toString() ?? '';
          final String section = data['section']?.toString() ?? '';
          final String bloodGroup =
              data['blood_group']?.toString() ?? '';

          final String firstLetter = name.trim().isNotEmpty
              ? name.trim()[0].toUpperCase()
              : 'S';

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // PROFILE HEADER
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 25, 20, 30),
                  decoration: const BoxDecoration(
                    color: Color(0xff1565C0),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 105,
                        height: 105,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 48,
                          backgroundColor: const Color(0xffE3F2FD),
                          child: Text(
                            firstLetter,
                            style: const TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff1565C0),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (universityId.isNotEmpty)
                        Text(
                          'University ID: $universityId',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                          ),
                        ),
                      const SizedBox(height: 15),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (department.isNotEmpty)
                            profileChip(Icons.school, department),
                          if (semester.isNotEmpty)
                            profileChip(Icons.menu_book, semester),
                          if (batch.isNotEmpty)
                            profileChip(Icons.groups, 'Batch $batch'),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // PERSONAL INFORMATION
                _sectionTitle('Personal Information'),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      infoCard(
                        icon: Icons.email_rounded,
                        title: 'Email',
                        value: email,
                      ),
                      infoCard(
                        icon: Icons.phone_rounded,
                        title: 'Phone',
                        value: phone,
                      ),
                      infoCard(
                        icon: Icons.bloodtype_rounded,
                        title: 'Blood Group',
                        value: bloodGroup,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ACADEMIC INFORMATION
                _sectionTitle('Academic Information'),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      infoCard(
                        icon: Icons.badge_rounded,
                        title: 'University ID',
                        value: universityId,
                      ),
                      infoCard(
                        icon: Icons.school_rounded,
                        title: 'Department',
                        value: department,
                      ),
                      infoCard(
                        icon: Icons.calendar_month_rounded,
                        title: 'Semester',
                        value: semester,
                      ),
                      infoCard(
                        icon: Icons.groups_rounded,
                        title: 'Batch',
                        value: batch,
                      ),
                      infoCard(
                        icon: Icons.class_rounded,
                        title: 'Section',
                        value: section,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xff1E293B),
          ),
        ),
      ),
    );
  }

  Widget profileChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: const Color(0xffE3F2FD),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: const Color(0xff1565C0),
              size: 22,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isNotEmpty ? value : 'Not provided',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff1E293B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EditProfileDialog extends StatefulWidget {
  final String uid;
  final Map<String, dynamic> profileData;

  const EditProfileDialog({
    super.key,
    required this.uid,
    required this.profileData,
  });

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _universityIdController;
  late final TextEditingController _phoneController;
  late final TextEditingController _bloodGroupController;
  late final TextEditingController _departmentController;
  late final TextEditingController _semesterController;
  late final TextEditingController _batchController;
  late final TextEditingController _sectionController;

  bool _isSaving = false;

  String _initialValue(String key) =>
      widget.profileData[key]?.toString() ?? '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _initialValue('name'));
    _universityIdController =
        TextEditingController(text: _initialValue('university_id'));
    _phoneController = TextEditingController(text: _initialValue('phone'));
    _bloodGroupController =
        TextEditingController(text: _initialValue('blood_group'));
    _departmentController =
        TextEditingController(text: _initialValue('department'));
    _semesterController =
        TextEditingController(text: _initialValue('semester'));
    _batchController = TextEditingController(text: _initialValue('batch'));
    _sectionController = TextEditingController(text: _initialValue('section'));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _universityIdController.dispose();
    _phoneController.dispose();
    _bloodGroupController.dispose();
    _departmentController.dispose();
    _semesterController.dispose();
    _batchController.dispose();
    _sectionController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .update({
        'name': _nameController.text.trim(),
        'university_id': _universityIdController.text.trim(),
        'phone': _phoneController.text.trim(),
        'blood_group': _bloodGroupController.text.trim(),
        'department': _departmentController.text.trim(),
        'semester': _semesterController.text.trim(),
        'batch': _batchController.text.trim(),
        'section': _sectionController.text.trim(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile update failed: $error')),
      );
    }
  }

  Widget _textField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: const Color(0xffF5F7FB),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xffDCE3ED)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Edit Profile',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _textField(
                  label: 'Full Name',
                  controller: _nameController,
                ),
                _textField(
                  label: 'University ID',
                  controller: _universityIdController,
                ),
                _textField(
                  label: 'Phone Number',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                ),
                _textField(
                  label: 'Blood Group',
                  controller: _bloodGroupController,
                  hint: 'Example: A+',
                ),
                _textField(
                  label: 'Department',
                  controller: _departmentController,
                ),
                _textField(
                  label: 'Semester',
                  controller: _semesterController,
                  hint: 'Example: 5th Semester',
                ),
                _textField(
                  label: 'Batch',
                  controller: _batchController,
                ),
                _textField(
                  label: 'Section',
                  controller: _sectionController,
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Email cannot be changed from this form.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _saveProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff1565C0),
            foregroundColor: Colors.white,
          ),
          child: _isSaving
              ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
              : const Text('Save Changes'),
        ),
      ],
    );
  }
}