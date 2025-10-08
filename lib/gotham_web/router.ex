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
  end

  # Protected API routes
  scope "/api", GothamWeb do
    pipe_through [:api, :auth]

    # Users
    resources "/users", UserController, except: [:new, :edit]
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
    resources "/shifts", ShiftController, except: [:new, :edit]

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
end
