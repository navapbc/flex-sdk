Rails.application.routes.draw do
  mount Flex::Engine => "/flex"

  resources :passport_cases
end
