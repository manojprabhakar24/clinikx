import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Config.dart';

class SuperAdminRegistrationForm extends StatefulWidget {
  @override
  _SuperAdminRegistrationFormState createState() =>
      _SuperAdminRegistrationFormState();
}

class _SuperAdminRegistrationFormState
    extends State<SuperAdminRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _designationController = TextEditingController();
  TextEditingController _mobileController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Show image only on desktop view
              if (MediaQuery.of(context).size.width >= 600)
                Expanded(
                  flex: 3,
                  child: Image.asset(
                    'assets/images/img1.png',
                    fit: BoxFit.cover,
                  ),
                ),
              Expanded(
                flex: 7,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Additional text and image above the logo
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Spacer(),
                          Row(
                            children: [
                              Text(
                                'Powered by ',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Image.asset(
                                'assets/images/matrical.jpg',
                                height: 80,
                                width: 50,
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Existing logo
                      Image.asset(
                        AppConfig.imagelogo,
                        height: MediaQuery.of(context).size.width < 600 ? 100 : 200,
                        width: MediaQuery.of(context).size.width < 600 ? 100 : 200,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Super Admin Registration',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextFieldWithIcon(
                                    controller: _nameController,
                                    labelText: 'Enter Name',
                                    icon: Icons.person,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Name is required';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(width: 20),
                                Expanded(
                                  child: _buildTextFieldWithIcon(
                                    controller: _designationController,
                                    labelText: 'Enter Designation',
                                    icon: Icons.work,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Designation is required';
                                      } else if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
                                        return 'Designation must contain only alphabets';
                                      } else if (value.length > 100) {
                                        return 'Designation cannot exceed 100 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextFieldWithIcon(
                                    controller: _mobileController,
                                    labelText: 'Enter Mobile Number',
                                    icon: Icons.phone,
                                    keyboardType: TextInputType.phone,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Mobile number is required';
                                      } else if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
                                        return 'Enter a valid 10-digit mobile number starting with 6, 7, 8, or 9';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(width: 20),
                                Expanded(
                                  child: _buildTextFieldWithIcon(
                                    controller: _emailController,
                                    labelText: 'Enter Email',
                                    icon: Icons.email,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Email is required';
                                      } else if (value.length < 6 || value.length > 30) {
                                        return 'Email must be between 6 and 30 characters long';
                                      } else if (!RegExp(r'^[a-z0-9._]+@[a-z0-9]+\.[a-z]+').hasMatch(value)) {
                                        return 'Enter a valid email address';
                                      } else if (value.startsWith('.') || value.endsWith('.')) {
                                        return 'Email cannot start or end with a dot';
                                      } else if (value.contains('..')) {
                                        return 'Email cannot have two consecutive dots';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextFieldWithIcon(
                                    controller: _passwordController,
                                    labelText: 'Enter Password',
                                    icon: Icons.lock,
                                    obscureText: true,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Password is required';
                                      } else if (value.length < 6) {
                                        return 'Password must be at least 6 characters';
                                      } else if (!_containsUppercase(value) ||
                                          !_containsSpecialCharacter(value)) {
                                        return 'Password must contain at least one uppercase letter and one special character';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(width: 20),
                                Expanded(
                                  child: _buildTextFieldWithIcon(
                                    controller: _confirmPasswordController,
                                    labelText: 'Confirm Password',
                                    icon: Icons.lock,
                                    obscureText: true,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please confirm password';
                                      } else if (value != _passwordController.text) {
                                        return 'Passwords do not match';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () async {
                                var connectivityResult =
                                await Connectivity().checkConnectivity();
                                if (connectivityResult == ConnectivityResult.none) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('No internet connection'),
                                    ),
                                  );
                                  return;
                                }

                                if (_formKey.currentState!.validate()) {
                                  // Check if mobile number already exists and its status
                                  QuerySnapshot querySnapshot = await FirebaseFirestore
                                      .instance
                                      .collection('super_admins')
                                      .where('mobile', isEqualTo: _mobileController.text)
                                      .get();

                                  if (querySnapshot.docs.isNotEmpty) {
                                    final status =
                                        querySnapshot.docs.first.get('status') ?? '';
                                    if (status == 'AA') {
                                      // Mobile number already exists and its status is "AA" (Active)
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Mobile number is already registered. Please use a different number or contact the administrator.'),
                                        ),
                                      );
                                    } else if (status == 'IA') {
                                      // Mobile number already exists and its status is "IA" (Inactive)
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Mobile number is already registered and status is inactive. Please use a different number or contact the administrator.'),
                                        ),
                                      );
                                    } else {
                                      // Mobile number already exists but status is neither "AA" nor "IA"
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Mobile number is already registered with an unknown status. Please contact the administrator.'),
                                        ),
                                      );
                                    }
                                  } else {
                                    // Save data to Firestore
                                    FirebaseFirestore.instance
                                        .collection('super_admins')
                                        .add({
                                      'name': _nameController.text,
                                      'designation': _designationController.text,
                                      'mobile': _mobileController.text,
                                      'email': _emailController.text,
                                      // You may want to encrypt the password before saving it to Firestore
                                      // For demonstration purposes, I'm not encrypting it here
                                      'password': _passwordController.text,
                                    }).then((value) {
                                      // Show registration successful message
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Registration successful'),
                                        ),
                                      );
                                      // Clear form fields after successful registration
                                      _nameController.clear();
                                      _designationController.clear();
                                      _mobileController.clear();
                                      _emailController.clear();
                                      _passwordController.clear();
                                      _confirmPasswordController.clear();
                                    }).catchError((error) {
                                      // Show error message if registration fails
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Error: $error'),
                                        ),
                                      );
                                    });
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                                textStyle: TextStyle(fontSize: 18),
                              ),
                              child: Text('Submit'),
                            ),
                            SizedBox(height: 20),
                            // Image Widget below the button
                            Image.asset(
                              AppConfig.imageaddress,
                              width: double.infinity,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFieldWithIcon({
    required TextEditingController controller,
    required String labelText,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: EdgeInsets.only(right: 20),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              obscureText: obscureText,
              style: TextStyle(fontSize: 16, color: Colors.black),
              decoration: InputDecoration(
                labelText: labelText,
                labelStyle: TextStyle(color: Colors.grey),
                fillColor: Colors.white,
                filled: true,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 1.0),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 2.0),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                errorStyle: TextStyle(color: Colors.red),
                suffixIcon: Icon(icon),
              ),
              validator: validator,
            ),
          ),
        ],
      ),
    );
  }

  bool _containsUppercase(String value) {
    return value.contains(RegExp(r'[A-Z]'));
  }

  bool _containsSpecialCharacter(String value) {
    return value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _designationController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
