/// Content Type Enum
/// Represents all available content generation types
enum ContentType {
  blog,
  social,
  email,
  video,
  image,
  product,
  ad;

  String get displayName {
    switch (this) {
      case ContentType.blog:
        return 'Blog Post';
      case ContentType.social:
        return 'Social Media';
      case ContentType.email:
        return 'Email Campaign';
      case ContentType.video:
        return 'Video Script';
      case ContentType.image:
        return 'AI Image';
      case ContentType.product:
        return 'Product Description';
      case ContentType.ad:
        return 'Ad Copy';
    }
  }

  String get icon {
    switch (this) {
      case ContentType.blog:
        return '📄';
      case ContentType.social:
        return '📱';
      case ContentType.email:
        return '📧';
      case ContentType.video:
        return '🎬';
      case ContentType.image:
        return '🎨';
      case ContentType.product:
        return '🛍️';
      case ContentType.ad:
        return '📢';
    }
  }

  String get apiEndpoint {
    switch (this) {
      case ContentType.blog:
        return '/api/v1/generate/blog';
      case ContentType.social:
        return '/api/v1/generate/social';
      case ContentType.email:
        return '/api/v1/generate/email';
      case ContentType.video:
        return '/api/v1/generate/video-script';
      case ContentType.image:
        return '/api/v1/generate/image';
      case ContentType.product:
        return '/api/v1/generate/product';
      case ContentType.ad:
        return '/api/v1/generate/ad';
    }
  }
}
