require "ans-labelizer/version"

module Ans
  module Labelizer
    class Config
      def initialize
        @locale_path = "activerecord.flags"
      end

      attr_accessor :locale_path
    end

    def self.config
      @config ||= Config.new
    end

    def self.included(m)
      m.send :include, InstanceMethods
      m.send :extend, ClassMethods

      config = self.config

      ::I18n.t("#{config.locale_path}.#{m.model_name.underscore}", default: {}).each do |column,hash|
        inverse = hash.invert

        ClassMethods.class_eval do
          define_method :"#{column}_labels" do
            hash
          end
          define_method :"#{column}_keys" do
            inverse
          end
        end
        InstanceMethods.class_eval do
          define_method :"#{column}_label" do
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
