import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../utils/product_image.dart';
import '../utils/responsive.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product; // null = add, otherwise edit
  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  static const _defaultDesc = 'No description available yet.';
  static const _maxExtra = 2;

  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  late final TextEditingController _name;
  late final TextEditingController _price;
  late final TextEditingController _oldPrice;
  late final TextEditingController _description;
  late final TextEditingController _details;
  late final TextEditingController _period;
  late final TextEditingController _stock;

  late List<String> _categories;
  late String _category;
  late bool _preorder;
  late String _imageUrl;
  late List<String> _extra;

  bool _saving = false;

  bool get _isEdit => widget.product != null;

  String _num(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _name = TextEditingController(text: p?.name ?? '');
    _price = TextEditingController(text: p == null ? '' : _num(p.price));
    _oldPrice = TextEditingController(
        text: p?.oldPrice == null ? '' : _num(p!.oldPrice!));
    _description = TextEditingController(
        text: (p == null || p.description == _defaultDesc) ? '' : p.description);
    _details = TextEditingController(text: p?.details.join('\n') ?? '');
    _period = TextEditingController(text: p?.preorderPeriod ?? '');
    _stock = TextEditingController(text: p?.stock?.toString() ?? '');

    _categories = [...ProductService.categories];
    if (p != null &&
        p.category.isNotEmpty &&
        !_categories.contains(p.category)) {
      _categories.add(p.category);
    }
    _category =
        p != null && p.category.isNotEmpty ? p.category : _categories.first;
    _preorder = p?.preorder ?? false;
    _imageUrl = p?.imageUrl ?? '';
    _extra = [...?p?.images];
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _oldPrice.dispose();
    _description.dispose();
    _details.dispose();
    _period.dispose();
    _stock.dispose();
    super.dispose();
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  // ----------------------------------------------------------------- photos
  Future<String?> _pickAsDataUrl({double max = 600}) async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: max,
        maxHeight: max,
        imageQuality: 75,
      );
      if (picked == null) return null;
      final bytes = await picked.readAsBytes();
      return 'data:image/jpeg;base64,${base64Encode(bytes)}';
    } catch (e) {
      if (mounted) _snack('Could not pick image: $e');
      return null;
    }
  }

  Future<void> _pickMain() async {
    final url = await _pickAsDataUrl();
    if (url == null || !mounted) return;
    setState(() => _imageUrl = url);
  }

  Future<void> _pickExtra() async {
    if (_extra.length >= _maxExtra) return;
    final url = await _pickAsDataUrl(max: 500);
    if (url == null || !mounted) return;
    setState(() => _extra.add(url));
  }

  // ------------------------------------------------------------------- save
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final details = _details.text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final desc = _description.text.trim();
    final old = double.tryParse(_oldPrice.text.trim());

    final product = Product(
      id: widget.product?.id ?? '',
      name: _name.text.trim(),
      price: double.parse(_price.text.trim()),
      oldPrice: old,
      category: _category,
      imageUrl: _imageUrl,
      images: _extra,
      preorder: _preorder,
      preorderPeriod: _preorder ? _period.text.trim() : '',
      stock: _preorder ? null : int.parse(_stock.text.trim()),
      description: desc.isEmpty ? _defaultDesc : desc,
      details: details,
      seller: widget.product?.seller ?? '',
    );

    try {
      if (_isEdit) {
        await ProductService.update(product);
      } else {
        await ProductService.create(product);
      }
      if (!mounted) return;
      Navigator.pop(context, _isEdit ? 'updated' : 'added');
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _snack('Could not save: $e');
    }
  }

  InputDecoration _decoration(String label, {String? helper}) =>
      InputDecoration(
        labelText: label,
        helperText: helper,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      );

  Widget _extraThumb(int i) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 80,
            height: 80,
            child: buildProductImage(_extra[i], height: 80, width: 80),
          ),
        ),
        Positioned(
          top: 2,
          right: 2,
          child: InkWell(
            onTap: () => setState(() => _extra.removeAt(i)),
            child: const CircleAvatar(
              radius: 11,
              backgroundColor: Colors.black54,
              child: Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Product' : 'Add Product'),
        centerTitle: true,
      ),
      body: ResponsiveCenter(
        maxWidth: 600,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Main photo
              Center(
                child: GestureDetector(
                  onTap: _pickMain,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 160,
                      width: 160,
                      color: Colors.grey.shade200,
                      child: _imageUrl.isEmpty
                          ? const Icon(Icons.add_a_photo, size: 40)
                          : buildProductImage(_imageUrl,
                              height: 160, width: 160),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: _pickMain,
                    icon: const Icon(Icons.photo_library),
                    label: Text(
                        _imageUrl.isEmpty ? 'Choose photo' : 'Change photo'),
                  ),
                  if (_imageUrl.isNotEmpty)
                    TextButton.icon(
                      onPressed: () => setState(() => _imageUrl = ''),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Remove'),
                    ),
                ],
              ),

              // Extra photos (the thumbnails on the product page)
              const SizedBox(height: 8),
              const Text('Extra photos (shown as thumbnails)',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var i = 0; i < _extra.length; i++) _extraThumb(i),
                  if (_extra.length < _maxExtra)
                    InkWell(
                      onTap: _pickExtra,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.add_photo_alternate_outlined),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _name,
                maxLength: 60,
                decoration: _decoration('Product name'),
                validator: (v) {
                  final t = v?.trim() ?? '';
                  if (t.length < 2) return 'Enter at least 2 characters';
                  return null;
                },
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: _price,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: _decoration('Price (₱)'),
                validator: (v) {
                  final n = double.tryParse(v?.trim() ?? '');
                  if (n == null || n <= 0) return 'Enter a price above 0';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _oldPrice,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: _decoration('Old price (₱), optional',
                    helper: 'Shown crossed out next to the price'),
                validator: (v) {
                  final t = v?.trim() ?? '';
                  if (t.isEmpty) return null;
                  final old = double.tryParse(t);
                  final price = double.tryParse(_price.text.trim());
                  if (old == null || old <= 0) return 'Enter a valid price';
                  if (price != null && old <= price) {
                    return 'Old price must be higher than the price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: _decoration('Category'),
                items: [
                  for (final c in _categories)
                    DropdownMenuItem(value: c, child: Text(c)),
                ],
                onChanged: (v) => setState(() => _category = v ?? _category),
              ),
              const SizedBox(height: 8),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Pre-order'),
                subtitle: const Text('Pre-orders have no stock limit'),
                value: _preorder,
                onChanged: (v) => setState(() => _preorder = v),
              ),

              if (_preorder) ...[
                const SizedBox(height: 8),
                TextFormField(
                  controller: _period,
                  decoration: _decoration('Pre-order period',
                      helper: 'e.g. 2026/02/20 〜 2026/04/22 (JST)'),
                ),
              ] else ...[
                const SizedBox(height: 8),
                TextFormField(
                  controller: _stock,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: _decoration('Stock',
                      helper: 'How many units you have. 0 = sold out'),
                  validator: (v) {
                    final n = int.tryParse(v?.trim() ?? '');
                    if (n == null) return 'Enter the number in stock';
                    if (n > 99999) return 'That seems too high';
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 16),

              TextFormField(
                controller: _description,
                maxLines: 4,
                maxLength: 500,
                decoration: _decoration('Description'),
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: _details,
                maxLines: 5,
                decoration: _decoration('Product details',
                    helper: 'One detail per line, e.g. Material: PVC, ABS'),
              ),
              const SizedBox(height: 20),

              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(_isEdit ? 'Save changes' : 'Add product'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}