Flex::Engine.routes.draw do
  namespace :staff do
    root to: "dashboard#index"
  end
end
