module Tabular
  module Services
    # This service holds the global logger.
    module Logger
      module_function

      LOG_LEVELS = [:fatal, :error, :warn, :info, :debug]

      def raw_logger
        @raw_logger ||= ::Logger.new($stderr)
      end

      LOG_LEVELS.each do |method|
        define_method(method) do |*args, &block|
          raw_logger.public_send(method, *args, &block)
        end
      end
    end
  end
end
