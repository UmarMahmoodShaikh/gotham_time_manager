# Gotham Time Manager API Documentation

## Overview
This document provides comprehensive API documentation for the Gotham Time Manager application. The API is built using Phoenix Framework and provides endpoints for user management, authentication, and task management.

**Base URL:** `http://localhost:4000`
**Content Type:** `application/json`

## Table of Contents
1. [Authentication](#authentication)
2. [User Management](#user-management)
3. [Task Management](#task-management)
4. [Error Handling](#error-handling)
5. [CORS Configuration](#cors-configuration)

---

## Authentication

### Login
Authenticate a user with email/username and password.

**Endpoint:** `POST /api/login`

**Request Body:**
```json
{
  "email": "user@example.com",     // Optional (required if username not provided)
  "username": "johndoe",           // Optional (required if email not provided)
  "password": "your_password"      // Required
}
```

**Response (Success - 200):**
```json
{
  "status": "ok",
  "user_id": 1,
  "email": "user@example.com",
  "role": "employee"
}
```

**Response (Error - 401):**
```json
{
  "error": "Invalid credentials"
}
```

**Response (Error - 400):**
```json
{
  "error": "Missing email or username"
}
```

**Frontend Example:**
```javascript
const loginUser = async (emailOrUsername, password) => {
  const loginData = {
    password: password
  };
  
  // Add either email or username
  if (emailOrUsername.includes('@')) {
    loginData.email = emailOrUsername;
  } else {
    loginData.username = emailOrUsername;
  }

  const response = await fetch('http://localhost:4000/api/login', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(loginData)
  });

  return await response.json();
};
```

### Logout
End the current user session.

**Endpoint:** `POST /api/logout`

**Response (Success - 200):**
```json
{
  "message": "Logged out successfully"
}
```

---

## User Management

### List All Users
Get a list of all users in the system.

**Endpoint:** `GET /api/users`

**Response (Success - 200):**
```json
{
  "data": [
    {
      "id": 1,
      "username": "johndoe",
      "email": "john@example.com",
      "role": "employee"
    },
    {
      "id": 2,
      "username": "janesmith",
      "email": "jane@example.com",
      "role": "manager"
    }
  ]
}
```

**Frontend Example:**
```javascript
const fetchUsers = async () => {
  const response = await fetch('http://localhost:4000/api/users', {
    method: 'GET',
    headers: {
      'Content-Type': 'application/json',
    },
    credentials: 'include' // Include cookies for session management
  });

  return await response.json();
};
```

### Get User by ID
Retrieve a specific user by their ID.

**Endpoint:** `GET /api/users/:id`

**Response (Success - 200):**
```json
{
  "data": {
    "id": 1,
    "username": "johndoe",
    "email": "john@example.com",
    "role": "employee"
  }
}
```

**Response (Error - 404):**
```json
{
  "message": "User not found"
}
```

### Create User
Create a new user account.

**Endpoint:** `POST /api/users`

**Request Body:**
```json
{
  "user": {
    "first_name": "John",           // Required
    "last_name": "Doe",             // Optional
    "email": "john@example.com",    // Required
    "username": "johndoe",          // Optional
    "password": "securepassword",   // Required
    "role": "employee"              // Required (employee/manager/admin)
  }
}
```

**Response (Success - 201):**
```json
{
  "data": {
    "id": 1,
    "username": "johndoe",
    "email": "john@example.com",
    "role": "employee"
  }
}
```

**Response (Error - 422):**
```json
{
  "errors": {
    "email": ["can't be blank"],
    "password": ["can't be blank"]
  }
}
```

**Frontend Example:**
```javascript
const createUser = async (userData) => {
  const response = await fetch('http://localhost:4000/api/users', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ user: userData }),
    credentials: 'include'
  });

  return await response.json();
};
```

### Update User
Update an existing user's information.

**Endpoint:** `PUT /api/users/:id`

**Request Body:**
```json
{
  "user": {
    "first_name": "John Updated",
    "last_name": "Doe Updated",
    "email": "john.updated@example.com",
    "username": "johndoe_updated",
    "role": "manager"
  }
}
```

**Response (Success - 200):**
```json
{
  "data": {
    "id": 1,
    "username": "johndoe_updated",
    "email": "john.updated@example.com",
    "role": "manager"
  }
}
```

### Delete User
Delete a user from the system.

**Endpoint:** `DELETE /api/users/:id`

**Response (Success - 204):**
```
User Deleted Successfully
```

**Response (Error - 404):**
```json
{
  "message": "User not found"
}
```

---

## Task Management

### List All Tasks
Get a list of all tasks in the system.

**Endpoint:** `GET /api/tasks`

**Response (Success - 200):**
```json
{
  "data": [
    {
      "id": 1,
      "title": "Complete project documentation",
      "description": "Write comprehensive API documentation",
      "status": 1,
      "status_name": "active",
      "user_ids": [1, 2]
    },
    {
      "id": 2,
      "title": "Review code changes",
      "description": "Review pull request #123",
      "status": 2,
      "status_name": "in_review",
      "user_ids": [1]
    }
  ]
}
```

**Frontend Example:**
```javascript
const fetchTasks = async () => {
  const response = await fetch('http://localhost:4000/api/tasks', {
    method: 'GET',
    headers: {
      'Content-Type': 'application/json',
    },
    credentials: 'include'
  });

  return await response.json();
};
```

### Get Task by ID
Retrieve a specific task by its ID.

**Endpoint:** `GET /api/tasks/:id`

**Response (Success - 200):**
```json
{
  "data": {
    "id": 1,
    "title": "Complete project documentation",
    "description": "Write comprehensive API documentation",
    "status": 1,
    "status_name": "active",
    "user_ids": [1, 2]
  }
}
```

**Response (Error - 404):**
```json
{
  "message": "Task not found"
}
```

### Create Task
Create a new task and optionally assign it to users.

**Endpoint:** `POST /api/tasks`

**Request Body:**
```json
{
  "task": {
    "title": "New Task Title",           // Required
    "description": "Task description",   // Required
    "status": 1,                        // Required (-1: pending, 0: non_active, 1: active, 2: in_review, 3: completed, 5: archived)
    "user_ids": [1, 2]                  // Optional: Array of user IDs to assign
  }
}
```

**Response (Success - 200):**
```json
{
  "data": {
    "id": 3,
    "title": "New Task Title",
    "description": "Task description",
    "status": 1,
    "status_name": "active",
    "user_ids": [1, 2]
  }
}
```

**Response (Error - 404 - User not found):**
```json
{
  "message": "User(s) not found",
  "missing_ids": [999]
}
```

**Response (Error - 400 - Validation error):**
```json
{
  "errors": {
    "title": ["can't be blank"],
    "status": ["is invalid. Allowed values: -1, 0, 1, 2, 3, 5"]
  }
}
```

**Frontend Example:**
```javascript
const createTask = async (taskData) => {
  const response = await fetch('http://localhost:4000/api/tasks', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ task: taskData }),
    credentials: 'include'
  });

  return await response.json();
};

// Example usage
const newTask = {
  title: "Implement user authentication",
  description: "Add JWT-based authentication system",
  status: 1,
  user_ids: [1, 2]
};

createTask(newTask);
```

### Update Task
Update an existing task's information and/or reassign users.

**Endpoint:** `PUT /api/tasks/:id`

**Request Body:**
```json
{
  "task": {
    "title": "Updated Task Title",
    "description": "Updated description",
    "status": 2,
    "user_ids": [1, 3, 4]
  }
}
```

**Response (Success - 200):**
```json
{
  "data": {
    "id": 1,
    "title": "Updated Task Title",
    "description": "Updated description",
    "status": 2,
    "status_name": "in_review",
    "user_ids": [1, 3, 4]
  }
}
```

### Delete Task
Delete a task from the system.

**Endpoint:** `DELETE /api/tasks/:id`

**Response (Success - 204):**
```
(Empty response body)
```

**Response (Error - 404):**
```json
{
  "message": "Task not found"
}
```

### Get Tasks by User
Retrieve all tasks assigned to a specific user.

**Endpoint:** `GET /api/tasks/users/:user_id`

**Response (Success - 200):**
```json
{
  "data": [
    {
      "id": 1,
      "title": "Complete project documentation",
      "description": "Write comprehensive API documentation",
      "status": 1,
      "status_name": "active",
      "user_ids": [1, 2]
    }
  ]
}
```

**Response (Error - 404):**
```json
{
  "message": "No tasks found for this user"
}
```

**Frontend Example:**
```javascript
const fetchUserTasks = async (userId) => {
  const response = await fetch(`http://localhost:4000/api/tasks/users/${userId}`, {
    method: 'GET',
    headers: {
      'Content-Type': 'application/json',
    },
    credentials: 'include'
  });

  return await response.json();
};
```

---

## Task Status Values

The task status field accepts the following integer values:

| Value | Status Name | Description |
|-------|-------------|-------------|
| -1    | pending     | Task is pending approval or assignment |
| 0     | non_active  | Task is inactive or paused |
| 1     | active      | Task is currently being worked on |
| 2     | in_review   | Task is under review |
| 3     | completed   | Task has been completed |
| 5     | archived    | Task has been archived |

---

## Error Handling

### Common HTTP Status Codes

- **200 OK**: Request successful
- **201 Created**: Resource created successfully
- **204 No Content**: Successful request with no response body
- **400 Bad Request**: Invalid request data
- **401 Unauthorized**: Authentication failed
- **404 Not Found**: Resource not found
- **422 Unprocessable Entity**: Validation errors

### Error Response Format

All error responses follow a consistent format:

```json
{
  "error": "Error message",          // Single error
  "message": "Error message",        // Alternative single error
  "errors": {                        // Multiple validation errors
    "field_name": ["error message 1", "error message 2"]
  }
}
```

### Frontend Error Handling Example

```javascript
const handleApiCall = async (apiFunction) => {
  try {
    const response = await apiFunction();
    
    if (!response.ok) {
      const errorData = await response.json();
      console.error('API Error:', errorData);
      return { success: false, error: errorData };
    }
    
    const data = await response.json();
    return { success: true, data };
  } catch (error) {
    console.error('Network Error:', error);
    return { success: false, error: { message: 'Network error occurred' } };
  }
};
```

---

## CORS Configuration

The API includes CORS (Cross-Origin Resource Sharing) support for frontend integration:

### Allowed Origins
- `http://localhost:3001` (and other localhost ports)
- Development and production domains (as configured)

### Allowed Headers
- `Content-Type`
- `Authorization`
- `X-Requested-With`

### Allowed Methods
- `GET`, `POST`, `PUT`, `DELETE`, `OPTIONS`

### Credentials
- Cookies and authentication headers are supported
- Use `credentials: 'include'` in fetch requests

### Frontend CORS Example

```javascript
// Correct way to make CORS requests
const apiCall = async (endpoint, options = {}) => {
  const response = await fetch(`http://localhost:4000${endpoint}`, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      ...options.headers
    },
    credentials: 'include' // Important for cookies/sessions
  });
  
  return response;
};
```

---

## Complete Frontend Integration Example

Here's a complete example of a frontend service class:

```javascript
class GothamTimeManagerAPI {
  constructor(baseURL = 'http://localhost:4000') {
    this.baseURL = baseURL;
  }

