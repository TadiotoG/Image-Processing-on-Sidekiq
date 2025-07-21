# Pin npm packages
pin "@hotwired/turbo-rails"
pin "@hotwired/stimulus"
pin "@hotwired/stimulus-loading"
pin "@rails/actioncable"
pin "jquery", to: "https://cdn.jsdelivr.net/npm/jquery@3.7.1/dist/jquery.min.js"

pin_all_from "app/javascript/controllers", under: "controllers"
pin_all_from "app/javascript/channels", under: "channels"


pin "application", to: "application.js"
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
pin_all_from "app/javascript/channels", under: "channels"
pin "jquery", to: "https://cdn.jsdelivr.net/npm/jquery@3.7.1/dist/jquery.min.js"
pin "sweetalert2", to: "https://cdn.jsdelivr.net/npm/sweetalert2@11"
pin "@rails/actioncable", to: "actioncable.esm.js"
