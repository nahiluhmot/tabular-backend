task routes: :environment do
  routes = Tabular::Controllers::Main.apps.flat_map do |app|
    app.routes.reject { |verb| verb == 'HEAD' }.flat_map do |verb, app_routes|
      app_routes.map do |route|
        {
          controller: app.name,
          verb: verb,
          route: route[0].inspect
        }
      end
    end
  end

  Formatador.display_table(routes, [:controller, :verb, :route])
end
