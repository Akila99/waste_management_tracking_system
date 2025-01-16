import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waste_management_tracking/components/services/auth_service.dart';
import 'package:waste_management_tracking/pages/home/components/home_drawer.dart';

class SignupScreen extends StatefulWidget {
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Location selection variables
  String? selectedProvince;
  String? selectedDistrict;
  String? selectedCouncil;
  String? selectedWard;
  String? wardName;

  // Password validation criteria states
  Map<String, bool> _validationCriteria = {
    'length': false,
    'uppercase': false,
    'number': false,
    'special': false,
    'match': false,
  };

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePassword);
    _confirmPasswordController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _validatePassword() {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    setState(() {
      _validationCriteria = {
        'length': password.length >= 8,
        'uppercase': RegExp(r'[A-Z]').hasMatch(password),
        'number': RegExp(r'[0-9]').hasMatch(password),
        'special': RegExp(r'[!@#\$&*~]').hasMatch(password),
        'match': confirmPassword.isNotEmpty && password == confirmPassword,
      };
    });
  }

  void _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_validationCriteria.values.every((isValid) => isValid)) return;
    if (selectedWard == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select your waste collection area")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final name = _nameController.text.trim();

      final User? user = await _authService.signUp(email, password, name);

      if (user != null) {
        // Store additional user data in Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'province': selectedProvince,
          'district': selectedDistrict,
          'council': selectedCouncil,
          'ward': selectedWard,
          'wardName': wardName,
        });

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
                (route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildValidationItem(String text, bool isValid) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.cancel,
          color: isValid ? Colors.green : Colors.red,
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: isValid ? Colors.green : Colors.red,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required Stream<QuerySnapshot> stream,
    required String? value,
    required String title,
    required void Function(String?) onChanged,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        }
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final data = snapshot.data?.docs ?? [];
        if (data.isEmpty) {
          return const Text("No options available");
        }

        final items = data.map((doc) {
          return DropdownMenuItem(
            value: doc.id,
            child: Text(doc['${title}_name']),
          );
        }).toList();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            hint: Text("Select your $title"),
            items: items,
            onChanged: onChanged,
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select your $title';
              }
              return null;
            },
          ),
        );
      },
    );
  }

  Future<void> _fetchWardName(String? wardId) async {
    if (wardId == null) return;
    try {
      final wardDoc = await FirebaseFirestore.instance
          .collection("province")
          .doc(selectedProvince)
          .collection("districts")
          .doc(selectedDistrict)
          .collection("council")
          .doc(selectedCouncil)
          .collection("ward")
          .doc(wardId)
          .get();

      if (wardDoc.exists) {
        setState(() {
          wardName = wardDoc['ward_name'];
        });
      }
    } catch (e) {
      print("Error fetching ward name: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Sign Up'),
          backgroundColor: Colors.green,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                  key: _formKey,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                      const SizedBox(height: 20),
                  const Text(
                    'Create Account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      hintText: 'Enter your name',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      if (value.length < 2) {
                        return 'Name must be at least 2 characters long';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password Fields
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      hintText: 'Confirm your password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  // Password Validation Checklist
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Password must contain:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildValidationItem(
                          'At least 8 characters',
                          _validationCriteria['length']!,
                        ),
                        const SizedBox(height: 4),
                        _buildValidationItem(
                          'At least one uppercase letter',
                          _validationCriteria['uppercase']!,
                        ),
                        const SizedBox(height: 4),
                        _buildValidationItem(
                          'At least one number',
                          _validationCriteria['number']!,
                        ),
                        const SizedBox(height: 4),
                        _buildValidationItem(
                          'At least one special character (!@#\$&*~)',
                          _validationCriteria['special']!,
                        ),
                        const SizedBox(height: 4),
                        _buildValidationItem(
                          'Passwords match',
                          _validationCriteria['match']!,
                        ),
                      ],
                    ),
                  ),

                  // Location Selection
                  const Text(
                    "Select your waste collection area:",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Province Dropdown
                  _buildDropdown(
                    stream: FirebaseFirestore.instance.collection("province").snapshots(),
                    value: selectedProvince,
                    title: "province",
                    onChanged: (value) {
                      setState(() {
                        selectedProvince = value;
                        selectedDistrict = null;
                        selectedCouncil = null;
                        selectedWard = null;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // District Dropdown
                  if (selectedProvince != null)
              _buildDropdown(
          stream: FirebaseFirestore.instance
              .collection("province")
              .doc(selectedProvince)
              .collection("districts")
              .snapshots(),
          value: selectedDistrict,
          title: "district",
          onChanged: (value) {
            setState(() {
              selectedDistrict = value;
              selectedCouncil = null;
              selectedWard = null;
            });
          },
        ),
        if (selectedProvince != null) const SizedBox(height: 16),

    // Council Dropdown
    if (selectedDistrict != null)
    _buildDropdown(
    stream: FirebaseFirestore.instance
        .collection("province")
        .doc(selectedProvince)
        .collection("districts")
        .doc(selectedDistrict)
        .collection("council")
        .snapshots(),
    value: selectedCouncil,
    title: "council",
    onChanged: (value) {
    setState(() {
    selectedCouncil = value;
    selectedWard = null;
    });
    },
    ),
    if (selectedDistrict != null) const SizedBox(height: 16),

    // Ward Dropdown
    if (selectedCouncil != null)
    _buildDropdown(
    stream: FirebaseFirestore.instance
        .collection("province")
        .doc(selectedProvince)
        .collection("districts")
        .doc(selectedDistrict)
        .collection("council")
        .doc(selectedCouncil)
        .collection("ward")
        .snapshots(),
    value: selectedWard,
    title: "ward",
    onChanged: (value) {
    setState(() {
      selectedWard = value;
    });
    _fetchWardName(value);
    },
    ),
                        if (selectedCouncil != null) const SizedBox(height: 16),

                        // Selected Ward Display
                        if (wardName != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green),
                            ),
                            child: Text(
                              "Selected Area: $wardName",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ),

                        const SizedBox(height: 24),

                        // Sign Up Button
                        ElevatedButton(
                          onPressed: _validationCriteria.values.every((isValid) => isValid)
                              ? _signUp
                              : null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.green.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                              : const Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Sign In Link
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Already have an account? Sign In'),
                        ),
                      ],
                  ),
              ),
          ),
        ),
    );
  }
}