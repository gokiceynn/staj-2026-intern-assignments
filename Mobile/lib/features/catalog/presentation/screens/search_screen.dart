import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/catalog_providers.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();

  static const _popularSearches = [
    'iPhone',
    'Kulaklık',
    'Spor ayakkabı',
    'Robot süpürge',
    'Kahve',
    'Parfüm',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search(String term) {
    final trimmed = term.trim();
    if (trimmed.isEmpty) return;
    ref.read(searchHistoryProvider.notifier).add(trimmed);
    context.pushReplacement(
      Uri(path: '/products', queryParameters: {'q': trimmed}).toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(searchHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onSubmitted: _search,
          decoration: InputDecoration(
            hintText: 'Ürün, kategori veya marka ara',
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => _search(_controller.text),
              tooltip: 'Ara',
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (history.isNotEmpty) ...[
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Geçmiş Aramalar',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      ref.read(searchHistoryProvider.notifier).clear(),
                  child: const Text('Temizle'),
                ),
              ],
            ),
            for (final term in history)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.history),
                title: Text(term),
                trailing: IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () =>
                      ref.read(searchHistoryProvider.notifier).remove(term),
                  tooltip: 'Kaldır',
                ),
                onTap: () => _search(term),
              ),
            const SizedBox(height: 16),
          ],
          const Text(
            'Popüler Aramalar',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final term in _popularSearches)
                ActionChip(
                  avatar: const Icon(Icons.trending_up, size: 16),
                  label: Text(term),
                  onPressed: () => _search(term),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
