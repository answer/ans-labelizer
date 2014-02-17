require "ans-labelizer/version"

module Ans
  module Labelizer
    include ActiveSupport::Configurable

    configure do |config|
      config.locale_path = "activerecord.flags"
      config.hash_method_suffix = "_labels"
      config.name_hash_method_suffix = "_names"
      config.inverse_method_suffix = "_keys"
      config.name_inverse_method_suffix = "_name_keys"
      config.values_method_suffix = "_values"
      config.label_method_suffix = "_label"
      config.name_method_suffix = "_name"
    end

    def self.included(m)
      label_class_name = "#{m.to_s}AnsLabels".to_sym

      instance_methods = nil
      class_methods = nil

      InstanceMethods.class_eval do
        if const_defined?(label_class_name)
          instance_methods = const_get label_class_name
        else
          instance_methods = Module.new
          const_set label_class_name, instance_methods
        end
        m.send :include, instance_methods
      end
      ClassMethods.class_eval do
        if const_defined?(label_class_name)
          class_methods = const_get label_class_name
        else
          class_methods = Module.new
          const_set label_class_name, class_methods
        end
        m.send :extend, class_methods
      end

      config = Ans::Labelizer.config

      locale_path = config.locale_path
      hash_method_suffix = config.hash_method_suffix
      name_hash_method_suffix = config.name_hash_method_suffix
      inverse_method_suffix = config.inverse_method_suffix
      name_inverse_method_suffix = config.name_inverse_method_suffix
      values_method_suffix = config.values_method_suffix
      label_method_suffix = config.label_method_suffix
      name_method_suffix = config.name_method_suffix

      ::I18n.t("#{locale_path}.#{m.model_name.underscore}", default: {}).each do |column,hash|
        name_hash = {}
        label_hash = {}
        hash.each do |value,labels|
          case labels
          when Hash
            labels.each do |k,v|
              name_hash[value] = k
              label_hash[value] = v
              break
            end
          else
            label_hash[value] = labels
          end
        end

        name_inverse = name_hash.invert
        label_inverse = label_hash.invert

        class_methods.class_eval do
          define_method :"#{column}#{hash_method_suffix}" do
            label_hash
          end
          define_method :"#{column}#{name_hash_method_suffix}" do
            name_hash
          end
          define_method :"#{column}#{inverse_method_suffix}" do
            label_inverse
          end
          define_method :"#{column}#{name_inverse_method_suffix}" do
            name_inverse
          end
          define_method :"#{column}#{values_method_suffix}" do |*keys|
            keys.map{|key|
              name_inverse[key]
            }.compact
          end
        end
        instance_methods.class_eval do
          define_method :"#{column}#{label_method_suffix}" do
            label_hash[send :"#{column}"]
          end
          define_method :"#{column}#{name_method_suffix}" do
            name_hash[send :"#{column}"]
          end
          name_hash.each do |value,name|
            define_method :"#{column}_#{name}?" do
              send(:"#{column}") == value
            end
            define_method :"#{column}_#{name}!" do
              send(:"#{column}=", value)
            end
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
