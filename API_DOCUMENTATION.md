# API Documentation

This document describes the API endpoints used by the SupplyLine MRO Suite Mobile application.

## Base Configuration

### Environment URLs

- **Development:** `http://localhost:5000/api/v1`
- **Staging:** `https://staging-api.supplyline-mro.com/api/v1`
- **Production:** `https://api.supplyline-mro.com/api/v1`

### Authentication

All API requests (except login and registration) require authentication using JWT tokens.

**Headers:**
```
Authorization: Bearer <jwt_token>
Content-Type: application/json
```

## Authentication Endpoints

### POST /auth/login

Authenticate user and receive JWT tokens.

**Request:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "user_id",
      "email": "user@example.com",
      "name": "John Doe",
      "role": "technician",
      "department": "maintenance"
    },
    "tokens": {
      "access_token": "jwt_access_token",
      "refresh_token": "jwt_refresh_token",
      "expires_in": 3600
    }
  }
}
```

### POST /auth/logout

Logout user and invalidate tokens.

**Request:**
```json
{
  "refresh_token": "jwt_refresh_token"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

### POST /auth/refresh

Refresh access token using refresh token.

**Request:**
```json
{
  "refresh_token": "jwt_refresh_token"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "access_token": "new_jwt_access_token",
    "expires_in": 3600
  }
}
```

### GET /auth/profile

Get current user profile.

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "user_id",
    "email": "user@example.com",
    "name": "John Doe",
    "role": "technician",
    "department": "maintenance",
    "permissions": ["tool_checkout", "tool_return", "view_reports"]
  }
}
```

## Tools Endpoints

### GET /tools

Get list of tools with pagination and filtering.

**Query Parameters:**
- `page` (int): Page number (default: 1)
- `limit` (int): Items per page (default: 20, max: 100)
- `search` (string): Search term
- `category` (string): Tool category
- `status` (string): Tool status (available, checked_out, maintenance)
- `location` (string): Tool location

**Response:**
```json
{
  "success": true,
  "data": {
    "tools": [
      {
        "id": "tool_id",
        "name": "Torque Wrench",
        "description": "Digital torque wrench 10-100 Nm",
        "category": "hand_tools",
        "status": "available",
        "location": "Tool Crib A",
        "qr_code": "SLMRO_1234567890",
        "last_calibration": "2024-01-15T10:00:00Z",
        "next_calibration": "2024-07-15T10:00:00Z"
      }
    ],
    "pagination": {
      "current_page": 1,
      "total_pages": 5,
      "total_items": 100,
      "items_per_page": 20
    }
  }
}
```

### GET /tools/{id}

Get specific tool details.

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "tool_id",
    "name": "Torque Wrench",
    "description": "Digital torque wrench 10-100 Nm",
    "category": "hand_tools",
    "status": "available",
    "location": "Tool Crib A",
    "qr_code": "SLMRO_1234567890",
    "specifications": {
      "range": "10-100 Nm",
      "accuracy": "±3%",
      "weight": "1.2 kg"
    },
    "calibration": {
      "last_date": "2024-01-15T10:00:00Z",
      "next_date": "2024-07-15T10:00:00Z",
      "certificate": "CAL-2024-001"
    },
    "checkout_history": [
      {
        "user": "John Doe",
        "checkout_date": "2024-01-20T09:00:00Z",
        "return_date": "2024-01-20T17:00:00Z",
        "purpose": "Aircraft maintenance"
      }
    ]
  }
}
```

### POST /tools/checkout

Check out a tool to a user.

**Request:**
```json
{
  "tool_id": "tool_id",
  "purpose": "Aircraft maintenance",
  "expected_return": "2024-01-21T17:00:00Z"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "checkout_id": "checkout_id",
    "tool": {
      "id": "tool_id",
      "name": "Torque Wrench"
    },
    "user": {
      "id": "user_id",
      "name": "John Doe"
    },
    "checkout_date": "2024-01-20T09:00:00Z",
    "expected_return": "2024-01-21T17:00:00Z",
    "purpose": "Aircraft maintenance"
  }
}
```

### POST /tools/return

Return a checked-out tool.

**Request:**
```json
{
  "checkout_id": "checkout_id",
  "condition": "good",
  "notes": "Tool in excellent condition"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "checkout_id": "checkout_id",
    "return_date": "2024-01-20T17:00:00Z",
    "condition": "good",
    "notes": "Tool in excellent condition"
  }
}
```

