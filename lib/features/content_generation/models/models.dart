/// Barrel file for content generation models
///
/// Usage:
/// ```dart
/// import '../models/models.dart';
///
/// // Access classes:
/// ContentGenerationResponse response = ContentGenerationResponse.fromJson(json);
/// QualityMetrics metrics = response.qualityMetrics;
///
/// // Access JSON keys:
/// final id = json[GenerationJsonKeys.id];
/// final content = json[GenerationJsonKeys.content];
/// ```
library;

export 'content_generation_request.dart';
export 'content_generation_response.dart';
export 'content_type.dart';
export 'generation_json_keys.dart';
