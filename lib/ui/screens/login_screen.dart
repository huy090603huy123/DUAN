import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/members_provider.dart';

// Giả sử các file này tồn tại và không có lỗi
import '../../utils/helper.dart';
import '../widgets/common/alert_dialog.dart';
// import '../widgets/common/custom_text_field.dart'; // Sẽ không dùng CustomTextField nữa

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _hasAccount = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.25,
              child: Center(
                child: Text(
                  "Libreasy",
                  style: Theme.of(context).textTheme.displayLarge,
                ),
              ),
            ),
            Container(
              color: Colors.white,
              height: MediaQuery.of(context).size.height * 0.75,
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: Helper.hPadding),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: _hasAccount ? const SignInWidget() : const SignUpWidget(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _hasAccount = !_hasAccount;
                      });
                    },
                    child: Text(
                      _hasAccount ? "New account? Sign up" : "Already have an account? Sign in",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SignInWidget extends StatefulWidget {
  const SignInWidget({super.key});

  @override
  State<SignInWidget> createState() => _SignInWidgetState();
}

class _SignInWidgetState extends State<SignInWidget> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn() async {
    final membersProvider = Provider.of<MembersProvider>(context, listen: false);
    membersProvider.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (mounted && !membersProvider.loggedIn) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialogBox(
          message: "Failed to sign in. Invalid Credentials",
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "SIGN IN",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 30),
        // SỬA LỖI: Thay thế CustomTextField bằng TextFormField
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: "Email",
            prefixIcon: const Icon(Icons.email),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 10),
        // SỬA LỖI: Thay thế CustomTextField bằng TextFormField
        TextFormField(
          controller: _passwordController,
          keyboardType: TextInputType.visiblePassword,
          obscureText: true,
          decoration: InputDecoration(
            hintText: "Password",
            prefixIcon: const Icon(Icons.lock),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 20),
        InkWell(
          onTap: () {
            // TODO: Implement forgot password logic
          },
          child: const Text(
            "Forgot password?",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightBlueAccent,
            minimumSize: Size(MediaQuery.of(context).size.width, 50),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          onPressed: _handleSignIn,
          child: const Text(
            "SIGN IN",
            style: TextStyle(
              letterSpacing: 1.4,
              fontSize: 15,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class SignUpWidget extends StatefulWidget {
  const SignUpWidget({super.key});

  @override
  State<SignUpWidget> createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends State<SignUpWidget> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _ageController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _handleSignUp() async {
    // SỬA LỖI: Di chuyển Provider ra ngoài các câu lệnh if để có thể truy cập ở cuối hàm.
    final membersProvider = Provider.of<MembersProvider>(context, listen: false);
    final password = _passwordController.text.trim();
    final cPassword = _confirmPasswordController.text.trim();
    final email = _emailController.text.trim();
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final age = int.tryParse(_ageController.text.trim()) ?? 0;

    // SỬA LỖI: Tách showDialog và return thành hai lệnh riêng biệt.
    if (password != cPassword) {
      showDialog(
        context: context,
        builder: (ctx) =>  AlertDialogBox(message: "Passwords don't match"),
      );
      return; // Dừng hàm tại đây
    }
    if (email.isEmpty || password.isEmpty || firstName.isEmpty || lastName.isEmpty || age <= 0) {
      showDialog(
        context: context,
        builder: (ctx) =>  AlertDialogBox(message: "Please enter all fields"),
      );
      return; // Dừng hàm tại đây
    }

    await membersProvider.signUp(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      age: age,
    );

    if (mounted && !membersProvider.loggedIn) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialogBox(message: "Failed to sign up"),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "SIGN UP",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _firstNameController,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  hintText: "First name",
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: TextFormField(
                controller: _lastNameController,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  hintText: "Last name",
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: "Email",
            prefixIcon: const Icon(Icons.email),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: _passwordController,
          keyboardType: TextInputType.visiblePassword,
          obscureText: true,
          decoration: InputDecoration(
            hintText: "Password",
            prefixIcon: const Icon(Icons.lock),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: _confirmPasswordController,
          keyboardType: TextInputType.visiblePassword,
          obscureText: true,
          decoration: InputDecoration(
            hintText: "Confirm Password",
            prefixIcon: const Icon(Icons.lock),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: _ageController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: "Age",
            prefixIcon: const Icon(Icons.tag),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightBlueAccent,
            minimumSize: Size(MediaQuery.of(context).size.width, 50),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          onPressed: _handleSignUp,
          child: const Text(
            "SIGN UP",
            style: TextStyle(
              letterSpacing: 1.4,
              fontSize: 15,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
