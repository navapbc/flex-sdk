Rails.application.configure do
  config.lookbook.preview_paths = [ Rails.root.join("app", "previews") ] if Rails.env.development?
end
