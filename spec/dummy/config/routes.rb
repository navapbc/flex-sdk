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
    collection do
      post :pick_up_next_task
    end
  end

  get "staff", to: "staff#index"
end
