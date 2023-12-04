# frozen_string_literal: true

module ComThetrainline
  module Services
    # Base class for services
    class Base
      def self.call(*argv, **args, &block)
        new.call(*argv, **args, &block)
      end
    end
  end
end
