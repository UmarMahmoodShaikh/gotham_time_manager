defmodule GothamWeb.Router do
  use GothamWeb, :router

  # Browser pipeline (only for HTML pages like "/")
  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {GothamWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  # API pipeline for JSON requests
  pipeline :api do
    plug :accepts, ["json"]
    plug GothamWeb.Plugs.ContentNegotiation
  end

  # Pipeline for API routes that require JWT authentication
  pipeline :auth do
    plug GothamWeb.Plugs.AuthenticateUser
  end

  # Browser route
  scope "/", GothamWeb do
    pipe_through :browser
    get "/", PageController, :home
  end

  # Public API routes (no auth)
  scope "/api", GothamWeb do
    pipe_through :api

    # Auth routes
    post "/sign_up", AuthController, :sign_up
    post "/sign_in", AuthController, :sign_in
    delete "/sign_out", AuthController, :sign_out

    # Additional login/logout endpoints for API documentation compatibility
    post "/login", AuthController, :login
    post "/logout", AuthController, :logout

    # JWT-based auth endpoints for Postman collection compatibility
    post "/auth/register", AuthController, :register
    post "/auth/login", AuthController, :auth_login
    post "/auth/logout", AuthController, :auth_logout
  end

  # Protected API routes
  scope "/api", GothamWeb do
    pipe_through [:api, :auth]

    # Protected auth endpoint
    get "/auth/me", AuthController, :me

    # Users
    resources "/users", UserController, except: []
    put "/users/:id/role", UserController, :update_role
    resources "/roles", RoleController, only: [:index, :show]
    put "/permissions/:user_id", PermissionController, :update
    delete "/permissions/:user_id", PermissionController, :delete

    # Clock & Working time
    get "/clocks/:userID", ClockController, :show
    post "/clocks/:userID", ClockController, :create

    get "/workingtime/:userID", WorkingTimeController, :index
    get "/workingtime/:userID/:id", WorkingTimeController, :show
    post "/workingtime/:userID", WorkingTimeController, :create
    put "/workingtime/:id", WorkingTimeController, :update
    delete "/workingtime/:id", WorkingTimeController, :delete

    # Time Tracking API (Time Manager Documentation)
    post "/time-tracking/clock-in", TimeTrackingController, :clock_in
    post "/time-tracking/clock-out", TimeTrackingController, :clock_out
    get "/time-tracking/status", TimeTrackingController, :status
    get "/time-tracking/entries", TimeTrackingController, :entries
    post "/time-tracking/manual-entry", TimeTrackingController, :create_manual_entry
    put "/time-tracking/entries/:id", TimeTrackingController, :update_entry
    delete "/time-tracking/entries/:id", TimeTrackingController, :delete_entry

    # Approvals API
    get "/approvals/pending", ApprovalController, :pending
    post "/approvals/:id/approve", ApprovalController, :approve
    post "/approvals/:id/reject", ApprovalController, :reject
    post "/approvals/bulk-approve", ApprovalController, :bulk_approve
    get "/approvals/history", ApprovalController, :history

    # Analytics API
    get "/analytics/dashboard", AnalyticsController, :dashboard
    get "/analytics/team-performance", AnalyticsController, :team_performance
    get "/analytics/attendance-trends", AnalyticsController, :attendance_trends
    get "/analytics/productivity-insights", AnalyticsController, :productivity_insights

    # Reports API
    get "/reports/timesheet", ReportsController, :timesheet
    get "/reports/attendance", ReportsController, :attendance
    get "/reports/payroll", ReportsController, :payroll
    get "/reports/overtime", ReportsController, :overtime

    # Settings API
    get "/settings/profile", SettingsController, :profile
    put "/settings/profile", SettingsController, :update_profile
    get "/settings/notifications", SettingsController, :notifications
    put "/settings/notifications", SettingsController, :update_notifications
    get "/settings/work-preferences", SettingsController, :work_preferences
    put "/settings/work-preferences", SettingsController, :update_work_preferences
    get "/settings/system", SettingsController, :system
    put "/settings/system", SettingsController, :update_system

    # Payroll API
    get "/payroll/summary", PayrollController, :summary
    get "/payroll/history", PayrollController, :history
    post "/payroll/generate", PayrollController, :generate
    get "/payroll/rates", PayrollController, :rates
    put "/payroll/rates/:user_id", PayrollController, :update_rates

    # Notification API
    get "/notifications", NotificationController, :index
    get "/notifications/unread-count", NotificationController, :unread_count
    put "/notifications/:id/read", NotificationController, :mark_as_read
    put "/notifications/mark-all-read", NotificationController, :mark_all_as_read
    delete "/notifications/:id", NotificationController, :delete
    post "/notifications/preferences", NotificationController, :update_preferences

    # User Profile & Break Management API
    get "/user/profile", UserProfileController, :show
    put "/user/profile", UserProfileController, :update
    put "/user/password", UserProfileController, :change_password
    get "/user/dashboard", UserProfileController, :dashboard
    post "/user/breaks/start", UserProfileController, :start_break
    post "/user/breaks/end", UserProfileController, :end_break
    get "/user/breaks/status", UserProfileController, :break_status
    get "/user/breaks/history", UserProfileController, :break_history
    get "/user/breaks/summary", UserProfileController, :break_summary

    # WorkingTimes for payroll and generic access
    resources "/working_times", WorkingTimeController, except: [:new, :edit]

    # Activities / Tasks
    get "/activities/billable", TaskController, :billable
    post "/logs/overtime/unpaid", WorkingTimeController, :log_unpaid_overtime

    # Unrecognized work
    resources "/unrecognized_works", UnrecognizedWorkController, except: [:new, :edit]

    # Schedules
    get "/schedules/:employee_id/constraints", ScheduleController, :constraints
    post "/schedules/create_batch", ScheduleController, :create_batch
    put "/schedules/create_batch", ScheduleController, :create_batch
    resources "/schedules", ScheduleController, except: [:new, :edit]

    # Shifts
    resources "/shifts", ShiftController, except: [:new, :edit, :delete]

    # Leaves
    resources "/leaves", LeaveController, except: [:new, :edit]

    # Payroll & Timesheet
    get "/payroll/calculation/rates", WorkingTimeController, :calculation_rates
    get "/payroll/report/:id", WorkingTimeController, :payroll_report
    put "/timesheets/:id/validate", WorkingTimeController, :validate_timesheet
    post "/audit/discrepancy/resolve", WorkingTimeController, :resolve_discrepancy

    # Audit
    get "/audit/night_shift_alert", ShiftController, :night_shift_alert
    get "/audit/presence_verification", ClockController, :presence_verification

    # Integration
    post "/integration/batsignal", IntegrationController, :batsignal
    resources "/integrations", IntegrationController, except: [:new, :edit]

    # Tasks & skills
    resources "/tasks", TaskController, except: [:new, :edit]
    put "/tasks/:taskid/status", TaskController, :update_status

    # Teams & Projects
    resources "/teams", TeamController, except: [:new, :edit]
    put "/teams/:id/assign_manager", TeamController, :assign_manager
    put "/teams/:id/status", TeamController, :set_status

    resources "/projects", ProjectController, except: [:new, :edit]
    post "/projects/:id/tasks/:task_id", ProjectController, :add_task
    post "/projects/:id/teams/:team_id", ProjectController, :add_to_team

    resources "/skills", SkillController, except: []
    get "/skills/user/:userId", SkillController, :user_skills

    # User skills
    post "/users/:userid/skills/:skillid", UserSkillController, :create
    delete "/users/:userid/skills/:skillid", UserSkillController, :delete
    resources "/user_skills", UserSkillController, except: [:new, :edit]

    # Task skills
    put "/tasks/:taskid/skills/:skillid", TaskSkillController, :update
    resources "/task_skills", TaskSkillController, except: [:new, :edit]

    # Task assignments
    post "/tasks/:taskid/user/:userid", TaskAssignmentController, :create
    delete "/tasks/:taskid/user/:userid", TaskAssignmentController, :delete
    resources "/task_assignments", TaskAssignmentController, except: [:new, :edit]
    resources "/compensation_logs", CompensationLogController, except: [:new, :edit]
  end

  # Dev-only routes (dashboard, mailbox)
  if Application.compile_env(:gotham, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: GothamWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
