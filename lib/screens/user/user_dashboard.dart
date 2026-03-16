import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/content_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';
import '../../widgets/content_card.dart';
import '../../widgets/content_form.dart';
import '../../widgets/note_plus_background.dart';
import '../../widgets/note_plus_fab.dart';
import '../auth/login_screen.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({Key? key}) : super(key: key);

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
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

  void _showAddContentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ContentForm(
          isUserMode: true,
          onSubmit: (title, description, imageUrl) async {
            try {
              final newContent = ContentModel(
                id: '',
                title: title,
                description: description,
                imageUrl: imageUrl,
                createdAt: Timestamp.now(),
              );
              
              await _firestoreService.addContent(newContent);
              
              if (!mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Note added successfully')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            }
          },
          onCancel: () => Navigator.pop(context),
        ),
      ),
    );
  }

  void _editContent(ContentModel content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ContentForm(
          isUserMode: true,
          isEditing: true,
          initialData: content,
          onSubmit: (title, description, imageUrl) async {
            try {
              Map<String, dynamic> updateInfo = {
                "title": title,
                "description": description,
                "imageUrl": imageUrl,
                "createdAt": FieldValue.serverTimestamp(),
              };
              
              await _firestoreService.updateContent(content.id, updateInfo);
              
              if (!mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Note updated successfully')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            }
          },
          onCancel: () => Navigator.pop(context),
        ),
      ),
    );
  }

  void _deleteContent(String id) async {
    try {
      await _firestoreService.deleteContent(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
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
                  hintText: 'Search your notes...',
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
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=32'),
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
                    isAdmin: false, 
                    showActions: true,
                    onEdit: () => _editContent(content),
                    onDelete: () => _deleteContent(content.id),
                  );
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: NotePlusFAB(
        onPressed: _showAddContentSheet,
      ),
    );
  }
}
