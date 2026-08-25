import 'package:flutter/material.dart';
import 'package:garlic/view/screens/home_screen.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/loginScreen';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _pin = '';
  bool _error = false;

  void _submit() {
    if (_pin == '111111') {
      Navigator.pushNamedAndRemoveUntil(
        context,
        HomeScreen.routeName,
        (_) => false,
      );
    } else {
      setState(() => _error = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              const Text(
                '마늘·양파 현장조사',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'PIN 6자리를 입력하세요',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 40),
              PinCodeTextField(
                appContext: context,
                length: 6,
                obscureText: true,
                keyboardType: TextInputType.number,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(8),
                  fieldHeight: 48,
                  fieldWidth: 42,
                  activeFillColor: Colors.white,
                  inactiveFillColor: Colors.grey.shade100,
                  selectedFillColor: Colors.white,
                  activeColor: const Color(0xFF2F6B4F),
                  selectedColor: const Color(0xFF2F6B4F),
                  inactiveColor: Colors.grey.shade300,
                ),
                enableActiveFill: true,
                onChanged: (v) {
                  _pin = v;
                  if (_error) setState(() => _error = false);
                },
                onCompleted: (_) => _submit(),
              ),
              if (_error)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'PIN이 올바르지 않습니다 (111111)',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              const Spacer(),
              FilledButton(
                onPressed: _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2F6B4F),
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('입장'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