### GET /tools/search

Search tools by various criteria.

**Query Parameters:**
- `q` (string): Search query
- `category` (string): Tool category
- `location` (string): Tool location
- `status` (string): Tool status

**Response:**
```json
{
  "success": true,
  "data": {
    "results": [
      {
        "id": "tool_id",
        "name": "Torque Wrench",
        "category": "hand_tools",
        "status": "available",
        "location": "Tool Crib A",
        "relevance_score": 0.95
      }
    ],
    "total_results": 15,
    "search_time": 0.05
  }
}
```

## Users Endpoints

### GET /users

Get list of users (admin only).

**Query Parameters:**
- `page` (int): Page number
- `limit` (int): Items per page
- `role` (string): User role
- `department` (string): User department

**Response:**
```json
{
  "success": true,
  "data": {
    "users": [
      {
        "id": "user_id",
        "name": "John Doe",
        "email": "john@example.com",
        "role": "technician",
        "department": "maintenance",
        "active": true,
        "last_login": "2024-01-20T09:00:00Z"
      }
    ],
    "pagination": {
      "current_page": 1,
      "total_pages": 3,
      "total_items": 50,
      "items_per_page": 20
    }
  }
}
```

### POST /users/register

Register a new user (admin only).

**Request:**
```json
{
  "name": "Jane Smith",
  "email": "jane@example.com",
  "password": "password123",
  "role": "technician",
  "department": "maintenance"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "user_id",
    "name": "Jane Smith",
    "email": "jane@example.com",
    "role": "technician",
    "department": "maintenance",
    "active": true
  }
}
```

## Reports Endpoints

### GET /reports/tool-usage

Get tool usage report.

**Query Parameters:**
- `start_date` (string): Start date (ISO 8601)
- `end_date` (string): End date (ISO 8601)
- `tool_id` (string): Specific tool ID
- `user_id` (string): Specific user ID
- `department` (string): Department filter

**Response:**
```json
{
  "success": true,
  "data": {
    "summary": {
      "total_checkouts": 150,
      "total_tools": 25,
      "average_usage_time": "4.5 hours",
      "most_used_tool": "Torque Wrench"
    },
    "usage_data": [
      {
        "tool_id": "tool_id",
        "tool_name": "Torque Wrench",
        "checkout_count": 15,
        "total_usage_hours": 67.5,
        "average_usage_hours": 4.5
      }
    ]
  }
}
```

### GET /reports/user-activity

Get user activity report.

**Query Parameters:**
- `start_date` (string): Start date (ISO 8601)
- `end_date` (string): End date (ISO 8601)
- `user_id` (string): Specific user ID
- `department` (string): Department filter

**Response:**
```json
{
  "success": true,
  "data": {
    "summary": {
      "total_users": 20,
      "active_users": 18,
      "total_checkouts": 150,
      "average_checkouts_per_user": 7.5
    },
    "user_activity": [
      {
        "user_id": "user_id",
        "user_name": "John Doe",
        "department": "maintenance",
        "checkout_count": 12,
        "total_usage_hours": 54,
        "last_activity": "2024-01-20T17:00:00Z"
      }
    ]
  }
}
```

## Error Responses

All endpoints may return error responses in the following format:

```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human readable error message",
    "details": "Additional error details"
  }
}
```

### Common Error Codes

- `UNAUTHORIZED` (401): Invalid or missing authentication
- `FORBIDDEN` (403): Insufficient permissions
- `NOT_FOUND` (404): Resource not found
- `VALIDATION_ERROR` (422): Invalid request data
- `INTERNAL_ERROR` (500): Server error

## Rate Limiting

API requests are rate limited to prevent abuse:

- **Authenticated users:** 1000 requests per hour
- **Unauthenticated requests:** 100 requests per hour

Rate limit headers are included in responses:
```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1640995200
```

## Pagination

List endpoints support pagination with the following parameters:

- `page`: Page number (1-based)
- `limit`: Items per page (max 100)

Pagination info is included in the response:
```json
{
  "pagination": {
    "current_page": 1,
    "total_pages": 5,
    "total_items": 100,
    "items_per_page": 20,
    "has_next": true,
    "has_previous": false
  }
}
```
