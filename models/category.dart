import 'package:equatable/equatable.dart';

class Category extends Equatable {
  const Category({
    required this.id,
    required this.name,
    required this.iconUrl,
    required this.slug,
    this.itemCount = 0,
  });

  final String id;
  final String name;
  final String iconUrl;
  final String slug;
  final int itemCount;

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      iconUrl: json['icon_url'] as String? ?? '',
      slug: json['slug'] as String,
      itemCount: (json['item_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon_url': iconUrl,
        'slug': slug,
        'item_count': itemCount,
      };

  Category copyWith({
    String? id,
    String? name,
    String? iconUrl,
    String? slug,
    int? itemCount,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      iconUrl: iconUrl ?? this.iconUrl,
      slug: slug ?? this.slug,
      itemCount: itemCount ?? this.itemCount,
    );
  }

  @override
  List<Object?> get props => [id, name, iconUrl, slug, itemCount];
}
