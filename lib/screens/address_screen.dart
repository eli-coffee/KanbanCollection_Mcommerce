import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/responsive.dart';
class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final _controller = TextEditingController();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final a = await AuthService().getAddress();
    if (!mounted) return;
    setState(() {
      _controller.text = a;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final error = await AuthService().updateAddress(_controller.text);
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(error ?? 'Address saved')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Delivery address')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ResponsiveCenter(
              maxWidth: 600,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextField(
                    controller: _controller,
                    maxLines: 4,
                    maxLength: 200,
                    decoration: InputDecoration(
                      labelText: 'Full address',
                      helperText:
                          'House no., street, barangay, city, province, postal code',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Save address'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}