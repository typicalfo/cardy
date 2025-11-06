

class BusinessCard {
  const BusinessCard({
    required this.id,
    required this.name,
    this.title = '',
    this.company = '',
    this.phone = '',
    this.email = '',
    this.website = '',
    this.websiteUrl = '',
    this.enableVcardQr = true,
    this.enableLinkQr = true,
    this.enableEmailQr = true,
    this.enablePhoneQr = true,
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
  final String websiteUrl;
  final bool enableVcardQr;
  final bool enableLinkQr;
  final bool enableEmailQr;
  final bool enablePhoneQr;
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
    String? websiteUrl,
    bool? enableVcardQr,
    bool? enableLinkQr,
    bool? enableEmailQr,
    bool? enablePhoneQr,
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
      websiteUrl: websiteUrl ?? this.websiteUrl,
      enableVcardQr: enableVcardQr ?? this.enableVcardQr,
      enableLinkQr: enableLinkQr ?? this.enableLinkQr,
      enableEmailQr: enableEmailQr ?? this.enableEmailQr,
      enablePhoneQr: enablePhoneQr ?? this.enablePhoneQr,
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
      'websiteUrl': websiteUrl,
      'enableVcardQr': enableVcardQr,
      'enableLinkQr': enableLinkQr,
      'enableEmailQr': enableEmailQr,
      'enablePhoneQr': enablePhoneQr,
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
      websiteUrl: json['websiteUrl'] as String? ?? '',
      enableVcardQr: json['enableVcardQr'] as bool? ?? true,
      enableLinkQr: json['enableLinkQr'] as bool? ?? true,
      enableEmailQr: json['enableEmailQr'] as bool? ?? true,
      enablePhoneQr: json['enablePhoneQr'] as bool? ?? true,
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