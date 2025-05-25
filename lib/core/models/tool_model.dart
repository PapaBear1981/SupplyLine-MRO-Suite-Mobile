class ToolModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final ToolStatus status;
  final String location;
  final String qrCode;
  final ToolSpecifications? specifications;
  final ToolCalibration? calibration;
  final List<CheckoutHistoryItem> checkoutHistory;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? currentCheckoutUserId;
  final DateTime? currentCheckoutDate;
  final DateTime? expectedReturnDate;

  ToolModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.status,
    required this.location,
    required this.qrCode,
    this.specifications,
    this.calibration,
    this.checkoutHistory = const [],
    required this.createdAt,
    this.updatedAt,
    this.currentCheckoutUserId,
    this.currentCheckoutDate,
    this.expectedReturnDate,
  });

  bool get isAvailable => status == ToolStatus.available;
  bool get isCheckedOut => status == ToolStatus.checkedOut;
  bool get isInService => status == ToolStatus.inService;
  bool get isOverdue => 
      isCheckedOut && 
      expectedReturnDate != null && 
      DateTime.now().isAfter(expectedReturnDate!);

  ToolModel copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    ToolStatus? status,
    String? location,
    String? qrCode,
    ToolSpecifications? specifications,
    ToolCalibration? calibration,
    List<CheckoutHistoryItem>? checkoutHistory,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? currentCheckoutUserId,
    DateTime? currentCheckoutDate,
    DateTime? expectedReturnDate,
  }) {
    return ToolModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      location: location ?? this.location,
      qrCode: qrCode ?? this.qrCode,
      specifications: specifications ?? this.specifications,
      calibration: calibration ?? this.calibration,
      checkoutHistory: checkoutHistory ?? this.checkoutHistory,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      currentCheckoutUserId: currentCheckoutUserId ?? this.currentCheckoutUserId,
      currentCheckoutDate: currentCheckoutDate ?? this.currentCheckoutDate,
      expectedReturnDate: expectedReturnDate ?? this.expectedReturnDate,
    );
  }

  factory ToolModel.fromJson(Map<String, dynamic> json) {
    return ToolModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      status: ToolStatus.fromString(json['status'] as String),
      location: json['location'] as String,
      qrCode: json['qr_code'] as String,
      specifications: json['specifications'] != null
          ? ToolSpecifications.fromJson(json['specifications'])
          : null,
      calibration: json['calibration'] != null
          ? ToolCalibration.fromJson(json['calibration'])
          : null,
      checkoutHistory: (json['checkout_history'] as List<dynamic>?)
              ?.map((item) => CheckoutHistoryItem.fromJson(item))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      currentCheckoutUserId: json['current_checkout_user_id'] as String?,
      currentCheckoutDate: json['current_checkout_date'] != null
          ? DateTime.parse(json['current_checkout_date'] as String)
          : null,
      expectedReturnDate: json['expected_return_date'] != null
          ? DateTime.parse(json['expected_return_date'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'status': status.value,
      'location': location,
      'qr_code': qrCode,
      'specifications': specifications?.toJson(),
      'calibration': calibration?.toJson(),
      'checkout_history': checkoutHistory.map((item) => item.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'current_checkout_user_id': currentCheckoutUserId,
      'current_checkout_date': currentCheckoutDate?.toIso8601String(),
      'expected_return_date': expectedReturnDate?.toIso8601String(),
    };
  }
}

enum ToolStatus {
  available('available'),
  checkedOut('checked_out'),
  inService('in_service'),
  damaged('damaged'),
  lost('lost');

  const ToolStatus(this.value);
  final String value;

  static ToolStatus fromString(String value) {
    return ToolStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => ToolStatus.available,
    );
  }
}

class ToolSpecifications {
  final String? range;
  final String? accuracy;
  final String? weight;
  final String? dimensions;
  final Map<String, dynamic>? additionalSpecs;

  ToolSpecifications({
    this.range,
    this.accuracy,
    this.weight,
    this.dimensions,
    this.additionalSpecs,
  });

  factory ToolSpecifications.fromJson(Map<String, dynamic> json) {
    return ToolSpecifications(
      range: json['range'] as String?,
      accuracy: json['accuracy'] as String?,
      weight: json['weight'] as String?,
      dimensions: json['dimensions'] as String?,
      additionalSpecs: json['additional_specs'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'range': range,
      'accuracy': accuracy,
      'weight': weight,
      'dimensions': dimensions,
      'additional_specs': additionalSpecs,
    };
  }
}

class ToolCalibration {
  final DateTime? lastDate;
  final DateTime? nextDate;
  final String? certificate;
  final bool isRequired;

  ToolCalibration({
    this.lastDate,
    this.nextDate,
    this.certificate,
    this.isRequired = false,
  });

  bool get isOverdue => 
      isRequired && 
      nextDate != null && 
      DateTime.now().isAfter(nextDate!);

  factory ToolCalibration.fromJson(Map<String, dynamic> json) {
    return ToolCalibration(
      lastDate: json['last_date'] != null
          ? DateTime.parse(json['last_date'] as String)
          : null,
      nextDate: json['next_date'] != null
          ? DateTime.parse(json['next_date'] as String)
          : null,
      certificate: json['certificate'] as String?,
      isRequired: json['is_required'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'last_date': lastDate?.toIso8601String(),
      'next_date': nextDate?.toIso8601String(),
      'certificate': certificate,
      'is_required': isRequired,
    };
  }
}

class CheckoutHistoryItem {
  final String userId;
  final String userName;
  final DateTime checkoutDate;
  final DateTime? returnDate;
  final String? purpose;
  final String? returnCondition;
  final String? returnNotes;

  CheckoutHistoryItem({
    required this.userId,
    required this.userName,
    required this.checkoutDate,
    this.returnDate,
    this.purpose,
    this.returnCondition,
    this.returnNotes,
  });

  factory CheckoutHistoryItem.fromJson(Map<String, dynamic> json) {
    return CheckoutHistoryItem(
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      checkoutDate: DateTime.parse(json['checkout_date'] as String),
      returnDate: json['return_date'] != null
          ? DateTime.parse(json['return_date'] as String)
          : null,
      purpose: json['purpose'] as String?,
      returnCondition: json['return_condition'] as String?,
      returnNotes: json['return_notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_name': userName,
      'checkout_date': checkoutDate.toIso8601String(),
      'return_date': returnDate?.toIso8601String(),
      'purpose': purpose,
      'return_condition': returnCondition,
      'return_notes': returnNotes,
    };
  }
}
