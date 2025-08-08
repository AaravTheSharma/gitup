import 'package:flutter/material.dart';
import '../shared/glass_card_widget.dart';
import '../shared/app_colors.dart';
import '../shared/app_text_styles.dart';
import 'photo_editor_controller.dart';
import 'dart:io';

class PhotoEditorScreen extends StatefulWidget {
  const PhotoEditorScreen({Key? key}) : super(key: key);

  @override
  State<PhotoEditorScreen> createState() => _PhotoEditorScreenState();
}

class _PhotoEditorScreenState extends State<PhotoEditorScreen> {
  final PhotoEditorController _controller = PhotoEditorController();
  final GlobalKey _imageKey = GlobalKey();
  File? _selectedImage;
  List<StickerItem> _stickers = [];
  bool _isEditing = false;
  double _currentScale = 1.0;
  double _baseScale = 1.0;

  @override
  void initState() {
    super.initState();
    _initializePhotoEditor();
  }

  Future<void> _initializePhotoEditor() async {
    // Initialize photo editor
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.brandDark,
        title: Text('Select Image Source', style: AppTextStyles.headingMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: AppColors.brandTeal,
              ),
              title: Text('Gallery', style: AppTextStyles.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.brandTeal),
              title: Text('Camera', style: AppTextStyles.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    final image = await _controller.pickImageFromGallery();
    if (image != null) {
      setState(() {
        _selectedImage = image;
        _stickers = [];
        _isEditing = true;
        _currentScale = 1.0;
        _baseScale = 1.0;
      });
    }
  }

  Future<void> _takePhoto() async {
    final image = await _controller.takePhoto();
    if (image != null) {
      setState(() {
        _selectedImage = image;
        _stickers = [];
        _isEditing = true;
        _currentScale = 1.0;
        _baseScale = 1.0;
      });
    }
  }

  void _addSticker(String emoji) {
    if (_selectedImage == null) return;

    setState(() {
      _stickers.add(
        StickerItem(
          emoji: emoji,
          position: const Offset(150, 150),
          scale: 1.0,
          rotation: 0.0,
        ),
      );
    });
  }

  Future<void> _saveImage() async {
    if (_selectedImage == null) return;

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.brandDark,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.brandTeal,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Saving...', style: AppTextStyles.bodyMedium),
                ],
              ),
            ),
          ),
        ),
      );

      // Ensure UI is fully rendered
      await Future.delayed(const Duration(milliseconds: 800));

      // Force layout and drawing
      WidgetsBinding.instance.endOfFrame.then((_) async {
        if (!mounted) return;

        try {
          // Save image
          final success = await _controller.saveEditedImage(
            _selectedImage!.path,
            _stickers,
            widgetKey: _imageKey,
          );
          // Close loading indicator
          if (mounted) {
            Navigator.of(context).pop();
          }

          // Show result
          if (success && mounted) {
            _showSuccessDialog();
          } else if (mounted) {
            _showSimpleErrorDialog('Save failed, please try again');
          }
        } catch (innerError) {
          // Close loading indicator
          if (mounted) {
            Navigator.of(context).pop();
          }

          if (mounted) {
            _showSimpleErrorDialog('Save failed, please try again');
          }
        }
      });
    } catch (e) {
      // Close loading indicator
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (mounted) {
        _showSimpleErrorDialog('Save failed, please try again');
      }
    }
  }

  // Show simplified error dialog
  void _showSimpleErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.brandDark,
        title: Row(
          children: [
            Icon(Icons.error, color: AppColors.error),
            const SizedBox(width: 10),
            Text('Save Failed', style: AppTextStyles.headingMedium),
          ],
        ),
        content: Text(message, style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: AppColors.brandTeal)),
          ),
        ],
      ),
    );
  }

  // Show success dialog
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.brandDark,
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success),
            const SizedBox(width: 10),
            Text('Save Successful', style: AppTextStyles.headingMedium),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Image saved to gallery successfully.',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: AppColors.brandTeal)),
          ),
        ],
      ),
    );
  }

  // Adjust sticker size
  void _updateStickerScale(int index, double scale) {
    setState(() {
      _stickers[index] = _stickers[index].copyWith(scale: scale);
    });
  }

  // Rotate sticker
  void _updateStickerRotation(int index, double rotation) {
    setState(() {
      _stickers[index] = _stickers[index].copyWith(rotation: rotation);
    });
  }

  // Delete sticker
  void _removeSticker(int index) {
    setState(() {
      _stickers.removeAt(index);
    });
  }

  // Crop image
  Future<void> _cropImage() async {
    if (_selectedImage == null) return;

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.brandDark,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.brandTeal,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Preparing to crop...', style: AppTextStyles.bodyMedium),
                ],
              ),
            ),
          ),
        ),
      );

      // Wait to ensure dialog is displayed
      await Future.delayed(const Duration(milliseconds: 300));

      // Close loading indicator
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Call crop function
      final croppedImage = await _controller.cropImage(_selectedImage!);

      if (croppedImage != null && mounted) {
        setState(() {
          _selectedImage = croppedImage;
          _stickers = []; // Clear stickers as image dimensions have changed
          _currentScale = 1.0;
          _baseScale = 1.0;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image cropped successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Crop failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showStickerPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.brandDark,
      builder: (context) => Container(
        height: 300,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Sticker', style: AppTextStyles.headingMedium),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  childAspectRatio: 1,
                ),
                itemCount: _controller.availableEmojis.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _addSticker(_controller.availableEmojis[index]);
                    },
                    child: Center(
                      child: Text(
                        _controller.availableEmojis[index],
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Photo Editor', style: AppTextStyles.headingLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppColors.brandDark,
                  title: Text('Help', style: AppTextStyles.headingMedium),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '1. Tap empty area to select a photo',
                        style: AppTextStyles.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '2. Tap crop button to crop the image',
                        style: AppTextStyles.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '3. Tap emoji button to add stickers',
                        style: AppTextStyles.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '4. Drag stickers to adjust position',
                        style: AppTextStyles.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '5. Long press stickers to resize and rotate',
                        style: AppTextStyles.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '6. Tap save button to save to gallery',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Got it',
                        style: TextStyle(color: AppColors.brandTeal),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.brandGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _isEditing ? null : _showImageSourceDialog,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _selectedImage == null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate,
                                    size: 64,
                                    color: AppColors.brandTeal,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Tap to select photo',
                                    style: AppTextStyles.bodyLarge,
                                  ),
                                ],
                              ),
                            )
                          : Stack(
                              fit: StackFit.expand,
                              children: [
                                // Wrap the entire editing area with RepaintBoundary
                                RepaintBoundary(
                                  key: _imageKey,
                                  child: Container(
                                    color: Colors.black,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        // Background image
                                        Image.file(
                                          _selectedImage!,
                                          fit: BoxFit.contain,
                                        ),

                                        // Sticker layer - for rendering
                                        for (int i = 0;
                                            i < _stickers.length;
                                            i++)
                                          Positioned(
                                            left: _stickers[i].position.dx,
                                            top: _stickers[i].position.dy,
                                            child: Transform.rotate(
                                              angle: _stickers[i].rotation,
                                              child: Transform.scale(
                                                scale: _stickers[i].scale,
                                                child: Text(
                                                  _stickers[i].emoji,
                                                  style: const TextStyle(
                                                    fontSize: 50,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Interactive layer - not included in RepaintBoundary
                                InteractiveViewer(
                                  minScale: 0.5,
                                  maxScale: 3.0,
                                  onInteractionUpdate: (details) {
                                    setState(() {
                                      _currentScale =
                                          _baseScale * details.scale;
                                    });
                                  },
                                  onInteractionEnd: (details) {
                                    setState(() {
                                      _baseScale = _currentScale;
                                    });
                                  },
                                  child: Container(color: Colors.transparent),
                                ),

                                // Interactive sticker layer - for user operations
                                for (int i = 0; i < _stickers.length; i++)
                                  Positioned(
                                    left: _stickers[i].position.dx,
                                    top: _stickers[i].position.dy,
                                    child: GestureDetector(
                                      // Move sticker
                                      onPanUpdate: (details) {
                                        setState(() {
                                          _stickers[i] = _stickers[i].copyWith(
                                            position: Offset(
                                              _stickers[i].position.dx +
                                                  details.delta.dx,
                                              _stickers[i].position.dy +
                                                  details.delta.dy,
                                            ),
                                          );
                                        });
                                      },
                                      // Long press to show edit menu
                                      onLongPress: () {
                                        showModalBottomSheet(
                                          context: context,
                                          backgroundColor: AppColors.brandDark,
                                          builder: (context) => Container(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  'Edit Sticker',
                                                  style: AppTextStyles
                                                      .headingMedium,
                                                ),
                                                const SizedBox(height: 20),

                                                // Scale slider
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.zoom_out,
                                                      color: Colors.white,
                                                    ),
                                                    Expanded(
                                                      child: Slider(
                                                        value:
                                                            _stickers[i].scale,
                                                        min: 0.5,
                                                        max: 3.0,
                                                        activeColor:
                                                            AppColors.brandTeal,
                                                        onChanged: (value) {
                                                          _updateStickerScale(
                                                            i,
                                                            value,
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                    const Icon(
                                                      Icons.zoom_in,
                                                      color: Colors.white,
                                                    ),
                                                  ],
                                                ),

                                                // Rotation slider
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.rotate_left,
                                                      color: Colors.white,
                                                    ),
                                                    Expanded(
                                                      child: Slider(
                                                        value: (_stickers[i]
                                                                        .rotation /
                                                                    (2 *
                                                                        3.14159) +
                                                                0.5) %
                                                            1,
                                                        activeColor:
                                                            AppColors.brandTeal,
                                                        onChanged: (value) {
                                                          _updateStickerRotation(
                                                            i,
                                                            (value - 0.5) *
                                                                2 *
                                                                3.14159,
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                    const Icon(
                                                      Icons.rotate_right,
                                                      color: Colors.white,
                                                    ),
                                                  ],
                                                ),

                                                const SizedBox(height: 20),

                                                // Delete button
                                                ElevatedButton.icon(
                                                  icon: const Icon(
                                                    Icons.delete,
                                                  ),
                                                  label: const Text(
                                                    'Delete Sticker',
                                                  ),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.red,
                                                  ),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    _removeSticker(i);
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: 60,
                                        height: 60,
                                        color: Colors.transparent,
                                      ),
                                    ),
                                  ),

                                // 移除编辑提示横幅
                              ],
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        label: const Text('Save'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: _selectedImage == null ? null : _saveImage,
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 64,
                      height: 48,
                      child: GlassCard(
                        padding: EdgeInsets.zero,
                        child: IconButton(
                          icon: const Icon(Icons.crop),
                          onPressed: _selectedImage == null ? null : _cropImage,
                          tooltip: 'Crop',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 64,
                      height: 48,
                      child: GlassCard(
                        padding: EdgeInsets.zero,
                        child: IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: _selectedImage == null
                              ? null
                              : () {
                                  setState(() {
                                    _stickers = [];
                                    _currentScale = 1.0;
                                    _baseScale = 1.0;
                                  });
                                },
                          tooltip: 'Reset',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 64,
                      height: 48,
                      child: GlassCard(
                        padding: EdgeInsets.zero,
                        child: IconButton(
                          icon: const Icon(Icons.emoji_emotions_outlined),
                          onPressed: _selectedImage == null
                              ? null
                              : _showStickerPicker,
                          tooltip: 'Add Stickers',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StickerItem {
  final String emoji;
  final Offset position;
  final double scale;
  final double rotation;

  const StickerItem({
    required this.emoji,
    required this.position,
    this.scale = 1.0,
    this.rotation = 0.0,
  });

  StickerItem copyWith({
    String? emoji,
    Offset? position,
    double? scale,
    double? rotation,
  }) {
    return StickerItem(
      emoji: emoji ?? this.emoji,
      position: position ?? this.position,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
    );
  }
}
