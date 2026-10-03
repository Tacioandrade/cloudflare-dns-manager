import 'package:flutter/material.dart';

import '../data/api.dart';
import '../l10n/app_localizations.dart';
import '../widgets/name_servers_card.dart';
import 'dns_editor_screen.dart';

class PendingDomainScreen extends StatefulWidget {
  const PendingDomainScreen({
    super.key,
    required this.zone,
  });

  final Map<String, dynamic> zone;

  @override
  State<PendingDomainScreen> createState() => _PendingDomainScreenState();
}

class _PendingDomainScreenState extends State<PendingDomainScreen> {
  late Map<String, dynamic> _zone;
  bool _isChecking = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _zone = Map<String, dynamic>.from(widget.zone);
  }

  Future<void> _checkActivation() async {
    setState(() {
      _isChecking = true;
      _error = null;
    });
    try {
      final zone = await ApiService.checkZoneActivation(_zone['id'].toString());
      if (!mounted) return;
      setState(() => _zone = zone);
      if (_zone['status'] == 'active') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.text('domainActivated'))),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.text('domainStillPending'))),
        );
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nameServers = ((_zone['name_servers'] as List?) ?? const [])
        .map((value) => value.toString())
        .toList();
    final isActive = _zone['status'] == 'active';

    return Scaffold(
      appBar: AppBar(title: Text(_zone['name'].toString())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  isActive ? Icons.check_circle : Icons.pending_outlined,
                  size: 64,
                  color: isActive
                      ? Colors.green
                      : Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  context.l10n.text(
                    isActive ? 'domainActivated' : 'domainPendingTitle',
                  ),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.text(
                    isActive
                        ? 'domainActivatedDescription'
                        : 'domainPendingDescription',
                  ),
                  textAlign: TextAlign.center,
                ),
                if (!isActive) ...[
                  const SizedBox(height: 24),
                  NameServersCard(nameServers: nameServers),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    context.l10n.text(
                      'activationCheckError',
                      values: {'error': _error!},
                    ),
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ],
                const SizedBox(height: 24),
                if (isActive)
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => DnsEditorScreen(
                          zoneId: _zone['id'].toString(),
                          zoneName: _zone['name'].toString(),
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.dns),
                    label: Text(context.l10n.text('manageDnsRecords')),
                  )
                else
                  FilledButton.icon(
                    key: const ValueKey('checkDomainActivation'),
                    onPressed: _isChecking ? null : _checkActivation,
                    icon: _isChecking
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                    label: Text(context.l10n.text('checkDomainActivation')),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
