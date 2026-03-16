import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/content_model.dart';
import '../utils/constants.dart';

class ContentForm extends StatefulWidget {
  final ContentModel? initialData;
  final Function(String title, String description, String imageUrl) onSubmit;
  final VoidCallback onCancel;
  final bool isEditing;
  final bool isTitleDescOnly;
  final bool isUserMode;

  const ContentForm({
    Key? key,
    this.initialData,
    required this.onSubmit,
    required this.onCancel,
    this.isEditing = false,
    this.isTitleDescOnly = false,
    this.isUserMode = false,
  }) : super(key: key);

  @override
  State<ContentForm> createState() => _ContentFormState();
}

class _ContentFormState extends State<ContentForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageUrlController;

  bool _isSaving = false;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialData?.title ?? '');
    _descriptionController = TextEditingController(text: widget.initialData?.description ?? '');
    _imageUrlController = TextEditingController(text: widget.initialData?.imageUrl ?? '');
  }

  @override
  void didUpdateWidget(covariant ContentForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialData?.id != oldWidget.initialData?.id) {
       _titleController.text = widget.initialData?.title ?? '';
       _descriptionController.text = widget.initialData?.description ?? '';
       _imageUrlController.text = widget.initialData?.imageUrl ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      String finalImageUrl = _imageUrlController.text.trim();

      if (mounted) {
        setState(() {
          _isSaving = false;
          _isSuccess = true;
        });

        // Delay for success animation
        await Future.delayed(const Duration(milliseconds: 800));

        widget.onSubmit(
          _titleController.text.trim(),
          _descriptionController.text.trim(),
          finalImageUrl,
        );

        // Clear fields if adding new content
        if (!widget.isEditing) {
          _titleController.clear();
          _descriptionController.clear();
          _imageUrlController.clear();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: widget.onCancel,
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  widget.isEditing ? 'Edit Note' : 'New Note',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: darkTextColor,
                  ),
                ),
                _isSuccess
                    ? const Icon(Icons.check_circle, color: Colors.green, size: 28)
                    : _isSaving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : GestureDetector(
                            onTap: _submitForm,
                            child: const Text(
                              'SAVE',
                              style: TextStyle(
                                color: accentColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
              ],
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _titleController,
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: darkTextColor,
              ),
              decoration: InputDecoration(
                hintText: 'Title',
                hintStyle: GoogleFonts.outfit(
                  color: lightTextColor.withValues(alpha: 0.5),
                ),
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _imageUrlController,
              enabled: !_isSaving,
              style: GoogleFonts.outfit(
                fontSize: 16,
                color: darkTextColor,
              ),
              decoration: InputDecoration(
                hintText: 'Image URL',
                hintStyle: GoogleFonts.outfit(
                  color: lightTextColor.withValues(alpha: 0.5),
                ),
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                suffixIcon: TextButton(
                  onPressed: () {
                    setState(() {
                      _imageUrlController.text = 'https://images.unsplash.com/photo-1499750310107-5fef28a66643?w=800';
                    });
                  },
                  child: const Text('SAMPLE', style: TextStyle(fontSize: 10, color: accentColor)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              style: GoogleFonts.outfit(
                fontSize: 16,
                color: darkTextColor,
                height: 1.5,
              ),
              decoration: InputDecoration(
                hintText: 'Type something here...',
                hintStyle: GoogleFonts.outfit(
                  color: lightTextColor.withValues(alpha: 0.5),
                ),
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              maxLines: null,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter something';
                }
                return null;
              },
            ),
            const SizedBox(height: 100), // Buffer for keyboard
          ],
        ),
      ),
    );
  }
}
