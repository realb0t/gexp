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
