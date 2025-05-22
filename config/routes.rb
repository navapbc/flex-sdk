Flex::Engine.routes.draw do
  resources :tasks, only: [ :index, :show, :update ]
end
