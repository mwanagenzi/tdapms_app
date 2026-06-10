class LeaseProperty {
  final int id;
  final String name;

  const LeaseProperty({required this.id, required this.name});

  factory LeaseProperty.fromJson(Map<String, dynamic> json) => LeaseProperty(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: json['name'] as String? ?? '',
      );
}

class LeaseUnit {
  final int id;
  final String unitNumber;
  final LeaseProperty property;

  const LeaseUnit({
    required this.id,
    required this.unitNumber,
    required this.property,
  });

  factory LeaseUnit.fromJson(Map<String, dynamic> json) => LeaseUnit(
        id: (json['id'] as num?)?.toInt() ?? 0,
        unitNumber: json['unit_number'] as String? ?? '',
        property: json['property'] is Map
            ? LeaseProperty.fromJson(
                json['property'] as Map<String, dynamic>)
            : const LeaseProperty(id: 0, name: ''),
      );
}

class ActiveLease {
  final int id;
  final String status;
  final double monthlyRent;
  final String startDate;
  final String? endDate;
  final LeaseUnit unit;

  const ActiveLease({
    required this.id,
    required this.status,
    required this.monthlyRent,
    required this.startDate,
    this.endDate,
    required this.unit,
  });

  factory ActiveLease.fromJson(Map<String, dynamic> json) => ActiveLease(
        id: (json['id'] as num?)?.toInt() ?? 0,
        status: json['status'] as String? ?? '',
        monthlyRent:
            double.tryParse(json['monthly_rent']?.toString() ?? '') ?? 0,
        startDate: json['start_date'] as String? ?? '',
        endDate: json['end_date'] as String?,
        unit: json['unit'] is Map
            ? LeaseUnit.fromJson(json['unit'] as Map<String, dynamic>)
            : const LeaseUnit(
                id: 0,
                unitNumber: '',
                property: LeaseProperty(id: 0, name: ''),
              ),
      );
}

class TenantDetails {
  final int id;
  final String? idNumber;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String status; // active | inactive | blacklisted

  const TenantDetails({
    required this.id,
    this.idNumber,
    this.emergencyContactName,
    this.emergencyContactPhone,
    required this.status,
  });

  factory TenantDetails.fromJson(Map<String, dynamic> json) => TenantDetails(
        id: (json['id'] as num?)?.toInt() ?? 0,
        idNumber: json['id_number'] as String?,
        emergencyContactName: json['emergency_contact_name'] as String?,
        emergencyContactPhone: json['emergency_contact_phone'] as String?,
        status: json['status'] as String? ?? 'active',
      );
}

class TenantProfile {
  final int id;
  final String name;
  final String email; // read-only
  final String? phone;
  final TenantDetails tenant;
  final ActiveLease? activeLease;

  const TenantProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.tenant,
    this.activeLease,
  });

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  factory TenantProfile.fromJson(Map<String, dynamic> json) {
    // Response may be wrapped in {"data": {...}} or returned directly.
    final map = json.containsKey('data') && json['data'] is Map
        ? json['data'] as Map<String, dynamic>
        : json;

    return TenantProfile(
      id: (map['id'] as num?)?.toInt() ?? 0,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String?,
      tenant: map['tenant'] is Map
          ? TenantDetails.fromJson(map['tenant'] as Map<String, dynamic>)
          : const TenantDetails(id: 0, status: 'active'),
      activeLease: map['active_lease'] is Map
          ? ActiveLease.fromJson(map['active_lease'] as Map<String, dynamic>)
          : null,
    );
  }
}
