require "ans-labelizer/version"

module Ans
  module Labelizer
    include ActiveSupport::Configurable

    configure do |config|
      config.locale_path = "activerecord.flags"
      config.hash_method_suffix = "_labels"
      config.inverse_method_suffix = "_keys"
      config.label_method_suffix = "_label"
    end

    def self.included(m)
      class_name = m.class.to_s.to_sym

      instance_methods = nil
      class_methods = nil

      InstanceMethods.class_eval do
        instance_methods = Module.new
        const_set class_name, instance_methods
        m.send :include, instance_methods
      end
      ClassMethods.class_eval do
        class_methods = Module.new
        const_set class_name, class_methods
        m.send :extend, class_methods
      end

      config = Ans::Labelizer.config

      locale_path = config.locale_path
      hash_method_suffix = config.hash_method_suffix
      inverse_method_suffix = config.inverse_method_suffix
      label_method_suffix = config.label_method_suffix

      ::I18n.t("#{locale_path}.#{m.model_name.underscore}", default: {}).each do |column,hash|
        inverse = hash.invert

        class_methods.class_eval do
          define_method :"#{column}#{hash_method_suffix}" do
            hash
          end
          define_method :"#{column}#{inverse_method_suffix}" do
            inverse
          end
        end
        instance_methods.class_eval do
          define_method :"#{column}#{label_method_suffix}" do
            hash[send :"#{column}"]
          end
        end
      end
    end

    module InstanceMethods
    end
    module ClassMethods
    end
  end
end
