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

  bool _isObscurePassword = true;
  bool _isObscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 600) {
                // Desktop view
                return Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Image.asset(
                        'assets/images/img1.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: _buildForm(),
                      ),
                    ),
                  ],
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: _buildForm(),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    'assets/images/Matricallogo.png',
                    height: 100,
                    width: 80,
                    fit: BoxFit.fitWidth,
                  ),
                ],
              ),
            ],
          ),
          Image.asset(
            AppConfig.imagelogo,
            height: 100,
            width: 130,
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
          _buildTextFieldWithIcon(
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
          SizedBox(height: 20),
          _buildTextFieldWithIcon(
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
          SizedBox(height: 20),
          _buildTextFieldWithIcon(
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
          SizedBox(height: 20),
          _buildTextFieldWithIcon(
            controller: _emailController,
            labelText: 'Enter Email',
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email is required';
              } else if (value.length < 6 || value.length > 30) {
                return 'Email must be between 6 and 30 characters long';
              } else if (!RegExp(r'^[a-z0-9._]+@[a-z0-9]+\.[a-z]+')
                  .hasMatch(value)) {
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
          _buildPasswordFieldWithIcon(
            controller: _passwordController,
            labelText: 'Enter Password',
            icon: Icons.lock,
            isObscure: _isObscurePassword,
            onPressed: () {
              setState(() {
                _isObscurePassword = !_isObscurePassword;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required';
              } else if (value.length < 6) {
                return 'Password must be at least 6 characters';
              } else if (!_containsUppercase(value) || !_containsSpecialCharacter(value)) {
                return 'Password must contain at least one uppercase letter and one special character';
              }
              return null;
            },
          ),

          SizedBox(height: 20),
          _buildPasswordFieldWithIcon(
            controller: _confirmPasswordController,
            labelText: 'Confirm Password',
            icon: Icons.lock,
            isObscure: _isObscureConfirmPassword,
            onPressed: () {
              setState(() {
                _isObscureConfirmPassword = !_isObscureConfirmPassword;
              });
            },
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
          Center(
            child: ElevatedButton(
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
                    final status = querySnapshot.docs.first.get('status') ?? '';
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
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                textStyle: TextStyle(fontSize: 18),
              ),
              child: Text('Submit'),
            ),
          ),
      SizedBox(height: 20),
      LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 600) {
            // Desktop view
            return Padding(
              padding: const EdgeInsets.only(right: 300), // Adjust left padding for desktop view
              child: Column(
                 // Align children to the left
                children: [
                  // Place the image address widget here
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Image.asset(
                      AppConfig.imageaddress,
                      height: 80, // Adjust height as needed
                      width: double.infinity,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            );

          } else {
            // Mobile view (no left padding)
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Place the image address widget here
                Image.asset(
                  AppConfig.imageaddress,
                  height: 80, // Adjust height as needed
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
              ],
            );
          }
        },
      ),
    ]));
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
        margin: EdgeInsets.only(bottom: 20),
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
            prefixIcon: Icon(icon),
          ),
          validator: (value) {
            if (validator != null) {
              String? error = validator(value);
              if (error != null) {
                return error;
              }
            }

            // Additional validation for the "Enter Name" field
            if (labelText == 'Enter Name') {
              if (value == null || value.isEmpty) {
                return 'Name is required';
              } else if (!RegExp(r'^[a-zA-Z\s\-]+$').hasMatch(value)) {
                return 'Name must contain only alphabetic characters, spaces, and hyphens';
              } else if (value.length > 50) {
                return 'Name cannot exceed 50 characters';
              }
            }

            return null;
          },
        ));
  }
  Widget _buildPasswordFieldWithIcon({
    required TextEditingController controller,
    required String labelText,
    IconData? icon,
    bool isObscure = true,
    required VoidCallback onPressed,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.text,
        obscureText: isObscure,
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
          prefixIcon: Icon(icon),
          suffixIcon: IconButton(
            icon: Icon(
              isObscure ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey,
            ),
            onPressed: onPressed,
          ),
        ),
        validator: (value) {
          if (validator != null) {
            String? error = validator(value);
            if (error != null) {
              return error;
            }
          }

          // Additional validation for the "Enter Name" field
          if (labelText == 'Enter Name') {
            if (value == null || value.isEmpty) {
              return 'Name is required';
            } else if (!RegExp(r'^[a-zA-Z\s\-]+$').hasMatch(value)) {
              return 'Name must contain only alphabetic characters, spaces, and hyphens';
            } else if (value.length > 50) {
              return 'Name cannot exceed 50 characters';
            }
          }

          return null;
        },
      ));
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
