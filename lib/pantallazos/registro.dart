import 'package:flutter/material.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController fechaController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();
  final TextEditingController confirmarController = TextEditingController();

  bool aceptarTerminos = false;
  bool ocultarContrasena = true;
  bool ocultarConfirmar = true;

  @override
  void dispose() {
    nombreController.dispose();
    correoController.dispose();
    fechaController.dispose();
    telefonoController.dispose();
    contrasenaController.dispose();
    confirmarController.dispose();
    super.dispose();
  }

  InputDecoration customInput({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF5B8DEF), size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFD8E2F1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF5B8DEF), width: 1.5),
      ),
    );
  }

  Widget buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF2F3A4A),
        ),
      ),
    );
  }

  Future<void> seleccionarFecha() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2005),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        fechaController.text =
        "${pickedDate.day.toString().padLeft(2, '0')} / "
            "${pickedDate.month.toString().padLeft(2, '0')} / "
            "${pickedDate.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF5F7FB),
        title: const Text(
          'Registro',
          style: TextStyle(
            color: Color(0xFFB0B7C3),
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: 55,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'GlucoSmart',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2D65D8),
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Monitorea tu salud y controla tu glucosa',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF9AA5B5),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF1FF),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Text(
                        'Crear cuenta',
                        style: TextStyle(
                          color: Color(0xFF5B8DEF),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Center(
                child: Text(
                  'Completa tus datos',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F3B74),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Registrarte para comenzar a cuidar tu\nsalud y llevar un mejor control',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF5E6A7D),
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              buildLabel('Nombre completo'),
              TextField(
                controller: nombreController,
                decoration: customInput(
                  hint: 'Ejemplo: Luis Marroquín Cardenas',
                  icon: Icons.person_outline,
                ),
              ),
              const SizedBox(height: 16),

              buildLabel('Correo electronico'),
              TextField(
                controller: correoController,
                decoration: customInput(
                  hint: 'ejemplo@correo.com',
                  icon: Icons.mail_outline,
                ),
              ),
              const SizedBox(height: 16),

              buildLabel('Fecha de nacimiento'),
              TextField(
                controller: fechaController,
                readOnly: true,
                onTap: seleccionarFecha,
                decoration: customInput(
                  hint: 'dd / mm / aaaa',
                  icon: Icons.calendar_month_outlined,
                  suffixIcon: IconButton(
                    onPressed: seleccionarFecha,
                    icon: const Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: Color(0xFF7D8797),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              buildLabel('Telefono (opcional)'),
              TextField(
                controller: telefonoController,
                keyboardType: TextInputType.phone,
                decoration: customInput(
                  hint: '+502 1234 5678',
                  icon: Icons.phone_outlined,
                ),
              ),
              const SizedBox(height: 16),

              buildLabel('Contraseña'),
              TextField(
                controller: contrasenaController,
                obscureText: ocultarContrasena,
                decoration: customInput(
                  hint: 'Crea una contraseña',
                  icon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        ocultarContrasena = !ocultarContrasena;
                      });
                    },
                    icon: Icon(
                      ocultarContrasena
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFF7D8797),
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              buildLabel('Confirmar contraseña'),
              TextField(
                controller: confirmarController,
                obscureText: ocultarConfirmar,
                decoration: customInput(
                  hint: 'Confirma tu contraseña',
                  icon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        ocultarConfirmar = !ocultarConfirmar;
                      });
                    },
                    icon: Icon(
                      ocultarConfirmar
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFF7D8797),
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              buildLabel('Tarjeta informativa'),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF5FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.favorite_outline,
                      color: Color(0xFF5B8DEF),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '¿Tienes alguna condición médica?',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2F3A4A),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Esto nos ayuda a personalizar\nrecomendaciones para ti',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF6E7A8C),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Agregar',
                        style: TextStyle(
                          color: Color(0xFF5B8DEF),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              buildLabel('Checkbox terminos'),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: aceptarTerminos,
                    activeColor: const Color(0xFF5B8DEF),
                    onChanged: (value) {
                      setState(() {
                        aceptarTerminos = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF5E6A7D),
                          ),
                          children: [
                            TextSpan(text: 'Acepto los '),
                            TextSpan(
                              text: 'Términos y Condiciones',
                              style: TextStyle(
                                color: Color(0xFF2D65D8),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(text: '\n y la '),
                            TextSpan(
                              text: 'Política de Privacidad.',
                              style: TextStyle(
                                color: Color(0xFF2D65D8),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D65D8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Crear cuenta  →',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                      children: [
                        TextSpan(text: '¿Ya tienes cuenta? '),
                        TextSpan(
                          text: 'Iniciar Sesión',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}import 'package:flutter/material.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController fechaController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();
  final TextEditingController confirmarController = TextEditingController();

  bool aceptarTerminos = false;
  bool ocultarContrasena = true;
  bool ocultarConfirmar = true;

  @override
  void dispose() {
    nombreController.dispose();
    correoController.dispose();
    fechaController.dispose();
    telefonoController.dispose();
    contrasenaController.dispose();
    confirmarController.dispose();
    super.dispose();
  }

  InputDecoration customInput({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF5B8DEF), size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFD8E2F1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF5B8DEF), width: 1.5),
      ),
    );
  }

  Widget buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF2F3A4A),
        ),
      ),
    );
  }

  Future<void> seleccionarFecha() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2005),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        fechaController.text =
        "${pickedDate.day.toString().padLeft(2, '0')} / "
            "${pickedDate.month.toString().padLeft(2, '0')} / "
            "${pickedDate.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF5F7FB),
        title: const Text(
          'Registro',
          style: TextStyle(
            color: Color(0xFFB0B7C3),
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: 55,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'GlucoSmart',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2D65D8),
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Monitorea tu salud y controla tu glucosa',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF9AA5B5),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF1FF),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Text(
                        'Crear cuenta',
                        style: TextStyle(
                          color: Color(0xFF5B8DEF),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Center(
                child: Text(
                  'Completa tus datos',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F3B74),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Registrarte para comenzar a cuidar tu\nsalud y llevar un mejor control',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF5E6A7D),
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              buildLabel('Nombre completo'),
              TextField(
                controller: nombreController,
                decoration: customInput(
                  hint: 'Ejemplo: Luis Marroquín Cardenas',
                  icon: Icons.person_outline,
                ),
              ),
              const SizedBox(height: 16),

              buildLabel('Correo electronico'),
              TextField(
                controller: correoController,
                decoration: customInput(
                  hint: 'ejemplo@correo.com',
                  icon: Icons.mail_outline,
                ),
              ),
              const SizedBox(height: 16),

              buildLabel('Fecha de nacimiento'),
              TextField(
                controller: fechaController,
                readOnly: true,
                onTap: seleccionarFecha,
                decoration: customInput(
                  hint: 'dd / mm / aaaa',
                  icon: Icons.calendar_month_outlined,
                  suffixIcon: IconButton(
                    onPressed: seleccionarFecha,
                    icon: const Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: Color(0xFF7D8797),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              buildLabel('Telefono (opcional)'),
              TextField(
                controller: telefonoController,
                keyboardType: TextInputType.phone,
                decoration: customInput(
                  hint: '+502 1234 5678',
                  icon: Icons.phone_outlined,
                ),
              ),
              const SizedBox(height: 16),

              buildLabel('Contraseña'),
              TextField(
                controller: contrasenaController,
                obscureText: ocultarContrasena,
                decoration: customInput(
                  hint: 'Crea una contraseña',
                  icon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        ocultarContrasena = !ocultarContrasena;
                      });
                    },
                    icon: Icon(
                      ocultarContrasena
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFF7D8797),
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              buildLabel('Confirmar contraseña'),
              TextField(
                controller: confirmarController,
                obscureText: ocultarConfirmar,
                decoration: customInput(
                  hint: 'Confirma tu contraseña',
                  icon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        ocultarConfirmar = !ocultarConfirmar;
                      });
                    },
                    icon: Icon(
                      ocultarConfirmar
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFF7D8797),
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              buildLabel('Tarjeta informativa'),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF5FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.favorite_outline,
                      color: Color(0xFF5B8DEF),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '¿Tienes alguna condición médica?',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2F3A4A),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Esto nos ayuda a personalizar\nrecomendaciones para ti',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF6E7A8C),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Agregar',
                        style: TextStyle(
                          color: Color(0xFF5B8DEF),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              buildLabel('Checkbox terminos'),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: aceptarTerminos,
                    activeColor: const Color(0xFF5B8DEF),
                    onChanged: (value) {
                      setState(() {
                        aceptarTerminos = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF5E6A7D),
                          ),
                          children: [
                            TextSpan(text: 'Acepto los '),
                            TextSpan(
                              text: 'Términos y Condiciones',
                              style: TextStyle(
                                color: Color(0xFF2D65D8),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(text: '\n y la '),
                            TextSpan(
                              text: 'Política de Privacidad.',
                              style: TextStyle(
                                color: Color(0xFF2D65D8),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D65D8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Crear cuenta  →',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                      children: [
                        TextSpan(text: '¿Ya tienes cuenta? '),
                        TextSpan(
                          text: 'Iniciar Sesión',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}
