import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/members_provider.dart';
import '../../utils/enums/status_enum.dart'; // Đảm bảo đã import status enum
import '../../utils/helper.dart';
import '../widgets/common/alert_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _hasAccount = true;

  @override
  Widget build(BuildContext context) {
    // SỬA LỖI 1: Bọc toàn bộ Scaffold bằng Consumer để lắng nghe trạng thái
    return Consumer<MembersProvider>(
      builder: (context, provider, child) {
        // Nếu trạng thái đang là LOADING, hiển thị vòng xoay chờ
        if (provider.status == Status.LOADING) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Nếu không, hiển thị giao diện đăng nhập/đăng ký
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
                  padding:
                  EdgeInsets.symmetric(vertical: 20, horizontal: Helper.hPadding),
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child:
                          _hasAccount ? const SignInWidget() : const SignUpWidget(),
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
                          _hasAccount
                              ? "New account? Sign up"
                              : "Already have an account? Sign in",
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
      },
    );
  }
}

// --- WIDGET ĐĂNG NHẬP ---
class SignInWidget extends StatefulWidget {
  const SignInWidget({super.key});

  @override
  State<SignInWidget> createState() => _SignInWidgetState();
}

class _SignInWidgetState extends State<SignInWidget> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Thêm form key để validate

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // SỬA LỖI 2: Viết lại hoàn toàn hàm xử lý đăng nhập
  void _handleSignIn() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final membersProvider = Provider.of<MembersProvider>(context, listen: false);

    try {
      await membersProvider.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Nếu thành công, listener trong provider sẽ tự động điều hướng.
      // Không cần làm gì thêm ở đây.
    } catch (e) {
      // Bắt lỗi từ Firebase và hiển thị
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialogBox(
            // Hiển thị thông báo lỗi cụ thể hơn
            message: "Đăng nhập thất bại. Vui lòng kiểm tra lại thông tin.",
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
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
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: "Email",
              prefixIcon: const Icon(Icons.email),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            validator: (value) {
              if (value == null || value.isEmpty || !value.contains('@')) {
                return 'Vui lòng nhập email hợp lệ';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: "Password",
              prefixIcon: const Icon(Icons.lock),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập mật khẩu';
              }
              return null;
            },
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
      ),
    );
  }
}

// --- WIDGET ĐĂNG KÝ ---
class SignUpWidget extends StatefulWidget {
  const SignUpWidget({super.key});

  @override
  State<SignUpWidget> createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends State<SignUpWidget> {
  final _formKey = GlobalKey<FormState>();
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

  // SỬA LỖI 3: Viết lại hoàn toàn hàm xử lý đăng ký
  void _handleSignUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final membersProvider = Provider.of<MembersProvider>(context, listen: false);

    try {
      await membersProvider.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        age: int.parse(_ageController.text.trim()),
      );
      // Nếu thành công, listener trong provider sẽ tự động điều hướng.
    } catch (e) {
      // Bắt lỗi từ Firebase (vd: email đã tồn tại) và hiển thị
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialogBox(
              message: "Đăng ký thất bại: Vui lòng thử lại."),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
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
                    border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (v) => v!.isEmpty ? 'Không được bỏ trống' : null,
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
                    border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (v) => v!.isEmpty ? 'Không được bỏ trống' : null,
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
            validator: (v) => v!.isEmpty || !v.contains('@') ? 'Email không hợp lệ' : null,
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: "Password",
              prefixIcon: const Icon(Icons.lock),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            validator: (v) => v!.length < 6 ? 'Mật khẩu phải có ít nhất 6 ký tự' : null,
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: "Confirm Password",
              prefixIcon: const Icon(Icons.lock),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            validator: (v) {
              if (v != _passwordController.text) {
                return 'Mật khẩu không khớp';
              }
              return null;
            },
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
            validator: (v) => v!.isEmpty ? 'Không được bỏ trống' : null,
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
      ),
    );
  }
}
