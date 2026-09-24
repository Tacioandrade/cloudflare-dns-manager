import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants.dart';
import '../data/api.dart';
import '../data/dns_record_filter.dart';
import '../data/dns_record_validator.dart';
import '../data/local_storage.dart';
import '../l10n/app_localizations.dart';

typedef DnsRecordsLoader = Future<List<dynamic>> Function(String zoneId);
typedef DnsRecordDeleter = Future<void> Function(
  String zoneId,
  String recordId,
);

class DnsEditorScreen extends StatefulWidget {
  final String zoneId;
  final String zoneName;
  final DnsRecordsLoader? recordsLoader;
  final DnsRecordDeleter? recordDeleter;

  const DnsEditorScreen({
    super.key,
    required this.zoneId,
    required this.zoneName,
    this.recordsLoader,
    this.recordDeleter,
  });

  @override
  State<DnsEditorScreen> createState() => _DnsEditorScreenState();
}

class _DnsEditorScreenState extends State<DnsEditorScreen> {
  static const double _footerHeight = 88;
  static const double _footerActionClearance = 88;

  List<dynamic> _records = [];
  bool _isLoading = true;
  String _searchQuery = '';
  bool _isSearching = false;
  bool _isPurgingCache = false;
  bool _isBulkSelectionMode = false;
  bool _isBulkDeleting = false;
  bool _areFiltersVisible = false;
  List<String> _allowedTypes = ['A', 'CNAME'];
  final Set<String> _selectedTypes = {};
  final Set<bool> _selectedProxyStates = {};
  final Set<String> _selectedRecordIds = {};
  final FocusNode _searchFocusNode = FocusNode();

