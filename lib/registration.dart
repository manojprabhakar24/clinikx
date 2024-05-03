import 'package:clinikx/Config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';

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

      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                  // Image Widget added here
                  Image.asset(
                  AppConfig.imagelogo, // Provide your image path
                  height: 100, // Adjust the height as needed
                  width:100, // Take full width
                   // Cover the entire space
                ),
                SizedBox(height: 20),
                Center(child: Text('Super Admin Registration', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.blue),)),
               SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTextField(
                        controller: _nameController,
                        labelText: 'Enter Name',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Name is required';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      _buildTextField(
                        controller: _designationController,
                        labelText: 'Enter Designation',
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

                      SizedBox(height: 20),
                      _buildTextField(
                        controller: _mobileController,
                        labelText: 'Enter Mobile Number',
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

                      SizedBox(height: 20),
                      _buildTextField(
                        controller: _emailController,
                        labelText: 'Enter Email',
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

                      SizedBox(height: 20),
                      _buildTextField(
                        controller: _passwordController,
                        labelText: 'Enter Password',
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
                      SizedBox(height: 20),
                      _buildTextField(
                        controller: _confirmPasswordController,
                        labelText: 'Confirm Password',
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
                            QuerySnapshot querySnapshot = await FirebaseFirestore.instance
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
                              }
                            } else {
                              // Save data to Firestore
                              FirebaseFirestore.instance.collection('super_admins').add({
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
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20), // Adjust padding as needed
                          textStyle: TextStyle(fontSize: 16), // Adjust text size as needed
                        ),
                        child: Text('Submit'),
                      ),
                      SizedBox(height: 20),
                      // Image Widget below the button
                      Image.asset(
                        AppConfig.imageaddress, // Provide your image path
                        height:120 , // Adjust the height as needed
                        width: double.infinity, // Take full width
                        fit: BoxFit.cover, // Cover the entire space
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ));
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
      ),
      validator: validator,
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
