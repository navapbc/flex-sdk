Rails.application.routes.draw do
  mount Flex::Engine => "/flex"

  resources :passport_cases do
    collection do
      get :closed
    end
  end
end
