import 'package:flutter/material.dart';
import '/pantallas/registro.dart';
import '/navegacion_principal.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),

              // Logo principal
              Container(
                width: 110,
                height: 110,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: const Color(0xFF2F80ED),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Iniciar sesión',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF12305B),
                ),
              ),

              const SizedBox(height: 14),

              const Text(
                'Accede a tu monitoreo de salud\ny controla tus niveles.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: Color(0xFF6B7280),
                ),
              ),

              const SizedBox(height: 30),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Correo electrónico',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF12305B),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              const _CustomInput(
                hintText: 'ejemplo@correo.com',
                prefixIcon: Icons.email_outlined,
              ),

              const SizedBox(height: 18),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Contraseña',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF12305B),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              const _CustomInput(
                hintText: 'Ingresa tu contraseña',
                prefixIcon: Icons.lock_outline,
                suffixIcon: Icons.remove_red_eye_outlined,
              ),

              const SizedBox(height: 10),

              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '¿OLVIDASTE TU CONTRASEÑA?',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: 190,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F80ED),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const NavegacionPrincipal()),
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Iniciar sesión',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Row(
                children: const [
                  Expanded(
                    child: Divider(
                      color: Color(0xFFD6DCE5),
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'o continúa con',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9AA4B2),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: Color(0xFFD6DCE5),
                      thickness: 1,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: const [
                  Expanded(
                    child: _SocialButton(
                      text: 'Google',
                      imagePath: 'assets/images/gmail.png',
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _SocialButton(
                      text: 'Apple',
                      imagePath: 'assets/images/apple.png',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegistroScreen(),
                    ),
                  );
                },
                child: const Text(
                  "Crear cuenta",
                  style: TextStyle(
                    color: Color(0xFF2D65D8),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFFD9E9FF),
                      child: Image.asset(
                        'assets/images/autenticador.png',
                        width: 26,
                        height: 26,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Autenticación segura',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF12305B),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Protegemos tus datos con cifrado\nde nivel bancario.',
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.4,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomInput extends StatelessWidget {
  final String hintText;
  final IconData prefixIcon;
  final IconData? suffixIcon;

  const _CustomInput({
    required this.hintText,
    required this.prefixIcon,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFF),
        border: Border.all(
          color: const Color(0xFFCFE0FF),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(
            prefixIcon,
            color: const Color(0xFF2F80ED),
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              hintText,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF9AA4B2),
              ),
            ),
          ),
          if (suffixIcon != null) ...[
            Icon(
              suffixIcon,
              color: const Color(0xFF7C8798),
              size: 20,
            ),
            const SizedBox(width: 12),
          ],
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String text;
  final String imagePath;

  const _SocialButton({
    required this.text,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD6DCE5)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            height: 20,
            width: 20,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF12305B),
            ),
          ),
        ],
      ),
    );
  }
}
