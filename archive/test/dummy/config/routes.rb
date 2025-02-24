Rails.application.routes.draw do
  # Gives access to the sdk views via
  mount FlexSdk::Engine => "/flex_sdk"
end
