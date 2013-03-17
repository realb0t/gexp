require "gexp/version"

module Gexp
  class << self
    def label_to_class(label)
      label.split('.').
        map(&:classify).
        join('::').constantize
    end

    def class_to_label(klass)
      klass.name.split('::').
        map(&:underscore).join('.')
    end
  end
end

Dir["#{File.dirname(__FILE__)}/gexp/**/*.rb"].sort.each do |path|
  require path
end

require "#{File.dirname(__FILE__)}/examples/user_example"
require "#{File.dirname(__FILE__)}/examples/item_example"
