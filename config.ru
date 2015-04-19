# This file initializes the web application.
map ('/api/') do
  run Tabular::Controllers::Main
end
