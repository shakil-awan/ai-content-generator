import 'package:flutter/foundation.dart';

/// Structured dev-only test data for the image generation form.
///
/// These seeds let engineers populate the image form with realistic sample
/// prompts instantly so manual typing isn't needed during iterative UI work.

class ImageTestData {
  final String prompt;
  final String style;
  final String aspectRatio;
  final bool enhancePrompt;

  const ImageTestData({
    required this.prompt,
    required this.style,
    required this.aspectRatio,
    this.enhancePrompt = true,
  });
}

class ImageGenerationTestSeeder {
  ImageGenerationTestSeeder({List<ImageTestData>? customSeeds})
    : _seeds = customSeeds ?? _defaultSeeds;

  final List<ImageTestData> _seeds;
  int _cursor = 0;

  /// Returns the very first seed so the UI always boots with known data.
  ImageTestData initialSeed() {
    _cursor = 0;
    return _seeds[_cursor];
  }

  /// Moves forward through the curated samples, wrapping once we reach the end.
  ImageTestData nextSeed() {
    _cursor = (_cursor + 1) % _seeds.length;
    return _seeds[_cursor];
  }

  /// Moves backwards through the curated samples, wrapping to the end if needed.
  ImageTestData previousSeed() {
    _cursor = (_cursor - 1) % _seeds.length;
    if (_cursor < 0) {
      _cursor += _seeds.length;
    }
    return _seeds[_cursor];
  }

  static bool get isEnabled => kDebugMode;
}

const List<ImageTestData> _defaultSeeds = [
  ImageTestData(
    prompt:
        'Modern minimalist office workspace with natural lighting, plants on desk, MacBook, coffee cup, clean aesthetic',
    style: 'realistic',
    aspectRatio: '16:9',
    enhancePrompt: true,
  ),
  ImageTestData(
    prompt:
        'Abstract geometric pattern with vibrant orange and blue gradients, modern tech branding, clean lines',
    style: 'artistic',
    aspectRatio: '1:1',
    enhancePrompt: true,
  ),
  ImageTestData(
    prompt:
        'Cartoon illustration of a friendly robot teaching a coding class, colorful, warm lighting, classroom setting',
    style: 'illustration',
    aspectRatio: '16:9',
    enhancePrompt: true,
  ),
  ImageTestData(
    prompt:
        '3D rendered smartphone floating in space with holographic AI interface, futuristic, purple and cyan colors',
    style: '3d',
    aspectRatio: '9:16',
    enhancePrompt: true,
  ),
  ImageTestData(
    prompt:
        'Professional food photography, artisan coffee latte art, wooden table, morning sunlight, cozy cafe atmosphere',
    style: 'realistic',
    aspectRatio: '1:1',
    enhancePrompt: true,
  ),
  ImageTestData(
    prompt:
        'Watercolor style landscape painting of mountain sunrise, soft pastel colors, dreamy atmosphere',
    style: 'artistic',
    aspectRatio: '16:9',
    enhancePrompt: false,
  ),
  ImageTestData(
    prompt:
        'Cute character mascot for tech startup, friendly robot with heart symbol, flat design, blue and white',
    style: 'illustration',
    aspectRatio: '1:1',
    enhancePrompt: true,
  ),
  ImageTestData(
    prompt:
        '3D isometric view of modern smart home, cross-section showing IoT devices, clean minimalist design',
    style: '3d',
    aspectRatio: '4:3',
    enhancePrompt: true,
  ),
  ImageTestData(
    prompt:
        'Professional headshot backdrop, subtle gradient from navy to light blue, corporate elegant style',
    style: 'realistic',
    aspectRatio: '9:16',
    enhancePrompt: true,
  ),
  ImageTestData(
    prompt:
        'Retro vaporwave aesthetic city skyline at sunset, pink and purple tones, nostalgic 80s vibes',
    style: 'artistic',
    aspectRatio: '16:9',
    enhancePrompt: true,
  ),
];
