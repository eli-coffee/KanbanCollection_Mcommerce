import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';


class BrandLogo extends StatelessWidget {
  final double height;
  const BrandLogo({super.key, this.height = 56});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      height: height,
      errorBuilder: (_, _, _) =>
          Icon(Icons.smart_toy_outlined, size: height, color: Colors.white),
    );
  }
}

class BrandBanner extends StatelessWidget {
  const BrandBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: const BoxDecoration(
        gradient:
            LinearGradient(colors: [Color(0xFF16253F), AppColors.purple]),
      ),
      child: Row(
        children: [
          const BrandLogo(height: 58),
          const SizedBox(width: 12),
          Text('Kanban\nCollectibles',
              style: AppText.display(size: 20, color: Colors.white)
                  .copyWith(height: 1.05)),
        ],
      ),
    );
  }
}

/// White pill input with the label underneath (as in the mockup).
/// When [maxLength] is set, the label line also shows the live count, e.g. 5/20.
class PillField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscure;
  final Widget? suffix;
  final int? maxLength;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;

  const PillField({
    super.key,
    required this.controller,
    required this.label,
    this.obscure = false,
    this.suffix,
    this.maxLength,
    this.keyboardType,
    this.onSubmitted,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.black87),
            boxShadow: const [
              BoxShadow(color: Color.fromARGB(255, 8, 9, 19), offset: Offset(0, 3)),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            onSubmitted: onSubmitted,
            style: const TextStyle(color: Colors.black87, fontSize: 16),
            cursorColor: Colors.black87,
            inputFormatters: maxLength == null
                ? null
                : [LengthLimitingTextInputFormatter(maxLength)],
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              suffixIcon: suffix,
            ),
          ),
        ),
        const SizedBox(height: 6),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (_, v, _) => Text(
            maxLength == null ? label : '$label   ${v.text.length}/$maxLength',
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
        ),
      ],
    );
  }
}

class PillButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool loading;

  const PillButton({
    super.key,
    required this.text,
    this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.yellow,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.black),
        boxShadow: const [
          BoxShadow(color: Color.fromARGB(255, 8, 9, 19), offset: Offset(0, 3)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            child: loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : Text(text, style: AppText.display(size: 20)),
          ),
        ),
      ),
    );
  }
}

/// Photo on top, white card, indigo panel with logo, title, fields and button.
class AuthShell extends StatelessWidget {
  final String title;
  final List<Widget> fields;
  final Widget button;
  final Widget footer;
  final String? error;

  const AuthShell({
    super.key,
    required this.title,
    required this.fields,
    required this.button,
    required this.footer,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFCFDDE8), Color(0xFF2E3550)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Stack(
                  children: [
                    SizedBox(
                      height: 330,
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(36),
                        child: Image.asset(
                          'assets/images/operao.jpg',
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                          errorBuilder: (_, _, _) =>
                              Container(color: const Color(0xFF9FB4C9)),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 260),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(36),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.fromLTRB(20, 20, 20, 26),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(36),
                                gradient: const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [AppColors.indigo, AppColors.blue],
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      const BrandLogo(height: 64),
                                      const SizedBox(width: 16),
                                      Text('Kanban\nCollectibles',
                                          style: AppText.display(
                                                  size: 22,
                                                  color: Colors.white)
                                              .copyWith(height: 1.05)),
                                    ],
                                  ),
                                  const SizedBox(height: 22),
                                  Text(title,
                                      style: AppText.display(
                                          size: 24, color: Colors.white)),
                                  const SizedBox(height: 16),
                                  ...fields,
                                  if (error != null) ...[
                                    const SizedBox(height: 10),
                                    Text(error!,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            color: Color(0xFFFFC2C2))),
                                  ],
                                  const SizedBox(height: 14),
                                  button,
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            footer,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}