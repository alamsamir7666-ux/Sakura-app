import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/address.dart';
import '../../core/api/user_service.dart';
import '../../shared/widgets/common_widgets.dart';

final addressesListProvider = FutureProvider<List<Address>>((ref) {
  return ref.watch(userServiceProvider).getAddresses();
});

class AddressesScreen extends ConsumerStatefulWidget {
  const AddressesScreen({super.key});

  @override
  ConsumerState<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends ConsumerState<AddressesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _phone = TextEditingController();
  final _street = TextEditingController();
  final _city = TextEditingController();
  final _district = TextEditingController();
  final _postalCode = TextEditingController();
  Address? _editingAddress;

  @override
  void dispose() {
    _fullName.dispose();
    _phone.dispose();
    _street.dispose();
    _city.dispose();
    _district.dispose();
    _postalCode.dispose();
    super.dispose();
  }

  void _showAddressForm() {
    if (_editingAddress != null) {
      _fullName.text = _editingAddress!.fullName;
      _phone.text = _editingAddress!.phone;
      _street.text = _editingAddress!.street;
      _city.text = _editingAddress!.city;
      _district.text = _editingAddress!.district;
      _postalCode.text = _editingAddress!.postalCode ?? '';
    } else {
      _fullName.clear();
      _phone.clear();
      _street.clear();
      _city.clear();
      _district.clear();
      _postalCode.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    _editingAddress != null
                        ? 'Edit Address'
                        : 'Add Address',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextFormField(
                    controller: _fullName,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                    validator: (v) => v?.isEmpty == true ? 'Required' : null),
                const SizedBox(height: 12),
                TextFormField(
                    controller: _phone,
                    decoration: const InputDecoration(labelText: 'Phone'),
                    keyboardType: TextInputType.phone,
                    validator: (v) => v?.isEmpty == true ? 'Required' : null),
                const SizedBox(height: 12),
                TextFormField(
                    controller: _street,
                    decoration: const InputDecoration(labelText: 'Street Address'),
                    validator: (v) => v?.isEmpty == true ? 'Required' : null),
                const SizedBox(height: 12),
                TextFormField(
                    controller: _city,
                    decoration: const InputDecoration(labelText: 'City'),
                    validator: (v) => v?.isEmpty == true ? 'Required' : null),
                const SizedBox(height: 12),
                TextFormField(
                    controller: _district,
                    decoration: const InputDecoration(labelText: 'District'),
                    validator: (v) => v?.isEmpty == true ? 'Required' : null),
                const SizedBox(height: 12),
                TextFormField(
                    controller: _postalCode,
                    decoration: const InputDecoration(labelText: 'Postal Code')),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _saveAddress(ctx),
                    child: Text(_editingAddress != null ? 'Update' : 'Save'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).whenComplete(() => setState(() => _editingAddress = null));
  }

  Future<void> _saveAddress(BuildContext ctx) async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'fullName': _fullName.text,
      'phone': _phone.text,
      'street': _street.text,
      'city': _city.text,
      'district': _district.text,
      if (_postalCode.text.isNotEmpty) 'postalCode': _postalCode.text,
    };

    try {
      if (_editingAddress != null) {
        await ref
            .read(userServiceProvider)
            .updateAddress(_editingAddress!.id, data);
      } else {
        await ref.read(userServiceProvider).addAddress(data);
      }
      ref.invalidate(addressesListProvider);
      if (ctx.mounted) Navigator.pop(ctx);
    } catch (e) {
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final addressesAsync = ref.watch(addressesListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Addresses')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddressForm,
        backgroundColor: AppTheme.primaryPink,
        child: const Icon(Icons.add),
      ),
      body: addressesAsync.when(
        data: (addresses) {
          if (addresses.isEmpty) {
            return EmptyState(
              icon: Icons.location_on_outlined,
              title: 'No addresses saved',
              subtitle: 'Add a shipping address for faster checkout',
              actionLabel: 'Add Address',
              onAction: _showAddressForm,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final addr = addresses[index];
              return Card(
                child: ListTile(
                  leading: Icon(
                    addr.isDefault
                        ? Icons.location_on
                        : Icons.location_on_outlined,
                    color: addr.isDefault
                        ? AppTheme.primaryPink
                        : AppTheme.warmGray,
                  ),
                  title: Text(addr.fullName,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                      '${addr.fullAddress}\n${addr.phone}${addr.postalCode != null ? '\n${addr.postalCode}' : ''}'),
                  trailing: PopupMenuButton(
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(
                          value: 'delete', child: Text('Delete')),
                    ],
                    onSelected: (action) {
                      if (action == 'edit') {
                        setState(() => _editingAddress = addr);
                        _showAddressForm();
                      } else if (action == 'delete') {
                        ref
                            .read(userServiceProvider)
                            .deleteAddress(addr.id);
                        ref.invalidate(addressesListProvider);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
