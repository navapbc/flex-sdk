Rails.application.routes.draw do
  mount Flex::Engine => "/flex"

  mount Lookbook::Engine, at: "/lookbook" if Rails.env.development?

  resources :passport_cases do
    collection do
      get :closed
    end
  end

  resources :passport_application_forms, only: [ :index, :show ]
end
