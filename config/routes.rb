require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  localized do
    devise_for :users

    namespace :api do
      namespace :v1 do
        resources :***REMOVED***, only: [:create]
      end
    end

    concern :history do
      member do
        get :history
      end
    end

    resources :registrations do
      collection do
        get :parents
        get :students
        post :students
        get :employees
        post :employees
      end
    end

    resources :students do
      collection do
        get :search_api
      end
    end

    resources :teachers, only: :index

    root 'dashboard#index'

    get '/sandbox', to: 'dashboard#sandbox'
    get '/current_role/:id', to: 'current_role#set', as: :set_current_role
    get '/current_role', to: 'current_role#index', as: :current_roles
    get '/system_***REMOVED***/read_all', to: 'system_***REMOVED***#read_all', as: :read_all_***REMOVED***

    resources :messages, except: [:edit, :update] do
      collection do
        delete :destroy_batch
      end
    end
    resources :users, concerns: :history
    resource :account, only: [:edit, :update]
    resources :roles do
      member do
        get :history
      end
    end
    resources :***REMOVED***, only: [:index]
    resources :***REMOVED***, only: [:index, :show]
    resources :***REMOVED***_confirmations, except: [:new, :create] do
      member do
        patch :cancel
        patch :preview
        patch :confirm
      end
    end
    resource :***REMOVED***_configs, only: [:edit, :update], concerns: :history
    resources :***REMOVED***s, concerns: :history
    resource :ieducar_api_configurations, only: [:edit, :update], concerns: :history do
      resources :syncronizations, only: [:index, :create]
    end
    resource :contact_school, only: [:new, :create]
    resource :notification, only: [:edit, :update], concerns: :history
    resource :general_configurations, only: [:edit, :update], concerns: :history
    resource :entity_configurations, only: [:edit, :update], concerns: :history
    resources :backup_files, only: [:index, :create]
    resources :unities, concerns: :history do
      collection do
        delete :destroy_batch
        get :synchronizations
        post :create_batch
      end
    end
    resources :***REMOVED***, concerns: :history
    resources :***REMOVED***_classes, concerns: :history
    resources :***REMOVED***, concerns: :history
    resources :***REMOVED***, concerns: :history
    resources :***REMOVED***, concerns: :history
    resources :***REMOVED***, concerns: :history
    resources :***REMOVED***, concerns: :history do
      resources :material_request_items, only: [:index]
    end
    resources :***REMOVED***, concerns: :history do
      resources :material_request_authorization_items, only: [:index]
    end
    resources :***REMOVED***, concerns: :history do
      resources :material_exit_items, only: [:index]
    end
    resources :***REMOVED***, concerns: :history
    resources :***REMOVED***, concerns: :history
    resources :***REMOVED***s, concerns: :history
    resources :***REMOVED***, concerns: :history
    resources :lectures, only: [:index]
    resources :grades, only: [:index]
    resources :schools, only: [:index]
    resources :***REMOVED***, concerns: :history
    resources :***REMOVED***, concerns: :history
    resources :authorization_***REMOVED***, concerns: :history
    resources :moved_***REMOVED***, only: [:index]
    resources :***REMOVED***, concerns: :history

    resources :test_settings, concerns: :history do
      resources :test_setting_tests, only: [:index]
    end

    resources :school_calendars, concerns: :history do
      resources :school_calendar_steps, only: [:index]
      resources :school_calendar_events, concerns: :history
    end

    resources :teaching_plans, concerns: :history
    resources :contents, concerns: :history
    resources :classrooms, only: [:index]
    resources :disciplines, only: [:index]
    resources :exam_rules, only: [:index]
    resources :avaliations, concerns: :history
    resources :teacher_avaliations, only: :index
    resources :daily_notes, only: [:new, :create, :edit, :update], concerns: :history
    resources :conceptual_exams, only: [:new, :create, :edit, :update]
    resources :descriptive_exams, only: [:new, :create, :edit, :update]
    resources :daily_frequencies, only: [:new, :create], concerns: :history do
      collection do
        get :edit_multiple
        put :update_multiple
      end
    end
    resources :absence_justifications, concerns: :history

    get '/reports/attendance_record', to: 'attendance_record_report#form', as: 'attendance_record_report'
    post '/reports/attendance_record', to: 'attendance_record_report#report', as: 'attendance_record_report'
  end
end