  async request(endpoint, options = {}) {
    const response = await fetch(`${this.baseURL}${endpoint}`, {
      ...options,
      headers: {
        'Content-Type': 'application/json',
        ...options.headers
      },
      credentials: 'include'
    });

    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.message || error.error || 'API request failed');
    }

    // Handle 204 No Content responses
    if (response.status === 204) {
      return null;
    }

    return await response.json();
  }

  // Authentication
  async login(emailOrUsername, password) {
    const loginData = { password };
    if (emailOrUsername.includes('@')) {
      loginData.email = emailOrUsername;
    } else {
      loginData.username = emailOrUsername;
    }

    return await this.request('/api/login', {
      method: 'POST',
      body: JSON.stringify(loginData)
    });
  }

  async logout() {
    return await this.request('/api/logout', { method: 'POST' });
  }

  // Users
  async getUsers() {
    return await this.request('/api/users');
  }

  async getUser(id) {
    return await this.request(`/api/users/${id}`);
  }

  async createUser(userData) {
    return await this.request('/api/users', {
      method: 'POST',
      body: JSON.stringify({ user: userData })
    });
  }

  async updateUser(id, userData) {
    return await this.request(`/api/users/${id}`, {
      method: 'PUT',
      body: JSON.stringify({ user: userData })
    });
  }

  async deleteUser(id) {
    return await this.request(`/api/users/${id}`, { method: 'DELETE' });
  }

  // Tasks
  async getTasks() {
    return await this.request('/api/tasks');
  }

  async getTask(id) {
    return await this.request(`/api/tasks/${id}`);
  }

  async createTask(taskData) {
    return await this.request('/api/tasks', {
      method: 'POST',
      body: JSON.stringify({ task: taskData })
    });
  }

  async updateTask(id, taskData) {
    return await this.request(`/api/tasks/${id}`, {
      method: 'PUT',
      body: JSON.stringify({ task: taskData })
    });
  }

  async deleteTask(id) {
    return await this.request(`/api/tasks/${id}`, { method: 'DELETE' });
  }

  async getUserTasks(userId) {
    return await this.request(`/api/tasks/users/${userId}`);
  }
}

// Usage example
const api = new GothamTimeManagerAPI();

// Login user
api.login('john@example.com', 'password123')
  .then(response => console.log('Login successful:', response))
  .catch(error => console.error('Login failed:', error));

// Create task
api.createTask({
  title: 'New Feature Development',
  description: 'Implement user dashboard',
  status: 1,
  user_ids: [1, 2]
})
  .then(response => console.log('Task created:', response))
  .catch(error => console.error('Task creation failed:', error));
```

---

## Notes

1. **Authentication**: The current implementation uses basic session-based authentication. For production, consider implementing JWT tokens with proper expiration and refresh mechanisms.

2. **Validation**: Always validate input data on both frontend and backend.

3. **Error Handling**: Implement comprehensive error handling in your frontend application.

4. **Security**: Ensure HTTPS is used in production environments.

5. **Rate Limiting**: Consider implementing rate limiting for production APIs.

6. **Pagination**: For large datasets, implement pagination on list endpoints.

This documentation covers all available endpoints in the Gotham Time Manager API. For any additional features or modifications, please refer to the Phoenix application source code or contact the development team.
