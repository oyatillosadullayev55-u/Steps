import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/tracking_service.dart';
import '../utils/format.dart';

/// "Bugun" sahifasi: bugungi masofa va boshlash/to'xtatish tugmasi.
class HomePage extends StatelessWidget {
  final TrackingService service;

  const HomePage({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListenableBuilder(
      listenable: service,
      builder: (context, _) => Scaffold(
        appBar: AppBar(title: const Text('Bugun')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: cs.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 36),
                child: Column(
                  children: [
                    Text(
                      DateFormat('dd.MM.yyyy').format(DateTime.now()),
                      style: textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${km(service.today)} km',
                      style: textTheme.displayMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text('${service.today.toStringAsFixed(0)} metr'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: !service.ready
                  ? null
                  : (service.tracking ? service.stop : service.start),
              icon: Icon(service.tracking ? Icons.stop : Icons.directions_walk),
              label: Text(
                  service.tracking ? 'To\'xtatish' : 'Yurishni boshlash'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: service.tracking ? cs.error : null,
              ),
            ),
            if (service.tracking)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Center(child: Text('Masofa hisoblanmoqda...')),
              ),
            if (service.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(service.error!, style: TextStyle(color: cs.error)),
              ),
          ],
        ),
      ),
    );
  }
}