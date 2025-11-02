

class BusinessCard {
  const BusinessCard({
    required this.id,
    required this.name,
    this.title = '',
    this.company = '',
    this.phone = '',
    this.email = '',
    this.website = '',
    this.createdAt,
    this.isDefault = false,
  });

  final String id;
  final String name;
  final String title;
  final String company;
  final String phone;
  final String email;
  final String website;
  final DateTime? createdAt;
  final bool isDefault;

  BusinessCard copyWith({
    String? id,
    String? name,
    String? title,
    String? company,
    String? phone,
    String? email,
    String? website,
    DateTime? createdAt,
    bool? isDefault,
  }) {
    return BusinessCard(
      id: id ?? this.id,
      name: name ?? this.name,
      title: title ?? this.title,
      company: company ?? this.company,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      createdAt: createdAt ?? this.createdAt,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'company': company,
      'phone': phone,
      'email': email,
      'website': website,
      'createdAt': createdAt?.toIso8601String(),
      'isDefault': isDefault,
    };
  }

  factory BusinessCard.fromJson(Map<String, dynamic> json) {
    return BusinessCard(
      id: json['id'] as String,
      name: json['name'] as String,
      title: json['title'] as String? ?? '',
      company: json['company'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      website: json['website'] as String? ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BusinessCard && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'BusinessCard(id: $id, name: $name, company: $company)';
  }
}