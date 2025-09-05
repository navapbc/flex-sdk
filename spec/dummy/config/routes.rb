Rails.application.routes.draw do
  mount Flex::Engine => "/"

  mount Lookbook::Engine, at: "/lookbook"

  resources :passport_application_forms, only: [ :index, :new, :show, :create ]

  scope path: "/staff" do
    resources :passport_cases do
      resources :tasks, shallow: true
  
      collection do
        get :closed
      end
  
      member do
        get :application_details
        get :documents
        get :history
        get :notes
      end
    end

    resources :tasks, only: [ :index, :show, :update ] do
      collection do
        post :pick_up_next_task
      end
    end
  end

  get "staff", to: "staff#index"
end
