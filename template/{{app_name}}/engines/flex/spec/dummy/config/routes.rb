Rails.application.routes.draw do
  get "passport_application_forms/index"
  get "passport_application_forms/show"
  get "passport_cases/show"
  mount Flex::Engine => "/flex"

  resources :passport_cases do
    collection do
      get :closed
    end
  end
end
