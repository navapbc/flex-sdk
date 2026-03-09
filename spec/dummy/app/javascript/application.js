// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import { Application } from "@hotwired/stimulus"
import { registerControllers } from "strata"

const application = Application.start()
registerControllers(application)
