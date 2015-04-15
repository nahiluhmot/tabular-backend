module Tabular
  module Services
    # This module defines the present method, which can be used to infer the
    module Presenters
      module_function

      def present!(model, *args)
        basic_name = model.class.name.split('::').last.to_sym
        klass = Tabular::Presenters.const_get(basic_name)
        present_with!(model, klass, *args)
      rescue NameError
        raise Errors::PresentationError, "No presenter for: #{model.class.name}"
      end

      def present_with!(model, klass, *args)
        klass.new(model).present(*args)
      end

      def present_json!(model, *args)
        present!(model, *args).to_json
      end

      def present_json_with!(model, klass, *args)
        present_with!(model, klass, *args).to_json
      end
    end
  end
end
