import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class JobSearchExpandable extends StatefulWidget {
  @override
  _JobSearchExpandableState createState() => _JobSearchExpandableState();
}

class _JobSearchExpandableState extends State<JobSearchExpandable> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  // Mock search history
  final List<String> _searchHistory = [
    'Flutter Developer',
    'UI Designer',
    'Remote Jobs',
  ];

  void _onSearchTap() {
    setState(() {
      _isSearching = true;
    });
  }

  void _onCancel() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            /// Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: CupertinoSearchTextField(
                  controller: _searchController,
                  onTap: _onSearchTap,
                  onSubmitted: (value) {
                    if (value.isNotEmpty && !_searchHistory.contains(value)) {
                      setState(() {
                        _searchHistory.insert(0, value); // Add to history
                      });
                    }
                  },
                  onSuffixTap: _onCancel,
                  backgroundColor: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  placeholder: 'Search jobs...',
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    color: CupertinoColors.label,
                  ),
                  placeholderStyle: const TextStyle(
                    color: CupertinoColors.placeholderText,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            /// Show Search History
            if (_isSearching)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recent Searches',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ..._searchHistory.map(
                      (item) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(item),
                        trailing: const Icon(CupertinoIcons.time),
                        onTap: () {
                          _searchController.text = item;
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
