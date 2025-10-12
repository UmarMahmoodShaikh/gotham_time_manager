# Complete Time Manager API Documentation

This document provides a comprehensive overview of all implemented APIs in the Gotham Time Manager system.

## Server Information
- **Base URL**: `http://localhost:4000/api`
- **Authentication**: JWT Bearer Token required for protected endpoints
- **Content-Type**: `application/json`

## 1. Authentication APIs

### Public Endpoints (No Authentication Required)

#### POST /api/sign_up
Register a new user account.

**Request Body:**
```json
{
  "user": {
    "first_name": "John",
    "last_name": "Doe", 
    "email": "john.doe@example.com",
    "password": "password123"
  }
}
```

**Response (201):**
```json
{
  "message": "User created successfully",
  "user": {
    "id": 1,
    "first_name": "John",
    "last_name": "Doe",
    "email": "john.doe@example.com",
    "role_id": 1
  },
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

#### POST /api/sign_in (or /api/login)
Authenticate user and get access token.

**Request Body:**
```json
{
  "email": "john.doe@example.com",
  "password": "password123"
}
```

**Response (200):**
```json
{
  "message": "Login successful",
  "user": {
    "id": 1,
    "first_name": "John",
    "last_name": "Doe",
    "email": "john.doe@example.com",
    "role_id": 1
  },
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

#### DELETE /api/sign_out (or POST /api/logout)
Logout user (requires authentication).

**Headers:**
```
Authorization: Bearer <token>
```

**Response (200):**
```json
{
  "message": "Logout successful"
}
```

## 2. Time Tracking APIs

All time tracking endpoints require authentication.

#### POST /api/time-tracking/clock-in
Clock in with location tracking.

**Request Body:**
```json
{
  "work_location": "WFO",
  "latitude": 40.7128,
  "longitude": -74.0060,
  "notes": "Starting work for the day"
}
```

**Response (201):**
```json
{
  "message": "Clocked in successfully",
  "data": {
    "id": 1,
    "user_id": 1,
    "clock_in": "2024-10-12T09:00:00Z",
    "work_location": "WFO",
    "latitude": 40.7128,
    "longitude": -74.0060,
    "status": "in_progress"
  }
}
```

#### POST /api/time-tracking/clock-out
Clock out and complete time entry.

**Request Body:**
```json
{
  "notes": "Completed work for the day"
}
```

**Response (200):**
```json
{
  "message": "Clocked out successfully",
  "data": {
    "id": 1,
    "user_id": 1,
    "clock_in": "2024-10-12T09:00:00Z",
    "clock_out": "2024-10-12T17:00:00Z",
    "total_hours": 8.0,
    "work_location": "WFO",
    "notes": "Completed work for the day",
    "status": "completed"
  }
}
```

#### GET /api/time-tracking/status
Get current clock-in status.

**Response (200):**
```json
{
  "status": "clocked_in",
  "message": "User is currently clocked in",
  "active_entry": {
    "id": 1,
    "clock_in": "2024-10-12T09:00:00Z",
    "work_location": "WFO",
    "status": "in_progress"
  }
}
```

#### GET /api/time-tracking/entries
Get time entries with optional filtering.

**Query Parameters:**
- `start_date`: YYYY-MM-DD format
- `end_date`: YYYY-MM-DD format
- `page`: Page number (default: 1)
- `limit`: Items per page (default: 20)

**Response (200):**
```json
{
  "data": [
    {
      "id": 1,
      "user_id": 1,
      "clock_in": "2024-10-12T09:00:00Z",
      "clock_out": "2024-10-12T17:00:00Z",
      "total_hours": 8.0,
      "work_location": "WFO",
      "status": "completed"
    }
  ],
  "summary": {
    "total_hours": 40.0,
    "total_entries": 5
  }
}
```

#### POST /api/time-tracking/manual-entry
Create manual time entry.

**Request Body:**
```json
{
  "clock_in": "2024-10-12T09:00:00Z",
  "clock_out": "2024-10-12T17:00:00Z",
  "work_location": "WFH",
  "justification": "Forgot to clock in/out",
  "notes": "Working from home"
}
```

#### PUT /api/time-tracking/entries/:id
Update time entry (owner or admin only).

#### DELETE /api/time-tracking/entries/:id
Delete time entry (owner or admin only).

## 3. Approval APIs

#### GET /api/approvals/pending
Get pending time entries for approval (managers/admins only).

**Query Parameters:**
- `page`: Page number
- `limit`: Items per page

**Response (200):**
```json
{
  "data": [
    {
      "id": 1,
      "user": {
        "id": 2,
        "name": "Jane Smith",
        "email": "jane@example.com"
      },
      "clock_in": "2024-10-12T09:00:00Z",
      "clock_out": "2024-10-12T17:00:00Z",
      "total_hours": 8.0,
      "status": "pending",
      "is_manual": true
    }
  ],
  "meta": {
    "current_page": 1,
    "total_pages": 3,
    "total_count": 25
  }
}
```

#### POST /api/approvals/:id/approve
Approve time entry.

**Request Body:**
```json
{
  "notes": "Approved - valid overtime"
}
```

#### POST /api/approvals/:id/reject
Reject time entry.

**Request Body:**
```json
{
  "reason": "Insufficient documentation"
}
```

#### POST /api/approvals/bulk-approve
Approve multiple entries at once.

**Request Body:**
```json
{
  "entry_ids": [1, 2, 3],
  "notes": "Bulk approval for week ending 2024-10-12"
}
```

#### GET /api/approvals/history
Get approval history for manager.

## 4. Analytics APIs

#### GET /api/analytics/dashboard
Get comprehensive analytics dashboard.

**Query Parameters:**
- `start_date`: YYYY-MM-DD
- `end_date`: YYYY-MM-DD
- `user_id`: Filter by user (managers/admins only)

**Response (200):**
```json
{
  "data": {
    "total_hours": 160.0,
    "average_daily_hours": 8.0,
    "attendance_rate": 95.5,
    "overtime_hours": 10.0,
    "top_locations": [
      {"location": "WFO", "hours": 120.0, "count": 15},
      {"location": "WFH", "hours": 40.0, "count": 5}
    ],
    "daily_breakdown": [
      {"date": "2024-10-01", "total_hours": 8.0, "entries_count": 1}
    ]
  }
}
```

#### GET /api/analytics/team-performance
Team performance metrics (managers/admins only).

#### GET /api/analytics/attendance-trends
Attendance trends analysis.

#### GET /api/analytics/productivity-insights
Productivity insights and patterns.

## 5. Reports APIs

#### GET /api/reports/timesheet
Generate timesheet report.

**Query Parameters:**
- `start_date`: YYYY-MM-DD
- `end_date`: YYYY-MM-DD
- `user_id`: User to generate report for (managers/admins only)
- `format`: `json`, `csv`, or `pdf`

**Response for CSV:**
- Content-Type: `text/csv`
- Downloads CSV file

#### GET /api/reports/attendance
Generate attendance report (managers/admins only).

#### GET /api/reports/payroll
Generate payroll report (admins only).

#### GET /api/reports/overtime
Generate overtime report (managers/admins only).

## 6. Settings APIs

#### GET /api/settings/profile
Get user profile settings.

**Response (200):**
```json
{
  "data": {
    "user_id": 1,
    "timezone": "UTC",
    "date_format": "YYYY-MM-DD",
    "time_format": "24h",
    "language": "en",
    "theme": "light"
  }
}
```

#### PUT /api/settings/profile
Update profile settings.

#### GET /api/settings/notifications
Get notification preferences.

#### PUT /api/settings/notifications
Update notification preferences.

#### GET /api/settings/work-preferences
Get work preferences.

#### PUT /api/settings/work-preferences
Update work preferences.

#### GET /api/settings/system
Get system settings (admins only).

#### PUT /api/settings/system
Update system settings (admins only).

## 7. Payroll APIs

#### GET /api/payroll/summary
Get payroll summary for user.

**Query Parameters:**
- `start_date`: YYYY-MM-DD
- `end_date`: YYYY-MM-DD
- `user_id`: User ID (managers/admins only)

**Response (200):**
```json
{
  "data": {
    "total_hours": 160.0,
    "regular_hours": 160.0,
    "overtime_hours": 0.0,
    "regular_rate": 25.0,
    "overtime_rate": 37.5,
    "regular_pay": 4000.0,
    "overtime_pay": 0.0,
    "gross_pay": 4000.0,
    "taxes": 1200.0,
    "net_pay": 2800.0
  }
}
```

#### GET /api/payroll/history
Get payroll history with pagination.

#### POST /api/payroll/generate
Generate payroll for all users (admins only).

#### GET /api/payroll/rates
Get pay rates (managers/admins only).

#### PUT /api/payroll/rates/:user_id
Update pay rates for user (admins only).

## 8. User Management APIs

The system also includes comprehensive user management APIs:

#### GET /api/users
List all users (with pagination and filtering).

#### GET /api/users/:id
Get specific user details.

#### POST /api/users
Create new user (admins only).

#### PUT /api/users/:id
Update user information.

#### DELETE /api/users/:id
Delete user (admins only).

#### PUT /api/users/:id/role
Update user role (admins only).

## Error Responses

All endpoints return consistent error responses:

**400 Bad Request:**
```json
{
  "error": "already_clocked_in",
  "message": "User is already clocked in"
}
```

**401 Unauthorized:**
```json
{
  "error": "Unauthorized access"
}
```

**403 Forbidden:**
```json
{
  "error": "Access denied"
}
```

**422 Unprocessable Entity:**
```json
{
  "error": "validation_error",
  "message": "Invalid data provided",
  "errors": {
    "email": ["has already been taken"],
    "password": ["is too short"]
  }
}
```

## Role-Based Access Control

- **Employee (role_id: 1)**: Can manage own time entries, view own reports
- **Manager (role_id: 2)**: Can approve time entries, view team reports
- **Admin (role_id: 3)**: Full system access, user management, payroll

## Authentication

Include JWT token in all protected requests:

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

## Rate Limiting

The API includes CORS support and is ready for frontend integration.

---

**Total Implemented Endpoints**: 39+ endpoints across 8 categories
**Status**: ✅ All APIs implemented and server running on port 4000
**Database**: PostgreSQL with comprehensive schema including time_entries table
**Authentication**: JWT-based with role-based access control
**Features**: Location tracking, manual entries, approval workflows, analytics, reporting, payroll calculations
