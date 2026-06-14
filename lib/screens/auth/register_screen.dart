import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/theme/app_colors.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPhoneSelected = false;
  bool _agreeTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isPhoneValid = false;
  bool _isOtpValid = false;
  String _selectedRole = 'driver';

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

    _fullNameController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: isSmall ? 14 : 24,
            vertical: isSmall ? 12 : 18,
          ),
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOutCubic,
                    padding: EdgeInsets.fromLTRB(
                      isSmall ? 18 : 28,
                      isSmall ? 24 : 32,
                      isSmall ? 18 : 28,
                      isSmall ? 24 : 30,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFEDEDED)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.10),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/applogo.png',
                            height: 60,
                          ),
                          const SizedBox(height: 24),
                          _buildRegisterTabs(auth),
                          const SizedBox(height: 20),
                          Text(
                            'create_account'.tr(),
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                              color: textDark,
                            ),
                          ),
                          const SizedBox(height: 7),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            child: Text(
                              _isPhoneSelected
                                  ? 'signup_with_mobile'.tr()
                                  : 'signup_with_email'.tr(),
                              key: ValueKey(_isPhoneSelected),
                              style: const TextStyle(
                                fontSize: 15,
                                color: textGrey,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          _buildSmoothFormSwitcher(auth),
                          const SizedBox(height: 18),
                          _buildBottomSignIn(auth),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
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
            key: const ValueKey('register_phone_form'),
            child: _buildPhoneRegisterForm(auth),
          )
              : KeyedSubtree(
            key: const ValueKey('register_email_form'),
            child: _buildEmailRegisterForm(auth),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterTabs(AuthController auth) {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: tabBg,
        borderRadius: BorderRadius.circular(7),
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
                _formKey.currentState?.reset();
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
                _formKey.currentState?.reset();
                setState(() => _isPhoneSelected = false);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneRegisterForm(AuthController auth) {
    final otpSent = auth.isOtpSent && auth.registerOtpPhone != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('full_name'.tr()),
        _buildTextField(
          controller: _fullNameController,
          hint: 'enter_full_name'.tr(),
          icon: Icons.person,
          enabled: !auth.isBusy,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'please_fill_name'.tr();
            }
            if (value.trim().length < 3) {
              return 'name_too_short'.tr();
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        _buildLabel('date_of_birth'.tr()),
        _buildTextField(
          controller: _dobController,
          hint: 'dd/mm/yyyy',
          icon: Icons.calendar_month,
          enabled: !auth.isBusy,
          readOnly: true,
          suffixIcon: Icons.calendar_today_outlined,
          onTap: auth.isBusy ? null : _pickDate,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'select_dob'.tr();
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        _buildLabel('mobile_number'.tr()),
        Row(
          children: [
            Container(
              height: 44,
              width: 58,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.authDisabledBg,
                borderRadius: BorderRadius.circular(6),
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
              child: _buildTextField(
                controller: _phoneController,
                hint: 'enter_mobile_number'.tr(),
                icon: Icons.phone,
                enabled: !auth.isBusy,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: (value) {
                  final phone = value?.replaceAll(RegExp(r'\D'), '') ?? '';
                  if (phone.isEmpty) return 'err_invalid_phone'.tr();
                  if (phone.length != 10) return 'err_invalid_phone'.tr();
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildTermsBox(auth),
        const SizedBox(height: 14),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          child: otpSent
              ? Column(
            key: const ValueKey('register_otp_section'),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLabel('enter_otp'.tr()),
                  GestureDetector(
                    onTap: auth.isBusy ? null : _handlePhoneRegister,
                    child: Text(
                      'resend_otp'.tr(),
                      style: TextStyle(
                        fontSize: 13,
                        color: auth.isBusy ? textGrey : primaryOrange,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              _buildTextField(
                controller: _otpController,
                hint: 'enter_6_digit_otp'.tr(),
                icon: Icons.verified_user_outlined,
                enabled: !auth.isBusy,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                validator: (value) {
                  final otp = value?.replaceAll(RegExp(r'\D'), '') ?? '';
                  if (otp.isEmpty) return 'enter_otp'.tr();
                  if (otp.length != 6) return 'err_invalid_otp'.tr();
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _buildMainButton(
                title: 'verify_otp'.tr(),
                isLoading: auth.isBusy,
                enabled: _isOtpValid,
                onPressed: _handleVerifyRegisterOtp,
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'test_otp_info'.tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: textGrey,
                  ),
                ),
              ),
            ],
          )
              : Column(
            key: const ValueKey('register_send_otp_section'),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMainButton(
                title: 'send_otp'.tr(),
                isLoading: auth.isBusy,
                enabled: _isPhoneValid,
                onPressed: _handlePhoneRegister,
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  _isPhoneValid
                      ? 'otp_send_notice'.tr()
                      : 'enter_10_digit_notice'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
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

  Widget _buildEmailRegisterForm(AuthController auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('full_name'.tr()),
        _buildTextField(
          controller: _fullNameController,
          hint: 'enter_full_name'.tr(),
          icon: Icons.person,
          enabled: !auth.isBusy,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'please_fill_name'.tr();
            }
            if (value.trim().length < 3) {
              return 'name_too_short'.tr();
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        _buildLabel('date_of_birth'.tr()),
        _buildTextField(
          controller: _dobController,
          hint: 'dd/mm/yyyy',
          icon: Icons.calendar_month,
          enabled: !auth.isBusy,
          readOnly: true,
          suffixIcon: Icons.calendar_today_outlined,
          onTap: auth.isBusy ? null : _pickDate,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'select_dob'.tr();
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        _buildLabel('email_address'.tr()),
        _buildTextField(
          controller: _emailController,
          hint: 'your.email@example.com',
          icon: Icons.email,
          enabled: !auth.isBusy,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            final email = value?.trim() ?? '';
            if (email.isEmpty) return 'err_empty_email'.tr();
            if (!_validateEmail(email)) return 'err_invalid_email'.tr();
            return null;
          },
        ),
        const SizedBox(height: 12),
        _buildLabel('password'.tr()),
        _buildTextField(
          controller: _passwordController,
          hint: 'enter_password_hint'.tr(),
          icon: Icons.lock,
          enabled: !auth.isBusy,
          obscureText: _obscurePassword,
          suffixIcon: _obscurePassword ? Icons.visibility : Icons.visibility_off,
          onSuffixTap: () {
            setState(() => _obscurePassword = !_obscurePassword);
          },
          validator: (value) {
            if (value == null || value.isEmpty) return 'please_fill_password'.tr();
            if (value.length < 6) {
              return 'err_password_too_short'.tr();
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        _buildLabel('confirm_password'.tr()),
        _buildTextField(
          controller: _confirmPasswordController,
          hint: 'confirm_password_hint'.tr(),
          icon: Icons.lock,
          enabled: !auth.isBusy,
          obscureText: _obscureConfirmPassword,
          suffixIcon: _obscureConfirmPassword
              ? Icons.visibility
              : Icons.visibility_off,
          onSuffixTap: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) return 'please_fill_confirmPassword'.tr();
            if (value != _passwordController.text) {
              return 'password_not_match'.tr();
            }
            return null;
          },
        ),
        const SizedBox(height: 14),
        _buildTermsBox(auth),
        const SizedBox(height: 14),
        _buildMainButton(
          title: 'create_account'.tr(),
          isLoading: auth.isBusy,
          enabled: true,
          onPressed: _handleEmailRegister,
        ),
      ],
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
          height: 36,
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
                color: Colors.black.withOpacity(0.055),
                blurRadius: 5,
                offset: const Offset(0, 1),
              ),
            ]
                : [],
          ),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: selected ? primaryOrange : textGrey,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 15,
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

  Widget _buildLabel(String title) {
    return RichText(
      text: TextSpan(
        text: title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        children: const [
          TextSpan(
            text: ' *',
            style: TextStyle(color: primaryOrange),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    bool readOnly = false,
    bool enabled = true,
    IconData? suffixIcon,
    VoidCallback? onTap,
    VoidCallback? onSuffixTap,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return SizedBox(
      height: 48,
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        obscureText: obscureText,
        readOnly: readOnly,
        onTap: onTap,
        validator: validator,
        inputFormatters: inputFormatters,
        style: const TextStyle(
          fontSize: 15,
          color: textDark,
        ),
        decoration: InputDecoration(
          hintText: hint,
          counterText: '',
          hintStyle: const TextStyle(
            color: Color(0xFF8E96A3),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            size: 18,
            color: const Color(0xFF9AA3AF),
          ),
          suffixIcon: suffixIcon == null
              ? null
              : IconButton(
            splashRadius: 18,
            onPressed: enabled ? onSuffixTap : null,
            icon: Icon(
              suffixIcon,
              size: 18,
              color: suffixIcon == Icons.calendar_today_outlined
                  ? Colors.black
                  : const Color(0xFF9AA3AF),
            ),
          ),
          filled: true,
          fillColor: enabled ? Colors.white : const Color(0xFFF3F4F6),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: fieldBorder),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: primaryOrange),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: primaryOrange),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: primaryOrange),
          ),
        ),
      ),
    );
  }

  Widget _buildTermsBox(AuthController auth) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: fieldBorder),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: Checkbox(
              value: _agreeTerms,
              activeColor: primaryOrange,
              side: const BorderSide(color: Color(0xFF9AA3AF)),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onChanged: auth.isBusy
                  ? null
                  : (value) {
                setState(() => _agreeTerms = value ?? false);
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: 'i_agree_to'.tr(),
                style: const TextStyle(
                  fontSize: 13,
                  color: textDark,
                ),
                children: [
                  TextSpan(
                    text: 'terms'.tr(),
                    style: const TextStyle(color: primaryOrange),
                  ),
                  TextSpan(text: 'and'.tr()),
                  TextSpan(
                    text: 'privacy_policy'.tr(),
                    style: const TextStyle(color: primaryOrange),
                  ),
                ],
              ),
            ),
          ),
        ],
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
      height: 43,
      child: ElevatedButton(
        onPressed: canClick ? onPressed : null,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: buttonOrange,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFE5E7EB),
          disabledForegroundColor: const Color(0xFF9CA3AF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: isLoading
              ? const SizedBox(
            key: ValueKey('loader'),
            height: 19,
            width: 19,
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

  Widget _buildBottomSignIn(AuthController auth) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          'already_have_account'.tr() + ' ',
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
            context.go('/login');
          },
          child: Text(
            'signin'.tr(),
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

  Future<void> _pickDate() async {
    FocusScope.of(context).unfocus();

    final now = DateTime.now();

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1950),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: primaryOrange,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      final day = selectedDate.day.toString().padLeft(2, '0');
      final month = selectedDate.month.toString().padLeft(2, '0');
      final year = selectedDate.year.toString();

      setState(() {
        _dobController.text = '$year-$month-$day';
      });
    }
  }

  Future<void> _handleEmailRegister() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (!_agreeTerms) {
      _showMessage(
        'err_agree_terms'.tr(),
        backgroundColor: Colors.red,
      );
      return;
    }

    try {
      await ref.read(authControllerProvider).signup(
        fullName: _fullNameController.text.trim(),
        dob: _dobController.text.trim(),
        phone: '',
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        termsAccepted: _agreeTerms,
        role: _selectedRole,
      );

      _showMessage(
        'account_created_login'.tr(),
        backgroundColor: Colors.green,
      );

      if (mounted) {
        context.go('/login');
      }
    } catch (e) {
      _showMessage(
        _cleanError(e),
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> _handlePhoneRegister() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (!_agreeTerms) {
      _showMessage(
        'err_agree_terms'.tr(),
        backgroundColor: Colors.red,
      );
      return;
    }

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
      final phone = _phoneController.text.replaceAll(RegExp(r'\D'), '');

      final message = await ref.read(authControllerProvider).signup(
        fullName: _fullNameController.text.trim(),
        dob: _dobController.text.trim(),
        phone: '+91$phone',
        email: '',
        password: '',
        termsAccepted: _agreeTerms,
        role: _selectedRole,
      );

      _showMessage(message, backgroundColor: Colors.green);
    } catch (e) {
      _showMessage(_cleanError(e), backgroundColor: Colors.red);
    }
  }

  Future<void> _handleVerifyRegisterOtp() async {
    FocusScope.of(context).unfocus();

    final otp = _otpController.text.replaceAll(RegExp(r'\D'), '');

    if (!_validateOtp(otp)) {
      _showMessage(
        'err_invalid_otp'.tr(),
        backgroundColor: Colors.red,
      );
      return;
    }

    try {
      final message = await ref.read(authControllerProvider).verifyRegisterOtp(
        otp: otp,
      );

      _showMessage(message, backgroundColor: Colors.green);

      if (mounted) {
        context.go('/login');
      }
    } catch (e) {
      _showMessage(_cleanError(e), backgroundColor: Colors.red);
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