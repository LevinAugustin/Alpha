import 'package:flexify/exercises/exercise_image.dart';
import 'package:flexify/exercises/uebung_assets.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

const exerciseMediaBackground = Color(0xFF000000);

class ExerciseStage extends StatelessWidget {
  const ExerciseStage({
    super.key,
    this.catalogId,
    this.variantKey,
    this.variantImage,
    this.fallbackPath,
  });

  final String? catalogId;
  final String? variantKey;
  final String? variantImage;
  final String? fallbackPath;

  @override
  Widget build(BuildContext context) {
    final visual = uebungAssetIndex.visual(
      catalogId: catalogId,
      variantKey: variantKey,
      variantImage: variantImage,
    );
    if (visual.kind == ExerciseVisualKind.none) {
      return ExerciseImage(path: fallbackPath);
    }
    final Widget picture = visual.kind == ExerciseVisualKind.clip
        ? ExerciseClip(
            key: ValueKey(visual.clip),
            asset: visual.clip!,
            poster: visual.still,
            fallbackPath: fallbackPath,
          )
        : _Still(asset: visual.still!, fallbackPath: fallbackPath);
    return Align(
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: AspectRatio(
          aspectRatio: 1,
          child: ColoredBox(color: exerciseMediaBackground, child: picture),
        ),
      ),
    );
  }
}

class ExerciseClip extends StatefulWidget {
  const ExerciseClip({
    super.key,
    required this.asset,
    this.poster,
    this.fallbackPath,
  });

  final String asset;
  final String? poster;
  final String? fallbackPath;

  @override
  State<ExerciseClip> createState() => _ExerciseClipState();
}

class _ExerciseClipState extends State<ExerciseClip> {
  VideoPlayerController? _controller;
  var _ready = false;
  var _failed = false;

  @override
  void initState() {
    super.initState();
    _open();
  }

  Future<void> _open() async {
    final controller = VideoPlayerController.asset(widget.asset);
    _controller = controller;
    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(0);
      await controller.play();
      if (!mounted) return;
      setState(() => _ready = true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _failed = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (_ready &&
        !_failed &&
        controller != null &&
        controller.value.isInitialized) {
      final size = controller.value.size;
      return FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: size.width == 0 ? 1 : size.width,
          height: size.height == 0 ? 1 : size.height,
          child: VideoPlayer(controller),
        ),
      );
    }
    return _poster(widget.poster, widget.fallbackPath);
  }
}

class _Still extends StatelessWidget {
  const _Still({required this.asset, this.fallbackPath});

  final String asset;
  final String? fallbackPath;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      key: const Key('exercise-media-still'),
      fit: BoxFit.contain,
      errorBuilder: (context, error, stack) => _Fallback(path: fallbackPath),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({this.path});

  final String? path;

  @override
  Widget build(BuildContext context) {
    return Center(child: ExerciseImage(path: path));
  }
}

Widget _poster(String? still, String? fallbackPath) {
  if (still == null) return _Fallback(path: fallbackPath);
  return Image.asset(
    still,
    fit: BoxFit.contain,
    errorBuilder: (context, error, stack) => _Fallback(path: fallbackPath),
  );
}

class ExerciseAssetIcon extends StatelessWidget {
  const ExerciseAssetIcon({super.key, required this.asset, required this.size});

  final String asset;
  final double size;

  @override
  Widget build(BuildContext context) {
    final cache = (size * MediaQuery.devicePixelRatioOf(context)).round();
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(
        asset,
        width: size,
        height: size,
        fit: BoxFit.cover,
        cacheWidth: cache,
        cacheHeight: cache,
        errorBuilder: (context, error, stack) =>
            ExerciseImage(path: null, height: size),
      ),
    );
  }
}

Widget? exerciseLeading({
  String? catalogId,
  String? imagePath,
  double size = 48,
  Widget? fallback,
}) {
  final icon = uebungAssetIndex.icon(
    catalogId: catalogId,
    imagePath: imagePath,
  );
  if (icon != null) return ExerciseAssetIcon(asset: icon, size: size);
  return fallback;
}
