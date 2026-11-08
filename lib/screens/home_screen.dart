import 'dart:async';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../utils/strings.dart';
import '../widgets/brand.dart';
import '../widgets/product_card.dart';
import 'product_detail.dart';

enum _Sort { name, priceLow, priceHigh }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  StreamSubscription<List<Product>>? _sub;

  List<Product> _products = [];
  String _query = '';
  String _category = 'All'; // always the English key, translated only for display
  bool _preorderOnly = false;
  _Sort _sort = _Sort.name;

  @override
  void initState() {
    super.initState();
    _sub = ProductService.stream().listen((list) {
      if (mounted) setState(() => _products = list);
    }, onError: (_) {});
  }

  @override
  void dispose() {
    _sub?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  String _norm(String s) => s.trim().toLowerCase();

  bool get _filtersActive =>
      _query.trim().isNotEmpty || _category != 'All' || _preorderOnly;

  void _resetFilters() {
    _searchController.clear();
    setState(() {
      _query = '';
      _category = 'All';
      _preorderOnly = false;
    });
  }

  /// Built from the real products, so a category can never be missing.
  List<String> get _categoryOptions {
    final set = <String>{...ProductService.categories};
    for (final p in _products) {
      if (p.category.trim().isNotEmpty && p.category != 'All') {
        set.add(p.category.trim());
      }
    }
    return ['All', ...set];
  }

  int _countFor(String c) => c == 'All'
      ? _products.length
      : _products.where((p) => _norm(p.category) == _norm(c)).length;

  List<Product> get _visible {
    final words = _norm(_query).isEmpty
        ? <String>[]
        : _norm(_query).split(RegExp(r'\s+'));

    final list = _products.where((p) {
      final matchCat =
          _category == 'All' || _norm(p.category) == _norm(_category);
      final haystack =
          _norm('${p.name} ${p.category} ${p.seller} ${p.description}');
      final matchQuery = words.every(haystack.contains);
      final matchPre = !_preorderOnly || p.preorder;
      return matchCat && matchQuery && matchPre;
    }).toList();

    switch (_sort) {
      case _Sort.priceLow:
        list.sort((a, b) => a.price.compareTo(b.price));
      case _Sort.priceHigh:
        list.sort((a, b) => b.price.compareTo(a.price));
      case _Sort.name:
        list.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    }
    return list;
  }

  void _openProduct(Product p) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            ProductDetailScreen(product: p, allProducts: _products),
      ),
    );
  }

  BoxDecoration get _pill {
  final cs = Theme.of(context).colorScheme;
  return BoxDecoration(
    color: cs.surface,
    borderRadius: BorderRadius.circular(30),
    border: Border.all(width: 1.5, color: cs.onSurface),
  );
}

  Widget _searchBar() {
    return Container(
      height: 52,
      padding:  EdgeInsets.only(left: 16, right: 4),
      decoration: _pill,
      child: Row(
        children: [
           Icon(Icons.search, size: 28),
          Expanded(
            child: TextField(
              controller: _searchController,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              textAlign: TextAlign.center,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: context.tr('Enter keywords to search'),
                hintStyle:
                     TextStyle(color: Colors.grey, letterSpacing: 2.5),
              ),
            ),
          ),
          if (_query.isNotEmpty)
            IconButton(
              icon:  Icon(Icons.close),
              onPressed: () {
                _searchController.clear();
                setState(() => _query = '');
              },
            ),
        ],
      ),
    );
  }

  Widget _controls() {
    final options = _categoryOptions;

    return Row(
      children: [
        PopupMenuButton<_Sort>(
          tooltip: context.tr('Sort'),
          icon: Icon(Icons.sort, size: 30),
          initialValue: _sort,
          onSelected: (s) => setState(() => _sort = s),
          itemBuilder: (_) => [
            PopupMenuItem(
                value: _Sort.name, child: Text(context.tr('Name A-Z'))),
            PopupMenuItem(
                value: _Sort.priceLow,
                child: Text(S.t('Price: low to high'))),
            PopupMenuItem(
                value: _Sort.priceHigh,
                child: Text(S.t('Price: high to low'))),
          ],
        ),
        IconButton(
          tooltip: S.t('Pre-order only'),
          isSelected: _preorderOnly,
          icon: const Icon(Icons.tune, size: 30),
          selectedIcon:
               Icon(Icons.tune, size: 30, color: AppColors.indigo),
          onPressed: () => setState(() => _preorderOnly = !_preorderOnly),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: PopupMenuButton<String>(
            initialValue: _category,
            onSelected: (String picked) => setState(() => _category = picked),
            itemBuilder: (_) => [
              for (final String option in options)
                PopupMenuItem<String>(
                  value: option,
                  child: Text(
                      '${option == 'All' ? context.tr('All') : option}  (${_countFor(option)})'),
                ),
            ],
            child: Container(
              height: 48,
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: _pill,
              child: Row(
                children: [
                  Icon(Icons.chevron_right),
                  Expanded(
                    child: Center(
                      child: Text(
                        _category == 'All'
                            ? context.tr('Categories')
                            : _category,
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                   SizedBox(width: 24),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _visible;

    return SafeArea(
      bottom: false,
      child: ResponsiveCenter(
        child: CustomScrollView(
          slivers: [
             SliverToBoxAdapter(child: BrandBanner()),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: _searchBar(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(8, 0, 16, 12),
                child: _controls(),
              ),
            ),
            if (items.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Text(_products.isEmpty
                          ? context.tr('No products yet')
                          : context
                              .tr('No products match your search or filters')),
                      if (_filtersActive && _products.isNotEmpty)
                        TextButton(
                          onPressed: _resetFilters,
                          child: Text(context.tr('Clear filters')),
                        ),
                    ],
                  ),
                ),
              ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(12, 0, 12, 16),
              sliver: SliverGrid(
                gridDelegate:
                     SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 240,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.74,
                ),
                delegate: SliverChildBuilderDelegate(
                  (_, i) => ProductCard(
                    product: items[i],
                    onTap: () => _openProduct(items[i]),
                  ),
                  childCount: items.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}