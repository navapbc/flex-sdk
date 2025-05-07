Rails.application.routes.draw do
  mount Flex::Engine => "/flex"

  resources :passport_cases do
    collection do
      get :closed
    end
  end

  resources :passport_application_forms, only: [ :index, :show ]
  end

  resources :passport_tasks do
  end
end
