Rails.application.routes.draw do
  mount FlexSdk::Engine => "/flex_sdk"
end
