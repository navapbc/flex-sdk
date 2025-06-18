Rails.application.routes.draw do
  mount Flex::Engine => "/"

  mount Lookbook::Engine, at: "/lookbook"

  resources :passport_cases do
    collection do
      get :closed
    end
  end

  resources :passport_application_forms, only: [ :index, :new, :show ]
  resources :tasks, only: [ :index, :show, :update ] do
    member do
      patch 'assign/:user_id', to: 'tasks#assign', as: 'assign'
    end
    collection do
      post :pick_up_next_task
    end
  end

  get "staff", to: "staff#index"
end
