import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Super Admin Registration',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        hintColor: Colors.orangeAccent,
        fontFamily: 'Roboto',
      ),
      home: SuperAdminRegistrationForm(),
    );
  }
}

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
      appBar: AppBar(
        title: Center(child: Text('Super Admin Registration')), // Centered Title
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Form(
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
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Registration successful'),
                              ),
                            );
                          }
                        },
                        child: Text('Submit'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
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
