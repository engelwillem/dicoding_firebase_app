import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketlog_app_ewillem/models/catalog_item.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import 'package:video_trimmer/video_trimmer.dart';

class ProductDetailPage extends StatefulWidget {
  final CatalogItem item;
  const ProductDetailPage({super.key, required this.item});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  Future<void> _showMediaSourceSelector() async {
    await [Permission.camera, Permission.storage, Permission.photos, Permission.microphone].request();

    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Pilih Gambar dari Galeri'),
            onTap: () {
              Navigator.of(context).pop();
              _pickMedia(ImageSource.gallery, 'image');
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Ambil Foto Baru'),
            onTap: () {
              Navigator.of(context).pop();
              _pickMedia(ImageSource.camera, 'image');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.video_library),
            title: const Text('Pilih Video dari Galeri'),
            onTap: () {
              Navigator.of(context).pop();
              _pickMedia(ImageSource.gallery, 'video');
            },
          ),
          ListTile(
            leading: const Icon(Icons.videocam),
            title: const Text('Rekam Video Baru'),
            onTap: () {
              Navigator.of(context).pop();
              _pickMedia(ImageSource.camera, 'video');
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickMedia(ImageSource source, String type) async {
    final ImagePicker picker = ImagePicker();
    XFile? media;

    if (type == 'image') {
      media = await picker.pickImage(source: source);
    } else {
      media = await picker.pickVideo(source: source);
    }

    if (media == null) return;

    if (source == ImageSource.camera) {
      await ImageGallerySaverPlus.saveFile(media.path, isReturnPathOfIOS: true);
    }

    if (type == 'image') {
      _cropImage(media.path);
    } else {
      _trimVideo(media.path);
    }
  }

  Future<void> _cropImage(String sourcePath) async {
    final CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: sourcePath,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Gambar',
          toolbarColor: Theme.of(context).colorScheme.primary,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Crop Gambar',
          aspectRatioPickerButtonHidden: true,
        ),
      ],
    );

    if (croppedFile == null) return;

    setState(() {
      widget.item.imagePath = croppedFile.path;
      widget.item.videoPath = null; // Clear video path
      widget.item.save();
    });
  }

  Future<void> _trimVideo(String sourcePath) async {
    final Trimmer trimmer = Trimmer();
    await trimmer.loadVideo(videoFile: File(sourcePath));

    final resultPath = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return TrimmerView(trimmer);
      }),
    );

    if (resultPath != null) {
      setState(() {
        widget.item.videoPath = resultPath;
        widget.item.imagePath = null; // Clear image path
        widget.item.save();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.title),
        actions: [
          IconButton(
            tooltip: 'Edit',
            onPressed: () => context.go('/item/${widget.item.id}/edit', extra: widget.item),
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            tooltip: 'Delete',
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Hapus Item'),
                    content: const Text('Anda yakin ingin menghapus item ini?'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Batal'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      TextButton(
                        child: const Text('Hapus'),
                        onPressed: () {
                          widget.item.delete();
                          context.pop();
                          context.pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.item.imagePath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    File(widget.item.imagePath!),
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                )
              else if (widget.item.videoPath != null)
                _VideoPlayerWidget(videoPath: widget.item.videoPath!)
              else
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Icon(Icons.photo_outlined, size: 50),
                  ),
                ),
              const SizedBox(height: 16),
              Text(widget.item.title, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(widget.item.category, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              Text(widget.item.description, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showMediaSourceSelector,
        label: const Text('Update Media'),
        icon: const Icon(Icons.add_a_photo),
      ),
    );
  }
}

class _VideoPlayerWidget extends StatefulWidget {
  final String videoPath;
  const _VideoPlayerWidget({required this.videoPath});

  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {});
        _controller.setLooping(true);
      });
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _controller.value.isPlaying ? _controller.pause() : _controller.play();
                });
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  VideoPlayer(_controller),
                  if (!_controller.value.isPlaying)
                    Icon(Icons.play_arrow, size: 50, color: Colors.white.withAlpha(178)),
                ],
              ),
            ),
          )
        : Container(
            height: 200,
            width: double.infinity,
            color: Colors.black,
            child: const Center(child: CircularProgressIndicator()),
          );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class TrimmerView extends StatefulWidget {
  final Trimmer _trimmer;
  const TrimmerView(this._trimmer, {super.key});

  @override
  State<TrimmerView> createState() => _TrimmerViewState();
}

class _TrimmerViewState extends State<TrimmerView> {
  double _startValue = 0.0;
  double _endValue = 0.0;
  bool _isPlaying = false;
  bool _progressVisibility = false;

  Future<void> _saveVideo() async {
    setState(() {
      _progressVisibility = true;
    });

    await widget._trimmer.saveTrimmedVideo(
      startValue: _startValue,
      endValue: _endValue,
      onSave: (outputPath) {
        if (outputPath != null) {
          Navigator.of(context).pop(outputPath);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Video Trimmer"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _progressVisibility ? null : _saveVideo,
          )
        ],
      ),
      body: Builder(
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.only(bottom: 30.0),
            color: Colors.black,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Visibility(
                  visible: _progressVisibility,
                  child: const LinearProgressIndicator(
                    backgroundColor: Colors.red,
                  ),
                ),
                Expanded(
                  child: VideoViewer(trimmer: widget._trimmer),
                ),
                Center(
                  child: TrimViewer(
                    trimmer: widget._trimmer,
                    viewerHeight: 50.0,
                    viewerWidth: MediaQuery.of(context).size.width,
                    maxVideoLength: widget._trimmer.videoPlayerController!.value.duration,
                    onChangeStart: (value) => _startValue = value,
                    onChangeEnd: (value) => _endValue = value,
                    onChangePlaybackState: (value) => setState(() => _isPlaying = value),
                  ),
                ),
                TextButton(
                  child: _isPlaying
                      ? const Icon(
                          Icons.pause,
                          size: 80.0,
                          color: Colors.white,
                        )
                      : const Icon(
                          Icons.play_arrow,
                          size: 80.0,
                          color: Colors.white,
                        ),
                  onPressed: () async {
                    bool playbackState = await widget._trimmer.videoPlaybackControl(
                      startValue: _startValue,
                      endValue: _endValue,
                    );
                    setState(() => _isPlaying = playbackState);
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
