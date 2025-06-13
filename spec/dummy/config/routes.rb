Rails.application.routes.draw do
  mount Flex::Engine => "/"

  mount Lookbook::Engine, at: "/lookbook"

  resources :passport_cases do
    collection do
      get :closed
    end
  end

  resources :passport_application_forms, only: [ :index, :new, :create, :show ]
  resources :tasks, only: [ :index, :show, :update ]

  get "staff", to: "staff#index"
end
