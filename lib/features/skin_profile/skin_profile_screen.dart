import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';

class SkinProfileScreen extends ConsumerStatefulWidget {
  const SkinProfileScreen({super.key});

  @override
  ConsumerState<SkinProfileScreen> createState() => _SkinProfileScreenState();
}

class _SkinProfileScreenState extends ConsumerState<SkinProfileScreen> {
  String _skinType = '';
  final List<String> _concerns = [];
  String _sensitivity = '';
  String _texture = '';
  final List<String> _allergies = [];

  static const _skinTypes = ['Normal', 'Dry', 'Oily', 'Combination', 'Sensitive'];
  static const _concernOptions = [
    'Acne',
    'Aging',
    'Dark Spots',
    'Redness',
    'Dullness',
    'Pores',
    'Fine Lines',
    'Dryness'
  ];
  static const _sensitivityLevels = ['None', 'Mild', 'Moderate', 'High'];
  static const _textures = ['Light', 'Gel', 'Cream', 'Rich Cream', 'Serum', 'Oil'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Skin Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Skin Type',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _skinTypes.map((type) {
                      final selected = _skinType == type;
                      return ChoiceChip(
                        label: Text(type),
                        selected: selected,
                        onSelected: (_) =>
                            setState(() => _skinType = selected ? '' : type),
                        selectedColor: AppTheme.primaryPink.withOpacity(0.2),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Skin Concerns',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _concernOptions.map((concern) {
                      final selected = _concerns.contains(concern);
                      return FilterChip(
                        label: Text(concern),
                        selected: selected,
                        onSelected: (v) {
                          setState(() {
                            v
                                ? _concerns.add(concern)
                                : _concerns.remove(concern);
                          });
                        },
                        selectedColor: AppTheme.primaryPink.withOpacity(0.2),
                        checkmarkColor: AppTheme.primaryPink,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Sensitivity Level',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: _sensitivityLevels.map((level) {
                      final selected = _sensitivity == level;
                      return ChoiceChip(
                        label: Text(level),
                        selected: selected,
                        onSelected: (_) => setState(
                            () => _sensitivity = selected ? '' : level),
                        selectedColor: AppTheme.primaryPink.withOpacity(0.2),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Preferred Texture',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _textures.map((texture) {
                      final selected = _texture == texture;
                      return ChoiceChip(
                        label: Text(texture),
                        selected: selected,
                        onSelected: (_) =>
                            setState(() => _texture = selected ? '' : texture),
                        selectedColor: AppTheme.primaryPink.withOpacity(0.2),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _skinType.isNotEmpty
                  ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Skin profile saved!'),
                          backgroundColor: AppTheme.successGreen,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Save Profile'),
            ),
          ),
        ],
      ),
    );
  }
}
