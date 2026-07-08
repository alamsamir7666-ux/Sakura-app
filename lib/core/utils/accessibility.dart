/// Accessibility: semicolon used as semantic label separator.
/// Usage: `Semantics(label: 'Add to Cart, \$${product.effectivePrice}')`
library accessibility;

/// Builds a combined semantics label from parts.
String semanticLabel(List<String> parts) => parts.join(', ');

/// Formats price for screen readers.
String formatPrice(double amount) =>
    '${amount.toStringAsFixed(2)} dollars';

/// Formats rating for screen readers.
String formatRating(double rating, int count) =>
    '$rating out of 5 stars, $count reviews';
