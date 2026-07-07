import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/admin_repository.dart';
import 'admin_screen.dart';

class PinScreen extends StatefulWidget {
  const PinScreen({super.key});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  final _repo = AdminRepository();
  final _pinController = TextEditingController();
  final _confirmController = TextEditingController();
  
  bool _isLoading = true;
  bool _isFirstTime = false;
  String? _savedHash;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkPinStatus();
  }

  Future<void> _checkPinStatus() async {
    final hash = await _repo.getAdminPinHash();
    if (mounted) {
      setState(() {
        _savedHash = hash;
        _isFirstTime = hash == null;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() async {
    setState(() => _errorMessage = null);
    
    final pin = _pinController.text;
    if (pin.isEmpty) {
      setState(() => _errorMessage = 'El PIN no puede estar vacío');
      return;
    }

    if (_isFirstTime) {
      final confirm = _confirmController.text;
      if (pin != confirm) {
        setState(() {
          _errorMessage = 'Los PINs no coinciden';
          _pinController.clear();
          _confirmController.clear();
        });
        return;
      }
      
      // Setup new PIN
      final newHash = _repo.hashPin(pin);
      await _repo.setAdminPinHash(newHash);
      _goToAdmin();
    } else {
      // Validate existing PIN
      final inputHash = _repo.hashPin(pin);
      if (inputHash == _savedHash) {
        _goToAdmin();
      } else {
        setState(() {
          _errorMessage = 'PIN incorrecto. Inténtalo de nuevo.';
          _pinController.clear();
        });
      }
    }
  }

  void _goToAdmin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AdminScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isFirstTime ? 'Crear PIN de Acceso' : 'Ingresar PIN'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 64, color: Colors.blueGrey),
            const SizedBox(height: 24),
            Text(
              _isFirstTime 
                ? 'Protege el acceso a la administración creando un PIN numérico.'
                : 'Ingresa tu PIN para acceder al panel de administración.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _pinController,
              decoration: const InputDecoration(
                labelText: 'PIN',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.password),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              obscureText: true,
              maxLength: 6,
              onSubmitted: (_) => _isFirstTime ? null : _submit(),
              autofocus: true,
            ),
            if (_isFirstTime) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _confirmController,
                decoration: const InputDecoration(
                  labelText: 'Confirmar PIN',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.password),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                obscureText: true,
                maxLength: 6,
                onSubmitted: (_) => _submit(),
              ),
            ],
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submit,
                child: Text(_isFirstTime ? 'Guardar y Entrar' : 'Entrar'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