  bool get _hasActiveFilters =>
      _selectedTypes.isNotEmpty || _selectedProxyStates.isNotEmpty;

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadTypesAndRecords();
  }

  Future<void> _loadTypesAndRecords() async {
    final allowedTypes = await LocalStorage.getDnsTypes();
    if (!mounted) return;
    setState(() {
      _allowedTypes = allowedTypes;
      _selectedTypes.removeWhere((type) => !_allowedTypes.contains(type));
    });
    await _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() => _isLoading = true);
    try {
      final records = await (widget.recordsLoader ?? ApiService.listDnsRecords)(
        widget.zoneId,
      );
      if (!mounted) return;
      setState(() {
        _records = records;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(context.l10n.text('error', values: {'error': '$e'}))));
    }
  }

  void _toggleTypeFilter(String type, bool selected) {
    setState(() {
      if (selected) {
        _selectedTypes.add(type);
      } else {
        _selectedTypes.remove(type);
      }
    });
  }

  void _toggleProxyFilter(bool proxyState, bool selected) {
    setState(() {
      if (selected) {
        _selectedProxyStates.add(proxyState);
      } else {
        _selectedProxyStates.remove(proxyState);
      }
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedTypes.clear();
      _selectedProxyStates.clear();
    });
  }

  void _enterBulkSelection([dynamic record]) {
    setState(() {
      _isBulkSelectionMode = true;
      final recordId = record?['id']?.toString();
      if (recordId != null) {
        _selectedRecordIds.add(recordId);
      }
    });
  }

  void _exitBulkSelection() {
    setState(() {
      _isBulkSelectionMode = false;
      _selectedRecordIds.clear();
    });
  }

  void _toggleRecordSelection(dynamic record, bool selected) {
    final recordId = record['id']?.toString();
    if (recordId == null) return;

    setState(() {
      if (selected) {
        _selectedRecordIds.add(recordId);
      } else {
        _selectedRecordIds.remove(recordId);
      }
    });
  }

  Widget _buildFilters() {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.text('filterByType'),
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _allowedTypes.map((type) {
                          return FilterChip(
                            label: Text(type),
                            selected: _selectedTypes.contains(type),
                            selectedColor: AppColors.primary.withOpacity(0.3),
                            checkmarkColor: AppColors.primary,
                            onSelected: (selected) =>
                                _toggleTypeFilter(type, selected),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.text('filterByProxy'),
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          SizedBox(
                            width: 132,
                            child: FilterChip(
                              label: Text(context.l10n.text('proxyEnabled')),
                              selected: _selectedProxyStates.contains(true),
                              selectedColor: AppColors.primary.withOpacity(0.3),
                              checkmarkColor: AppColors.primary,
                              onSelected: (selected) =>
                                  _toggleProxyFilter(true, selected),
                            ),
                          ),
                          SizedBox(
                            width: 132,
                            child: FilterChip(
                              label: Text(context.l10n.text('proxyDisabled')),
                              selected: _selectedProxyStates.contains(false),
                              selectedColor: AppColors.primary.withOpacity(0.3),
                              checkmarkColor: AppColors.primary,
                              onSelected: (selected) =>
                                  _toggleProxyFilter(false, selected),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Visibility(
                    visible: _hasActiveFilters,
                    maintainAnimation: true,
                    maintainSize: true,
                    maintainState: true,
                    child: TextButton(
                      onPressed: _clearFilters,
                      child: Text(context.l10n.text('clearFilters')),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordsBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadRecords,
      child: Builder(
        builder: (context) {
          final filteredRecords = DnsRecordFilter.apply(
            records: _records,
            searchQuery: _searchQuery,
            selectedTypes: _selectedTypes,
            selectedProxyStates: _selectedProxyStates,
          );

          final typeCounts = <String, int>{
            'A': 0,
            'CNAME': 0,
            'TXT': 0,
          };
          for (final record in _records) {
            final type = record['type']?.toString().toUpperCase();
            if (typeCounts.containsKey(type)) {
              typeCounts[type!] = typeCounts[type]! + 1;
            }
          }

          final safeBottom = MediaQuery.viewPaddingOf(context).bottom;
          final footer = SizedBox(
            height: _footerHeight + safeBottom,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                _footerActionClearance,
                16 + safeBottom,
              ),
              child: Center(
                child: Text(
                  context.l10n.text(
                    'dnsRecordCounts',
                    values: {
                      'total': '${_records.length}',
                      'a': '${typeCounts['A']}',
                      'cname': '${typeCounts['CNAME']}',
                      'txt': '${typeCounts['TXT']}',
                    },
                  ),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ),
          );

          if (filteredRecords.isEmpty) {
            return ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 100),
                  child: Center(child: Text(context.l10n.text('noRecords'))),
                ),
                footer,
              ],
            );
          }

          return ListView.builder(
            itemCount: filteredRecords.length + 1,
            itemBuilder: (context, index) {
              if (index == filteredRecords.length) {
                return footer;
              }

              final record = filteredRecords[index];
              final recordId = record['id']?.toString();
              final isSelected =
                  recordId != null && _selectedRecordIds.contains(recordId);
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: isSelected
                    ? Theme.of(context).colorScheme.primaryContainer
                    : null,
                child: ListTile(
                  leading: _isBulkSelectionMode
                      ? Checkbox(
                          key: ValueKey('bulk-select-$recordId'),
                          value: isSelected,
                          onChanged: _isBulkDeleting
                              ? null
                              : (selected) => _toggleRecordSelection(
                                    record,
                                    selected ?? false,
                                  ),
                        )
                      : null,
                  title: Text(
                    '${record['type']} • ${record['name']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(record['content']),
                  trailing: _isBulkSelectionMode
                      ? null
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Tooltip(
                              message: context.l10n.text(
                                record['proxied']
                                    ? 'disableProxy'
                                    : 'enableProxy',
                              ),
                              child: Switch(
                                value: record['proxied'],
                                onChanged: record['proxiable']
                                    ? (val) => _toggleProxy(record, val)
                                    : null,
                                activeThumbColor: AppColors.primary,
                              ),
                            ),
                            IconButton(
                              tooltip: context.l10n.text('copyRecord'),
                              icon: const Icon(Icons.content_copy),
                              onPressed: () => _showRecordDialog(record, true),
                            ),
                            IconButton(
                              tooltip: context.l10n.text('editRecord'),
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showRecordDialog(record),
                            ),
                            IconButton(
                              tooltip: context.l10n.text('deleteRecordAction'),
                              icon: const Icon(
                                Icons.delete,
                                color: AppColors.error,
                              ),
                              onPressed: () => _confirmDeleteRecord(record),
                            ),
                          ],
                        ),
                  onTap: _isBulkSelectionMode && !_isBulkDeleting
                      ? () => _toggleRecordSelection(record, !isSelected)
                      : null,
                  onLongPress: _isBulkDeleting
                      ? null
                      : () => _enterBulkSelection(record),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _confirmDeleteRecord(dynamic record) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.l10n.text('deleteConfirmTitle')),
        content: Text(context.l10n.text(
          'deleteRecord',
          values: {'name': '${record['name']}'},
        )),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.text('cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.text('delete')),
          ),
        ],
      ),
    );
    if (confirm == true) {
      _deleteRecord(record['id']);
    }
  }

  Future<void> _confirmBulkDelete() async {
    final selectedRecords = _records
        .where(
            (record) => _selectedRecordIds.contains(record['id']?.toString()))
        .toList();

    if (selectedRecords.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.text('selectRecordsToDelete'))),
      );
      return;
    }

    final desiredDialogHeight = 60.0 + (selectedRecords.length * 64.0);
    final availableDialogHeight = MediaQuery.sizeOf(context).height * 0.5;
    final maxDialogHeight =
        availableDialogHeight < 400.0 ? availableDialogHeight : 400.0;
    final dialogHeight = desiredDialogHeight < maxDialogHeight
        ? desiredDialogHeight
        : maxDialogHeight;

    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.text('deleteConfirmTitle')),
        content: SizedBox(
          width: 520,
          height: dialogHeight,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.text('bulkDeleteConfirmMessage')),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: selectedRecords.length,
                  separatorBuilder: (_, __) => const Divider(height: 16),
                  itemBuilder: (_, index) {
                    final record = selectedRecords[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${record['type']} • ${record['name']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('${record['content']}'),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.text('no')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              context.l10n.text('yes'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (confirm != true) {
      _exitBulkSelection();
      return;
    }

    await _deleteSelectedRecords(selectedRecords);
  }

  Future<void> _deleteSelectedRecords(List<dynamic> records) async {
    setState(() => _isBulkDeleting = true);
    final errors = <Object>[];

    for (final record in records) {
      try {
        await (widget.recordDeleter ?? ApiService.deleteDnsRecord)(
          widget.zoneId,
          record['id'].toString(),
        );
      } catch (error) {
        errors.add(error);
      }
    }

    if (!mounted) return;
    setState(() {
      _isBulkDeleting = false;
      _isBulkSelectionMode = false;
      _selectedRecordIds.clear();
    });
    await _loadRecords();

    if (mounted && errors.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.text(
            'bulkDeleteError',
            values: {'count': '${errors.length}'},
          )),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _toggleProxy(dynamic record, bool value) async {
    try {
      await ApiService.updateDnsRecord(widget.zoneId, record['id'], {
        'name': record['name'],
        'content': record['content'],
        'type': record['type'],
        'proxied': value,
      });
      _loadRecords();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                context.l10n.text('updateError', values: {'error': '$e'}))));
      }
    }
  }

  Future<void> _deleteRecord(String recordId) async {
    try {
      await (widget.recordDeleter ?? ApiService.deleteDnsRecord)(
        widget.zoneId,
        recordId,
      );
      _loadRecords();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                context.l10n.text('deleteError', values: {'error': '$e'}))));
      }
    }
  }

  Future<void> _confirmPurgeCache() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.l10n.text('purgeConfirmTitle')),
        content: Text(context.l10n.text('purgeConfirmMessage')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.text('cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              context.l10n.text('purge'),
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _isPurgingCache = true);
    try {
      await ApiService.purgeCache(widget.zoneId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.text('cachePurged')),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(context.l10n.text('purgeError', values: {'error': '$e'})),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPurgingCache = false);
      }
    }
  }

  void _showRecordDialog([dynamic record, bool isCopy = false]) {
    String initialName = '';
    if (record != null) {
      String fullName = record['name'];
      if (fullName == widget.zoneName) {
        initialName = '@';
      } else if (fullName.endsWith('.${widget.zoneName}')) {
        initialName =
            fullName.substring(0, fullName.length - widget.zoneName.length - 1);
      } else {
        initialName = fullName;
      }
    }

    final typeController =
        TextEditingController(text: record != null ? record['type'] : 'A');
    final nameController = TextEditingController(text: initialName);
    final contentController =
        TextEditingController(text: record != null ? record['content'] : '');
    bool isProxied = record != null
        ? record['proxied'] == true
        : DnsRecordValidator.isProxiableType(typeController.text);

    Future<void> onSave() async {
      final selectedType = typeController.text.trim().toUpperCase();
      final content = contentController.text.trim();
      final validationError = DnsRecordValidator.validateContent(
        type: selectedType,
        content: content,
      );

      if (validationError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(validationError),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      String finalName = nameController.text.trim();
      if (finalName == '@' || finalName.isEmpty) {
        finalName = widget.zoneName;
      } else if (!finalName.endsWith('.${widget.zoneName}')) {
        finalName = '$finalName.${widget.zoneName}';
      }

      final data = <String, dynamic>{
        'type': selectedType,
        'name': finalName,
        'content': content,
      };
      if (DnsRecordValidator.isProxiableType(selectedType)) {
        data['proxied'] = isProxied;
      }

      if (isCopy &&
          DnsRecordValidator.isDuplicate(
            records: _records,
            type: selectedType,
            name: finalName,
            content: content,
          )) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.text('duplicateRecord')),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      try {
        if (record == null || isCopy) {
          await ApiService.createDnsRecord(widget.zoneId, data);
        } else {
          await ApiService.updateDnsRecord(widget.zoneId, record['id'], data);
        }
        if (mounted) {
          Navigator.pop(context);
        }
        _loadRecords();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text(context.l10n.text('error', values: {'error': '$e'}))));
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return CallbackShortcuts(
              bindings: {
                const SingleActivator(LogicalKeyboardKey.escape): () {
                  Navigator.pop(context);
                },
              },
              child: FocusScope(
                autofocus: true,
                child: AlertDialog(
                  title: Text(isCopy
                      ? context.l10n.text('copyRecord')
                      : record == null
                          ? context.l10n.text('newRecord')
                          : context.l10n.text('editRecord')),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<String>(
                          value: typeController.text,
                          items: (_allowedTypes.contains(typeController.text)
                                  ? _allowedTypes
                                  : [..._allowedTypes, typeController.text])
                              .map((type) {
                            return DropdownMenuItem(
                                value: type, child: Text(type));
                          }).toList(),
                          onChanged: (val) {
                            setStateDialog(() {
                              typeController.text = val!;
                              if (!DnsRecordValidator.isProxiableType(val)) {
                                isProxied = false;
                              } else if (record == null) {
                                isProxied = true;
                              }
                            });
                          },
                          decoration: InputDecoration(
                              labelText: context.l10n.text('type')),
                        ),
                        TextField(
                          controller: nameController,
                          onSubmitted: (_) => onSave(),
                          decoration: InputDecoration(
                            labelText: context.l10n.text('nameSubdomain'),
                            hintText: '@ ou www',
                            suffixText: '.${widget.zoneName}',
                          ),
                        ),
                        TextField(
                            controller: contentController,
                            onSubmitted: (_) => onSave(),
                            decoration: InputDecoration(
                                labelText: context.l10n.text('content'))),
                        if (DnsRecordValidator.isProxiableType(
                            typeController.text))
                          SwitchListTile(
                            title: Text(context.l10n.text('proxied')),
                            value: isProxied,
                            onChanged: (val) =>
                                setStateDialog(() => isProxied = val),
                          ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(context.l10n.text('cancel'))),
                    ElevatedButton(
                      onPressed: onSave,
                      child: Text(context.l10n.text('recordSave')),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyF, control: true): () {
          if (!_isSearching) {
            setState(() {
              _isSearching = true;
            });
          }
          Future.delayed(const Duration(milliseconds: 50), () {
            _searchFocusNode.requestFocus();
          });
        },
        const SingleActivator(LogicalKeyboardKey.keyN, control: true): () {
          if (!_isBulkSelectionMode) {
            _showRecordDialog();
          }
        },
        const SingleActivator(LogicalKeyboardKey.escape): () {
          if (_isBulkSelectionMode && !_isBulkDeleting) {
            _exitBulkSelection();
          } else if (_isSearching) {
            setState(() {
              _isSearching = false;
              _searchQuery = '';
            });
          } else {
            Navigator.pop(context);
          }
        },
      },
      child: FocusScope(
        autofocus: true,
        child: Scaffold(
          appBar: AppBar(
            title: _isSearching
                ? TextField(
                    focusNode: _searchFocusNode,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: context.l10n.text('searchRecord'),
                      border: InputBorder.none,
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                  )
                : Text(widget.zoneName),
            actions: [
              IconButton(
                tooltip: context.l10n.text('dnsFilters'),
                icon: Icon(
                  _areFiltersVisible || _hasActiveFilters
                      ? Icons.filter_alt
                      : Icons.filter_alt_outlined,
                ),
                onPressed: () {
                  setState(() {
                    _areFiltersVisible = !_areFiltersVisible;
                  });
                },
              ),
              IconButton(
                key: const ValueKey('bulk-delete-mode-button'),
                tooltip: context.l10n.text(
                  _isBulkSelectionMode
                      ? 'cancelBulkSelection'
                      : 'selectRecordsToDeleteAction',
                ),
                icon: const Icon(Icons.delete),
                onPressed: _isBulkDeleting
                    ? null
                    : _isBulkSelectionMode
                        ? _exitBulkSelection
                        : _enterBulkSelection,
              ),
              IconButton(
                tooltip: context.l10n.text('purgeCache'),
                icon: _isPurgingCache
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.cleaning_services),
                onPressed: _isPurgingCache ? null : _confirmPurgeCache,
              ),
              IconButton(
                icon: Icon(_isSearching ? Icons.close : Icons.search),
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                    if (!_isSearching) {
                      _searchQuery = '';
                    }
                  });
                },
              ),
              const SizedBox(width: 16),
            ],
          ),
          body: Column(
            children: [
              if (_areFiltersVisible) _buildFilters(),
              Expanded(child: _buildRecordsBody()),
            ],
          ),
          floatingActionButton: _isBulkSelectionMode
              ? FloatingActionButton(
                  key: const ValueKey('bulk-delete-fab'),
                  tooltip: context.l10n.text('deleteSelectedRecords'),
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  onPressed: _isBulkDeleting ? null : _confirmBulkDelete,
                  child: _isBulkDeleting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.delete),
                )
              : FloatingActionButton(
                  key: const ValueKey('add-record-fab'),
                  onPressed: () => _showRecordDialog(),
                  child: const Icon(Icons.add),
                ),
        ),
      ),
    );
  }
}
