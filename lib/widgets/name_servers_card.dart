import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';

class NameServersCard extends StatelessWidget {
  const NameServersCard({
    super.key,
    required this.nameServers,
  });

  final List<String> nameServers;

  Future<void> _copy(BuildContext context, String nameServer) async {
    await Clipboard.setData(ClipboardData(text: nameServer));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.l10n.text(
            'nameServerCopied',
            values: {'nameServer': nameServer},
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.text('assignedNameServers'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            for (final nameServer in nameServers)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.dns_outlined),
                title: SelectableText(nameServer),
                trailing: IconButton(
                  key: ValueKey('copyNameServer-$nameServer'),
                  tooltip: context.l10n.text('copy'),
                  onPressed: () => _copy(context, nameServer),
                  icon: const Icon(Icons.copy),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
