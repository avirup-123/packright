import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../widgets/common_widgets.dart';

class PackingListScreen extends ConsumerWidget {
  const PackingListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTrip = ref.watch(currentTripProvider);
    final itemsAsync = ref.watch(packingItemsProvider);

    if (currentTrip == null) {
      return const Scaffold(
        body: Center(child: Text('No trip selected')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Packing List'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(currentTripProvider.notifier).state = null;
          },
        ),
      ),
      body: itemsAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return EmptyState(
              message: 'No items in this packing list yet.',
              icon: Icons.backpack,
            );
          }

          final checkedCount = items.where((i) => i.isChecked).length;
          final progress = checkedCount / items.length;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$checkedCount of ${items.length} packed',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          '${(progress * 100).toStringAsFixed(0)}%',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return PackingItemCard(
                      name: item.name,
                      category: item.category,
                      isChecked: item.isChecked,
                      quantity: item.quantity,
                      notes: item.notes,
                      onToggle: () async {
                        final storage = ref.read(storageProvider);
                        final updatedItem =
                            item.copyWith(isChecked: !item.isChecked);
                        await storage.updateItem(updatedItem);
                        ref.invalidate(packingItemsProvider);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading items: $error'),
        ),
      ),
    );
  }
}
