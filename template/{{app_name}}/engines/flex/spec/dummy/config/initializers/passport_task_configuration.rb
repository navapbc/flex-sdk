Rails.application.config.to_prepare do
  Rails.configuration.passport = {
    task_type_map: { 
      PassportPhotoTask => 'Verify Photo', 
      PassportVerifyInfoTask => 'Verify Info' 
    } 
  }
end