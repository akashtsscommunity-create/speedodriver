import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/theme/app_colors.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPhoneSelected = true;
  bool _obscurePassword = true;
  bool _isPhoneValid = false;
  bool _isOtpValid = false;

  static const Color primaryOrange = AppColors.primaryOrange;
  static const Color buttonOrange = AppColors.buttonOrange;
  static const Color textDark = AppColors.authTextDark;
  static const Color textGrey = AppColors.authTextGrey;
  static const Color fieldBorder = AppColors.authFieldBorder;
  static const Color tabBg = AppColors.authTabBg;

  @override
  void initState() {
    super.initState();

    _phoneController.addListener(_phoneListener);
    _otpController.addListener(_otpListener);
  }

  void _phoneListener() {
    final valid = _validatePhone(_phoneController.text);
    if (valid != _isPhoneValid) {
      setState(() => _isPhoneValid = valid);
    }
  }

  void _otpListener() {
    final valid = _validateOtp(_otpController.text);
    if (valid != _isOtpValid) {
      setState(() => _isOtpValid = valid);
    }
  }

  @override
  void dispose() {
    _phoneController.removeListener(_phoneListener);
    _otpController.removeListener(_otpListener);

    _phoneController.dispose();
    _otpController.dispose();
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final size = MediaQuery.sizeOf(context);
    final isSmall = size.width < 380;
    final isTablet = size.width >= 600;

    return Scaffold(
      backgroundColor: AppColors.appBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return AnimatedPadding(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.symmetric(
                horizontal: isSmall ? 14 : 24,
                vertical: isSmall ? 12 : 18,
              ),
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isTablet ? 448 : double.infinity,
                    ),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.96, end: 1),
                      duration: const Duration(milliseconds: 420),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.scale(
                            scale: value,
                            child: child,
                          ),
                        );
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // --- HEADER SECTION (Moved outside the card) ---
                          Image.asset(
                            'assets/images/applogo.png',
                            height: 52,
                          ),
                          const SizedBox(height: 12),
                          RichText(
                            textAlign: TextAlign.center,
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Speedo',
                                  style: TextStyle(color: textDark),
                                ),
                                TextSpan(
                                  text: 'Express',
                                  style: TextStyle(color: primaryOrange),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Sign in to continue',
                            style: TextStyle(
                              fontSize: 14,
                              color: textGrey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 24),
                          // --- END HEADER SECTION ---

                          // --- MAIN CARD ---
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 320),
                            curve: Curves.easeOutCubic,
                            padding: EdgeInsets.fromLTRB(
                              isSmall ? 18 : 30,
                              isSmall ? 24 : 32,
                              isSmall ? 18 : 30,
                              isSmall ? 24 : 30,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFEDEDED),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildLoginTabs(auth),
                                const SizedBox(height: 24),
                                Text(
                                  'welcome_back'.tr(),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: textDark,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 220),
                                  child: Text(
                                    _isPhoneSelected
                                        ? 'signin_with_mobile'.tr()
                                        : 'signin_with_email'.tr(),
                                    key: ValueKey(_isPhoneSelected),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: textGrey,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                _buildSmoothFormSwitcher(auth),
                                const SizedBox(height: 24),
                                _buildBottomSignUp(auth),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSmoothFormSwitcher(AuthController auth) {
    return ClipRect(
      child: AnimatedSize(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOutCubicEmphasized,
        alignment: Alignment.topCenter,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 360),
          reverseDuration: const Duration(milliseconds: 260),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          layoutBuilder: (currentChild, previousChildren) {
            return Stack(
              alignment: Alignment.topCenter,
              children: [
                ...previousChildren,
                if (currentChild != null) currentChild,
              ],
            );
          },
          transitionBuilder: (child, animation) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.035, 0),
                  end: Offset.zero,
                ).animate(curved),
                child: ScaleTransition(
                  scale: Tween<double>(
                    begin: 0.985,
                    end: 1,
                  ).animate(curved),
                  alignment: Alignment.topCenter,
                  child: child,
                ),
              ),
            );
          },
          child: _isPhoneSelected
              ? KeyedSubtree(
            key: const ValueKey('login_phone_form'),
            child: _buildPhoneLogin(auth),
          )
              : KeyedSubtree(
            key: const ValueKey('login_email_form'),
            child: _buildEmailLogin(auth),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginTabs(AuthController auth) {
    return Container(
      height: 44, // Slightly taller to match UI tab feel
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: tabBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              title: 'phone'.tr(),
              icon: Icons.phone,
              selected: _isPhoneSelected,
              onTap: auth.isBusy
                  ? null
                  : () {
                if (_isPhoneSelected) return;
                FocusScope.of(context).unfocus();
                ref.read(authControllerProvider).resetOtpState();
                _otpController.clear();
                setState(() => _isPhoneSelected = true);
              },
            ),
          ),
          Expanded(
            child: _buildTabButton(
              title: 'email'.tr(),
              icon: Icons.email,
              selected: !_isPhoneSelected,
              onTap: auth.isBusy
                  ? null
                  : () {
                if (!_isPhoneSelected) return;
                FocusScope.of(context).unfocus();
                ref.read(authControllerProvider).resetOtpState();
                _otpController.clear();
                setState(() => _isPhoneSelected = false);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required IconData icon,
    required bool selected,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: selected ? fieldBorder : Colors.transparent,
            ),
            boxShadow: selected
                ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ]
                : [],
          ),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? primaryOrange : textGrey,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: selected ? primaryOrange : textGrey,
                ),
                const SizedBox(width: 6),
                Text(title),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneLogin(AuthController auth) {
    final otpSent = auth.isOtpSent && auth.loginOtpPhone != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('mobile_number'.tr()),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              height: 46,
              width: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.authDisabledBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: fieldBorder),
              ),
              child: const Text(
                '+91',
                style: TextStyle(
                  fontSize: 15,
                  color: textDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildInputField(
                controller: _phoneController,
                hint: 'enter_mobile_number'.tr(),
                icon: Icons.phone,
                enabled: !auth.isBusy,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          child: otpSent
              ? Column(
            key: const ValueKey('otp_area'),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLabel('enter_otp'.tr()),
                  GestureDetector(
                    onTap: auth.isBusy ? null : _handleSendOtp,
                    child: Text(
                      'resend_otp'.tr(),
                      style: TextStyle(
                        fontSize: 13,
                        color: auth.isBusy ? textGrey : primaryOrange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildInputField(
                controller: _otpController,
                hint: 'enter_6_digit_otp'.tr(),
                icon: Icons.verified_user_outlined,
                enabled: !auth.isBusy,
                keyboardType: TextInputType.number,
                maxLength: 6,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
              ),
              const SizedBox(height: 20),
              _buildMainButton(
                title: 'verify_otp'.tr(),
                isLoading: auth.isBusy,
                enabled: _isOtpValid,
                onPressed: _handleVerifyOtp,
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'test_otp_info'.tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: textGrey,
                  ),
                ),
              ),
            ],
          )
              : Column(
            key: const ValueKey('send_otp_area'),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMainButton(
                title: 'send_otp'.tr(),
                isLoading: auth.isBusy,
                enabled: _isPhoneValid,
                onPressed: _handleSendOtp,
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  _isPhoneValid
                      ? 'otp_send_notice'.tr()
                      : 'enter_10_digit_notice'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: _isPhoneValid ? textGrey : Colors.redAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmailLogin(AuthController auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('email_address'.tr()),
        const SizedBox(height: 8),
        _buildInputField(
          controller: _emailController,
          hint: 'your.email@example.com',
          icon: Icons.email,
          enabled: !auth.isBusy,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildLabel('password'.tr()),
            GestureDetector(
              onTap: auth.isBusy
                  ? null
                  : () {
                _showMessage('forgot_password_msg'.tr());
              },
              child: Text(
                'forgot_q'.tr(),
                style: TextStyle(
                  fontSize: 13,
                  color: auth.isBusy ? textGrey : primaryOrange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildInputField(
          controller: _passwordController,
          hint: 'enter_password_hint'.tr(),
          icon: Icons.lock,
          enabled: !auth.isBusy,
          obscureText: _obscurePassword,
          suffixIcon:
          _obscurePassword ? Icons.visibility : Icons.visibility_off,
          onSuffixTap: () {
            setState(() => _obscurePassword = !_obscurePassword);
          },
        ),
        const SizedBox(height: 24),
        _buildMainButton(
          title: 'signin'.tr(),
          isLoading: auth.isBusy,
          enabled: true,
          onPressed: _handleEmailLogin,
        ),
      ],
    );
  }

  Widget _buildLabel(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: textDark,
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    bool enabled = true,
    int? maxLength,
    IconData? suffixIcon,
    VoidCallback? onSuffixTap,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return SizedBox(
      height: 46, // slightly taller to match design
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        obscureText: obscureText,
        maxLength: maxLength,
        inputFormatters: inputFormatters,
        style: const TextStyle(
          fontSize: 15,
          color: textDark,
        ),
        decoration: InputDecoration(
          counterText: '',
          hintText: hint,
          hintStyle: const TextStyle(
            color: AppColors.authHint,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            size: 18,
            color: AppColors.authIcon,
          ),
          suffixIcon: suffixIcon == null
              ? null
              : IconButton(
            splashRadius: 18,
            onPressed: enabled ? onSuffixTap : null,
            icon: Icon(
              suffixIcon,
              size: 18,
              color: AppColors.authIcon,
            ),
          ),
          filled: true,
          fillColor: enabled ? Colors.white : AppColors.authDisabledBg,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: fieldBorder),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.authDisabledButton),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: primaryOrange),
          ),
        ),
      ),
    );
  }

  Widget _buildMainButton({
    required String title,
    required bool isLoading,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    final canClick = enabled && !isLoading;

    return SizedBox(
      width: double.infinity,
      height: 48, // Slightly taller button
      child: ElevatedButton(
        onPressed: canClick ? onPressed : null,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: buttonOrange,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.authDisabledButton,
          disabledForegroundColor: AppColors.authDisabledText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: isLoading
              ? const SizedBox(
            key: ValueKey('loader'),
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
              : Text(
            title,
            key: ValueKey(title),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSignUp(AuthController auth) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          'dont_have_account'.tr() + ' ',
          style: const TextStyle(
            fontSize: 14,
            color: textGrey,
          ),
        ),
        GestureDetector(
          onTap: auth.isBusy
              ? null
              : () {
            ref.read(authControllerProvider).resetOtpState();
            context.go('/register');
          },
          child: Text(
            'signup'.tr(),
            style: TextStyle(
              fontSize: 14,
              color: auth.isBusy ? textGrey : primaryOrange,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleEmailLogin() async {
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty) {
      _showMessage(
        'err_empty_email'.tr(),
        backgroundColor: Colors.red,
      );
      return;
    }

    if (!_validateEmail(email)) {
      _showMessage(
        'err_invalid_email'.tr(),
        backgroundColor: Colors.red,
      );
      return;
    }

    if (password.isEmpty) {
      _showMessage(
        'err_empty_password'.tr(),
        backgroundColor: Colors.red,
      );
      return;
    }

    if (password.length < 6) {
      _showMessage(
        'err_password_too_short'.tr(),
        backgroundColor: Colors.red,
      );
      return;
    }

    try {
      await ref.read(authControllerProvider).login(email, password, "1");

      _showMessage(
        'login_success'.tr(),
        backgroundColor: Colors.green,
      );

      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      _showMessage(
        _cleanError(e),
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> _handleSendOtp() async {
    FocusScope.of(context).unfocus();

    final phone = _phoneController.text.replaceAll(RegExp(r'\D'), '');

    if (!_validatePhone(phone)) {
      _showMessage(
        'err_invalid_phone'.tr(),
        backgroundColor: Colors.red,
      );
      return;
    }

    _otpController.clear();

    try {
      final message =
      await ref.read(authControllerProvider).sendLoginOtp(phone);

      _showMessage(
        message,
        backgroundColor: Colors.green,
      );
    } catch (e) {
      _showMessage(
        _cleanError(e),
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> _handleVerifyOtp() async {
    FocusScope.of(context).unfocus();

    final phone = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    final otp = _otpController.text.replaceAll(RegExp(r'\D'), '');

    if (!_validatePhone(phone)) {
      _showMessage(
        'err_invalid_phone'.tr(),
        backgroundColor: Colors.red,
      );
      return;
    }

    if (!_validateOtp(otp)) {
      _showMessage(
        'err_invalid_otp'.tr(),
        backgroundColor: Colors.red,
      );
      return;
    }

    try {
      final message = await ref.read(authControllerProvider).verifyLoginOtp(
        phone: phone,
        otp: otp,
      );

      _showMessage(
        message,
        backgroundColor: Colors.green,
      );

      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      _showMessage(
        _cleanError(e),
        backgroundColor: Colors.red,
      );
    }
  }

  bool _validatePhone(String value) {
    final phone = value.replaceAll(RegExp(r'\D'), '');
    return phone.length == 10;
  }

  bool _validateOtp(String value) {
    final otp = value.replaceAll(RegExp(r'\D'), '');
    return otp.length == 6;
  }

  bool _validateEmail(String value) {
    final email = value.trim();
    final regex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,}$');
    return regex.hasMatch(email);
  }

  String _cleanError(Object error) {
    return error.toString().replaceAll('Exception: ', '').trim();
  }

  void _showMessage(
      String message, {
        Color backgroundColor = Colors.black87,
      }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }
}