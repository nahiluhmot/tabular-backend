desc 'Run the web server'
task web: :environment do
  unicorn_conf = { config_file: 'unicorn.rb' }
  app = Unicorn.builder('config.ru', unicorn_conf)
  Unicorn::HttpServer.new(app, unicorn_conf).start.join
end
