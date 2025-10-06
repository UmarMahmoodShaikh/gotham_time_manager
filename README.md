# GothamTimeManager

To start your Phoenix server:

* Run `mix setup` to install and setup dependencies
* Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

* Official website: https://www.phoenixframework.org/
* Guides: https://hexdocs.pm/phoenix/overview.html
* Docs: https://hexdocs.pm/phoenix
* Forum: https://elixirforum.com/c/phoenix-forum
* Source: https://github.com/phoenixframework/phoenix

# Gotham Time Manager

## Calling protected APIs (JWT + XSRF)

All protected endpoints require BOTH:
- Authorization: Bearer <jwt_from_login>
- x-xsrf-token: <xsrf_token_from_login>
- The session cookie set during login (so the server can compare the XSRF token). In browsers this is automatic; in Postman, enable cookie storage and make login first in the same collection so cookies are sent with subsequent requests.

### Flow
1. POST /api/login with email or username and password
   - Response includes: token (JWT), xsrf_token, and sets a cookie-based session.
2. For any subsequent protected request (e.g., GET /api/users):
   - Add header: Authorization: Bearer <token>
   - Add header: x-xsrf-token: <xsrf_token>
   - Ensure Postman/cURL sends the cookie from step 1.

### Common 401 reasons
- missing_authorization_header: Add Authorization: Bearer ...
- invalid_jwt: The token is invalid or expired
- user_not_found: JWT sub does not map to an existing user
- missing_or_invalid_xsrf_token: x-xsrf-token header missing or does not match the value stored in the session cookie from login

### Example (cURL)
Login:
  curl -i -c cookies.txt -H 'Content-Type: application/json' \
    -d '{"email":"uni@epitech.eu","password":"yourpass"}' \
    http://localhost:4000/api/login

Use protected endpoint:
  curl -i -b cookies.txt -H 'Authorization: Bearer YOUR_JWT' \
    -H 'x-xsrf-token: YOUR_XSRF' \
    http://localhost:4000/api/users

Note: Only POST /api/users (create) and POST /api/login are public. All other /api routes require JWT + XSRF.
