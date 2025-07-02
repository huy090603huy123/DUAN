import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

import '../../providers/members_provider.dart';
import '../../utils/enums/status_enum.dart';
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
    return Consumer<MembersProvider>(
      builder: (context, provider, child) {
        if (provider.status == Status.LOADING) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          body: Stack(
            children: [
              // --- HIỆU ỨNG SÓNG NỀN ---
              const Positioned.fill(child: AnimatedBackground()),
              // --- NỘI DUNG CHÍNH ---
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // --- LOGO/TÊN ỨNG DỤNG ---
                        Text(
                          "Quản Lý Kho",
                          style: GoogleFonts.pacifico(
                            fontSize: 60,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              const Shadow(
                                blurRadius: 10.0,
                                color: Colors.black26,
                                offset: Offset(2.0, 2.0),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        // --- KHUNG ĐĂNG NHẬP/ĐĂNG KÝ ---
                        PlayAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 500),
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.scale(
                                scale: value,
                                child: child,
                              ),
                            );
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 24),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: AnimatedSize(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              child: _hasAccount
                                  ? const SignInWidget()
                                  : const SignUpWidget(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // --- NÚT CHUYỂN ĐỔI ---
                        InkWell(
                          onTap: () {
                            setState(() {
                              _hasAccount = !_hasAccount;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20)),
                            child: Text(
                              _hasAccount
                                  ? "Chưa có tài khoản? Đăng ký ngay"
                                  : "Đã có tài khoản? Đăng nhập",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// --- WIDGET NỀN SÓNG ĐỘNG ---
class AnimatedBackground extends StatelessWidget {
  const AnimatedBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return WaveWidget(
      config: CustomConfig(
        gradients: [
          [Colors.green.shade700, Colors.green.shade400],
          [Colors.green.shade400, Colors.lightGreen.shade300],
          [Colors.lightGreen.shade300, Colors.lightGreen.shade200],
          [Colors.lightGreen.shade200, Colors.green.shade300]
        ],
        durations: [35000, 19440, 10800, 6000],
        heightPercentages: [0.20, 0.23, 0.25, 0.30],
        blur: const MaskFilter.blur(BlurStyle.solid, 10),
        gradientBegin: Alignment.bottomLeft,
        gradientEnd: Alignment.topRight,
      ),
      waveAmplitude: 0,
      size: const Size(double.infinity, double.infinity),
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
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final membersProvider =
    Provider.of<MembersProvider>(context, listen: false);

    try {
      await membersProvider.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => const AlertDialogBox(
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Đăng Nhập",
            style: GoogleFonts.nunito(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade900,
            ),
          ),
          const SizedBox(height: 25),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: _buildInputDecoration("Email", Icons.email_outlined),
            validator: (value) {
              if (value == null || value.isEmpty || !value.contains('@')) {
                return 'Vui lòng nhập email hợp lệ';
              }
              return null;
            },
          ),
          const SizedBox(height: 15),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: _buildInputDecoration("Mật khẩu", Icons.lock_outline),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập mật khẩu';
              }
              return null;
            },
          ),
          const SizedBox(height: 15),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () {
                // TODO: Implement forgot password logic
              },
              child: Text(
                "Quên mật khẩu?",
                style: TextStyle(color: Colors.grey[700]),
              ),
            ),
          ),
          const SizedBox(height: 25),
          ElevatedButton(
            style: _buildButtonStyle(context),
            onPressed: _handleSignIn,
            child: const Text("Đăng Nhập"),
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

  void _handleSignUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final membersProvider =
    Provider.of<MembersProvider>(context, listen: false);

    try {
      await membersProvider.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        age: int.parse(_ageController.text.trim()),
      );
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) =>
          const AlertDialogBox(message: "Đăng ký thất bại: Vui lòng thử lại."),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Tạo Tài Khoản",
            style: GoogleFonts.nunito(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade900,
            ),
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              Expanded(
                  child: TextFormField(
                    controller: _firstNameController,
                    decoration: _buildInputDecoration("Tên", Icons.person_outline),
                    validator: (v) => v!.isEmpty ? 'Không được bỏ trống' : null,
                  )),
              const SizedBox(width: 15),
              Expanded(
                  child: TextFormField(
                    controller: _lastNameController,
                    decoration: _buildInputDecoration("Họ", Icons.person_outline),
                    validator: (v) => v!.isEmpty ? 'Không được bỏ trống' : null,
                  )),
            ],
          ),
          const SizedBox(height: 15),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: _buildInputDecoration("Email", Icons.email_outlined),
            validator: (v) =>
            v!.isEmpty || !v.contains('@') ? 'Email không hợp lệ' : null,
          ),
          const SizedBox(height: 15),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: _buildInputDecoration("Mật khẩu", Icons.lock_outline),
            validator: (v) =>
            v!.length < 6 ? 'Mật khẩu phải có ít nhất 6 ký tự' : null,
          ),
          const SizedBox(height: 15),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: true,
            decoration:
            _buildInputDecoration("Xác nhận Mật khẩu", Icons.lock_outline),
            validator: (v) {
              if (v != _passwordController.text) {
                return 'Mật khẩu không khớp';
              }
              return null;
            },
          ),
          const SizedBox(height: 15),
          TextFormField(
            controller: _ageController,
            keyboardType: TextInputType.number,
            decoration: _buildInputDecoration("Tuổi", Icons.cake_outlined),
            validator: (v) => v!.isEmpty ? 'Không được bỏ trống' : null,
          ),
          const SizedBox(height: 25),
          ElevatedButton(
            style: _buildButtonStyle(context),
            onPressed: _handleSignUp,
            child: const Text("Đăng Ký"),
          ),
        ],
      ),
    );
  }
}

// --- HELPER WIDGETS ĐỂ GIẢM LẶP CODE ---
InputDecoration _buildInputDecoration(String hintText, IconData prefixIcon) {
  return InputDecoration(
    hintText: hintText,
    prefixIcon: Icon(prefixIcon, color: Colors.grey.shade600),
    filled: true,
    fillColor: Colors.grey.shade100,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(color: Colors.green.shade700, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(vertical: 16),
  );
}

ButtonStyle _buildButtonStyle(BuildContext context) {
  return ElevatedButton.styleFrom(
    backgroundColor: Colors.green.shade600,
    foregroundColor: Colors.white,
    minimumSize: Size(MediaQuery.of(context).size.width, 55),
    padding: const EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    textStyle: GoogleFonts.nunito(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.2,
    ),
    elevation: 5,
    shadowColor: Colors.green.withOpacity(0.4),
  );
}