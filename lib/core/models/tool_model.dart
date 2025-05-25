enum ToolStatus {
  available('available', 'Available'),
  checkedOut('checked_out', 'Checked Out'),
  inService('in_service', 'In Service'),
  maintenance('maintenance', 'Maintenance'),
  outOfService('out_of_service', 'Out of Service');

  const ToolStatus(this.value, this.displayName);
  final String value;
  final String displayName;

  static ToolStatus fromString(String value) {
    return ToolStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => ToolStatus.available,
    );
  }
}

enum ToolCategory {
  cl415('CL415', 'CL415'),
  rj85('RJ85', 'RJ85'),
  q400('Q400', 'Q400'),
  engine('Engine', 'Engine'),
  cnc('CNC', 'CNC'),
  sheetmetal('Sheetmetal', 'Sheetmetal'),
  general('General', 'General'),
  handTools('hand_tools', 'Hand Tools'),
  powerTools('power_tools', 'Power Tools'),
  measuring('measuring', 'Measuring'),
  safety('safety', 'Safety');

  const ToolCategory(this.value, this.displayName);
  final String value;
  final String displayName;

  static ToolCategory fromString(String value) {
    return ToolCategory.values.firstWhere(
      (category) => category.value == value,
      orElse: () => ToolCategory.general,
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
  final bool isCalibrationRequired;

  ToolCalibration({
    this.lastDate,
    this.nextDate,
    this.certificate,
    this.isCalibrationRequired = false,
  });

  bool get isOverdue {
    if (nextDate == null) return false;
    return DateTime.now().isAfter(nextDate!);
  }

  bool get isDueSoon {
    if (nextDate == null) return false;
    final daysUntilDue = nextDate!.difference(DateTime.now()).inDays;
    return daysUntilDue <= 30 && daysUntilDue > 0;
  }

  factory ToolCalibration.fromJson(Map<String, dynamic> json) {
    return ToolCalibration(
      lastDate: json['last_date'] != null
          ? DateTime.parse(json['last_date'] as String)
          : null,
      nextDate: json['next_date'] != null
          ? DateTime.parse(json['next_date'] as String)
          : null,
      certificate: json['certificate'] as String?,
      isCalibrationRequired: json['is_calibration_required'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'last_date': lastDate?.toIso8601String(),
      'next_date': nextDate?.toIso8601String(),
      'certificate': certificate,
      'is_calibration_required': isCalibrationRequired,
    };
  }
}

class ToolCheckoutHistory {
  final String userId;
  final String userName;
  final DateTime checkoutDate;
  final DateTime? returnDate;
  final String purpose;
  final String? notes;

  ToolCheckoutHistory({
    required this.userId,
    required this.userName,
    required this.checkoutDate,
    this.returnDate,
    required this.purpose,
    this.notes,
  });

  factory ToolCheckoutHistory.fromJson(Map<String, dynamic> json) {
    return ToolCheckoutHistory(
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      checkoutDate: DateTime.parse(json['checkout_date'] as String),
      returnDate: json['return_date'] != null
          ? DateTime.parse(json['return_date'] as String)
          : null,
      purpose: json['purpose'] as String,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_name': userName,
      'checkout_date': checkoutDate.toIso8601String(),
      'return_date': returnDate?.toIso8601String(),
      'purpose': purpose,
      'notes': notes,
    };
  }
}

class ToolModel {
  final String id;
  final String name;
  final String description;
  final ToolCategory category;
  final ToolStatus status;
  final String location;
  final String qrCode;
  final String? serialNumber;
  final ToolSpecifications? specifications;
  final ToolCalibration? calibration;
  final List<ToolCheckoutHistory>? checkoutHistory;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ToolModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.status,
    required this.location,
    required this.qrCode,
    this.serialNumber,
    this.specifications,
    this.calibration,
    this.checkoutHistory,
    required this.createdAt,
    this.updatedAt,
  });

  factory ToolModel.fromJson(Map<String, dynamic> json) {
    return ToolModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: ToolCategory.fromString(json['category'] as String),
      status: ToolStatus.fromString(json['status'] as String),
      location: json['location'] as String,
      qrCode: json['qr_code'] as String,
      serialNumber: json['serial_number'] as String?,
      specifications: json['specifications'] != null
          ? ToolSpecifications.fromJson(json['specifications'] as Map<String, dynamic>)
          : null,
      calibration: json['calibration'] != null
          ? ToolCalibration.fromJson(json['calibration'] as Map<String, dynamic>)
          : null,
      checkoutHistory: json['checkout_history'] != null
          ? (json['checkout_history'] as List)
              .map((item) => ToolCheckoutHistory.fromJson(item as Map<String, dynamic>))
              .toList()
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category.value,
      'status': status.value,
      'location': location,
      'qr_code': qrCode,
      'serial_number': serialNumber,
      'specifications': specifications?.toJson(),
      'calibration': calibration?.toJson(),
      'checkout_history': checkoutHistory?.map((item) => item.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  ToolModel copyWith({
    String? id,
    String? name,
    String? description,
    ToolCategory? category,
    ToolStatus? status,
    String? location,
    String? qrCode,
    String? serialNumber,
    ToolSpecifications? specifications,
    ToolCalibration? calibration,
    List<ToolCheckoutHistory>? checkoutHistory,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ToolModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      location: location ?? this.location,
      qrCode: qrCode ?? this.qrCode,
      serialNumber: serialNumber ?? this.serialNumber,
      specifications: specifications ?? this.specifications,
      calibration: calibration ?? this.calibration,
      checkoutHistory: checkoutHistory ?? this.checkoutHistory,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class PaginationModel {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final bool hasNextPage;
  final bool hasPreviousPage;

  PaginationModel({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
  }) : hasNextPage = currentPage < totalPages,
       hasPreviousPage = currentPage > 1;

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      currentPage: json['current_page'] as int,
      totalPages: json['total_pages'] as int,
      totalItems: json['total_items'] as int,
      itemsPerPage: json['items_per_page'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'total_pages': totalPages,
      'total_items': totalItems,
      'items_per_page': itemsPerPage,
    };
  }
}

class ToolsResponse {
  final List<ToolModel> tools;
  final PaginationModel pagination;

  ToolsResponse({
    required this.tools,
    required this.pagination,
  });

  factory ToolsResponse.fromJson(Map<String, dynamic> json) {
    return ToolsResponse(
      tools: (json['data']['tools'] as List)
          .map((item) => ToolModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      pagination: PaginationModel.fromJson(json['data']['pagination'] as Map<String, dynamic>),
    );
  }
}