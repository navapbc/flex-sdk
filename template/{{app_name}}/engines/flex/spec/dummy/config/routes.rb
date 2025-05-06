Rails.application.routes.draw do
  get "passport_cases/show"
  mount Flex::Engine => "/flex"

  resources :passport_cases do
    collection do
      get :closed
    end
  end

  resources :passport_tasks do
  end
end
