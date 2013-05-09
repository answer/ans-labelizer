require "ans-labelizer/version"

module Ans
  module Labelizer
    class Config
      def initialize
        @locale_path = "activerecord.flags"
        @hash_method_suffix = "_labels"
        @inverse_method_suffix = "_keys"
        @label_method_suffix = "_label"
      end

      attr_accessor :locale_path, :hash_method_suffix, :inverse_method_suffix, :label_method_suffix
    end

    def self.config
      @config ||= Config.new
    end
    def self.configure
      yield config
    end

    def self.included(m)
      m.send :include, InstanceMethods
      m.send :extend, ClassMethods

      config = self.config

      locale_path = config.locale_path
      hash_method_suffix = config.hash_method_suffix
      inverse_method_suffix = config.inverse_method_suffix
      label_method_suffix = config.label_method_suffix

      ::I18n.t("#{locale_path}.#{m.model_name.underscore}", default: {}).each do |column,hash|
        inverse = hash.invert

        ClassMethods.class_eval do
          define_method :"#{column}#{hash_method_suffix}" do
            hash
          end
          define_method :"#{column}#{inverse_method_suffix}" do
            inverse
          end
        end
        InstanceMethods.class_eval do
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
