import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:widget_circular_animator/widget_circular_animator.dart';

import '../../Core/Database/Controllers/auth_controller.dart';
import '../Views/user_file_page.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({Key? key}) : super(key: key);

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;

  @override
  void initState() {
    nameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  _modifyDialogue(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Modify Profile"),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      hintText: "Enter your name",
                    ),
                  ),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      hintText: "Enter your email",
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value != null && !EmailValidator.validate(value)) {
                        return 'Enter a valid email';
                      }
                      if (value!.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      hintText: "Enter your password",
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value!.isEmpty && value.length < 6) {
                        return 'Please enter min. 6 characters';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Save"),
              onPressed: () async {
                final isValid = formKey.currentState!.validate();
                if (!isValid) return;
                bool succes = await AuthController.updateUser(
                  nameController.text,
                  emailController.text,
                  passwordController.text,
                );
                if (succes) {
                  Get.back();
                  Get.snackbar(
                    "Success",
                    "Profile updated",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                } else {
                  Get.back();
                  Get.snackbar(
                    "Error",
                    "Profile not updated",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          return SingleChildScrollView(
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: size.width * 0.1,
                      right: size.width * 0.1,
                    ),
                    child: WidgetCircularAnimator(
                      innerColor: Theme.of(context).primaryColor,
                      outerColor: Theme.of(context).primaryColor,
                      size: size.height * 0.4,
                      child: CircularProfileAvatar(
                        "",
                        cacheImage: true,
                        radius: size.height * 0.35,
                        backgroundColor: Colors.transparent,
                        borderWidth: 0,
                        borderColor: Colors.transparent,
                        child: (snapshot.data.photoURL != null)
                            ? Image.network(snapshot.data.photoURL)
                            : Icon(
                                Icons.person,
                                size: size.height * 0.1,
                              ),
                      ),
                    ),
                  ),
                  VerticalDivider(
                    thickness: 5,
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(width: size.width * 0.1),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      Row(
                        children: [
                          const Text("Name: "),
                          const SizedBox(width: 10),
                          if (snapshot.data.displayName != null)
                            Text(snapshot.data.displayName!),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Email: "),
                          const SizedBox(width: 10),
                          Text(snapshot.data.email!),
                          const SizedBox(width: 10),
                          (snapshot.data.emailVerified)
                              ? const Icon(Icons.verified)
                              : Container(),
                        ],
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () => Get.to(() => const UserFilesPage()),
                        child: const Text("Files"),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            child: const Text("Edit Profile"),
                            onPressed: () {
                              _modifyDialogue(context);
                            },
                          ),
                          const SizedBox(width: 20),
                          ElevatedButton(
                            child: const Text("Send Email Verification"),
                            onPressed: () {
                              FirebaseAuth.instance.currentUser!
                                  .sendEmailVerification();
                            },
                          ),
                          const SizedBox(width: 20),
                          ElevatedButton(
                            child: const Text("Sign Out"),
                            onPressed: () {
                              FirebaseAuth.instance.signOut();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return const Center(
            child: Text("Something went wrong"),
          );
        }
      },
    );
  }
}
