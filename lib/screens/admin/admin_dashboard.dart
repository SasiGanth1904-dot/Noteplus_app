import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/content_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';
import '../../widgets/content_card.dart';
import '../../widgets/content_form.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/note_plus_background.dart';
import '../../widgets/note_plus_fab.dart';
import '../auth/login_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  
  ContentModel? _editingContent;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _logout() async {
    await _authService.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _handleAddOrUpdate(String title, String description, String imageUrl) async {
    try {
      if (_editingContent != null) {
        // Update existing
        await _firestoreService.updateContent(_editingContent!.id, {
          'title': title,
          'description': description,
          'imageUrl': imageUrl,
          'createdAt': FieldValue.serverTimestamp(),
        });
        setState(() {
          _editingContent = null; // Clear edit mode
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Content updated successfully!')),
        );
      } else {
        // Add new
        final newContent = ContentModel(
          id: '', // Firestore generates this
          title: title,
          description: description,
          imageUrl: imageUrl,
          createdAt: Timestamp.now(),
        );
        await _firestoreService.addContent(newContent);
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Content added successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _handleDelete(ContentModel content) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete Content',
      content: 'Are you sure you want to delete "${content.title}"?',
    );

    if (confirmed == true) {
      try {
        await _firestoreService.deleteContent(content.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Content deleted successfully!')),
        );
        if (_editingContent?.id == content.id) {
          setState(() {
            _editingContent = null;
          });
        }
      } catch (e) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting: ${e.toString()}')),
        );
      }
    }
  }

  void _showAddContentSheet(BuildContext context, {ContentModel? content}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: ContentForm(
              initialData: content ?? _editingContent,
              isEditing: content != null || _editingContent != null,
              onSubmit: (title, description, imageUrl) {
                _handleAddOrUpdate(title, description, imageUrl);
                Navigator.pop(context);
              },
              onCancel: () {
                setState(() {
                  _editingContent = null;
                });
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
    ).whenComplete(() {
      setState(() {
        _editingContent = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: GoogleFonts.outfit(color: darkTextColor, fontSize: 18),
                decoration: InputDecoration(
                  hintText: 'Search notes...',
                  hintStyle: GoogleFonts.outfit(color: darkTextColor.withValues(alpha: 0.5)),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.trim().toLowerCase();
                  });
                },
              )
            : RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Note',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: darkTextColor,
                      ),
                    ),
                    TextSpan(
                      text: 'Plus',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: _isSearching
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    _searchQuery = '';
                    _searchController.clear();
                  });
                },
              )
            : const Icon(Icons.sort, color: Colors.white),
        actions: [
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () => setState(() => _isSearching = true),
            ),
          if (_isSearching && _searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.white),
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _searchController.clear();
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
            ),
          ),
        ],
      ),
      body: NotePlusBackground(
        child: StreamBuilder<List<ContentModel>>(
          stream: _firestoreService.getContentStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading content\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            var items = snapshot.data ?? [];

            // Apply search filter
            if (_searchQuery.isNotEmpty) {
              items = items.where((item) {
                return item.title.toLowerCase().contains(_searchQuery) ||
                    item.description.toLowerCase().contains(_searchQuery);
              }).toList();
            }

            if (items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _searchQuery.isEmpty ? Icons.note_alt_outlined : Icons.search_off,
                      size: 60,
                      color: Colors.white70,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _searchQuery.isEmpty ? 'No notes yet.' : 'No notes found.',
                      style: const TextStyle(fontSize: 18, color: Colors.white70),
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final content = items[index];
                  return ContentCard(
                    content: content,
                    isAdmin: true,
                    onEdit: () {
                      setState(() {
                        _editingContent = content;
                      });
                      _showAddContentSheet(context, content: content);
                    },
                    onDelete: () => _handleDelete(content),
                  );
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: NotePlusFAB(
        onPressed: () => _showAddContentSheet(context),
      ),
    );
  }
}
