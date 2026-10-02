import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/tracking_service.dart';
import '../utils/format.dart';
import '../widgets/stat_tile.dart';

/// "Tarix" sahifasi: har kuni qancha yurilgani va umumiy statistika.
class HistoryPage extends StatelessWidget {
  final TrackingService service;

  const HistoryPage({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final showFmt = DateFormat('dd.MM.yyyy');

    return ListenableBuilder(
      listenable: service,
      builder: (context, _) {
        final keys = service.sortedKeys;

        return Scaffold(
          appBar: AppBar(title: const Text('Kunlik tarix')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: StatTile(
                        title: 'Jami', value: '${km(service.total)} km'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatTile(
                        title: 'O\'rtacha / kun',
                        value: '${km(service.average)} km'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (keys.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: Text('Hozircha ma\'lumot yo\'q.')),
                ),
              for (final k in keys)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(showFmt.format(DateTime.parse(k))),
                          Text(
                            '${km(service.days[k]!)} km',
                            style:
                            const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: service.days[k]! / service.maxDay,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}