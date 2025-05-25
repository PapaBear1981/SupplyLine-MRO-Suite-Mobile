class CheckoutRequest {
  final String toolId;
  final String userId;
  final DateTime expectedReturnDate;
  final String? purpose;
  final String? notes;

  CheckoutRequest({
    required this.toolId,
    required this.userId,
    required this.expectedReturnDate,
    this.purpose,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'tool_id': toolId,
      'user_id': userId,
      'expected_return_date': expectedReturnDate.toIso8601String(),
      'purpose': purpose,
      'notes': notes,
    };
  }
}

class CheckoutResponse {
  final bool success;
  final String message;
  final CheckoutData? data;

  CheckoutResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory CheckoutResponse.fromJson(Map<String, dynamic> json) {
    return CheckoutResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] != null ? CheckoutData.fromJson(json['data']) : null,
    );
  }
}

class CheckoutData {
  final String checkoutId;
  final String toolId;
  final String userId;
  final DateTime checkoutDate;
  final DateTime expectedReturnDate;
  final String? purpose;
  final String? notes;

  CheckoutData({
    required this.checkoutId,
    required this.toolId,
    required this.userId,
    required this.checkoutDate,
    required this.expectedReturnDate,
    this.purpose,
    this.notes,
  });

  factory CheckoutData.fromJson(Map<String, dynamic> json) {
    return CheckoutData(
      checkoutId: json['checkout_id'] as String,
      toolId: json['tool_id'] as String,
      userId: json['user_id'] as String,
      checkoutDate: DateTime.parse(json['checkout_date'] as String),
      expectedReturnDate: DateTime.parse(json['expected_return_date'] as String),
      purpose: json['purpose'] as String?,
      notes: json['notes'] as String?,
    );
  }
}

class ReturnRequest {
  final String toolId;
  final String checkoutId;
  final ToolCondition condition;
  final String? notes;
  final List<String>? photoUrls;

  ReturnRequest({
    required this.toolId,
    required this.checkoutId,
    required this.condition,
    this.notes,
    this.photoUrls,
  });

  Map<String, dynamic> toJson() {
    return {
      'tool_id': toolId,
      'checkout_id': checkoutId,
      'condition': condition.value,
      'notes': notes,
      'photo_urls': photoUrls,
    };
  }
}

class ReturnResponse {
  final bool success;
  final String message;
  final ReturnData? data;

  ReturnResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ReturnResponse.fromJson(Map<String, dynamic> json) {
    return ReturnResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] != null ? ReturnData.fromJson(json['data']) : null,
    );
  }
}

class ReturnData {
  final String returnId;
  final String toolId;
  final String checkoutId;
  final DateTime returnDate;
  final ToolCondition condition;
  final String? notes;

  ReturnData({
    required this.returnId,
    required this.toolId,
    required this.checkoutId,
    required this.returnDate,
    required this.condition,
    this.notes,
  });

  factory ReturnData.fromJson(Map<String, dynamic> json) {
    return ReturnData(
      returnId: json['return_id'] as String,
      toolId: json['tool_id'] as String,
      checkoutId: json['checkout_id'] as String,
      returnDate: DateTime.parse(json['return_date'] as String),
      condition: ToolCondition.fromString(json['condition'] as String),
      notes: json['notes'] as String?,
    );
  }
}

enum ToolCondition {
  good('good'),
  needsMaintenance('needs_maintenance'),
  damaged('damaged'),
  lost('lost');

  const ToolCondition(this.value);
  final String value;

  static ToolCondition fromString(String value) {
    return ToolCondition.values.firstWhere(
      (condition) => condition.value == value,
      orElse: () => ToolCondition.good,
    );
  }

  String get displayName {
    switch (this) {
      case ToolCondition.good:
        return 'Good Condition';
      case ToolCondition.needsMaintenance:
        return 'Needs Maintenance';
      case ToolCondition.damaged:
        return 'Damaged';
      case ToolCondition.lost:
        return 'Lost/Missing';
    }
  }
}
