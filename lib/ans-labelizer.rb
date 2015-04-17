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
      config.get_method_suffix = "_of"
      config.confirm_method_suffix = "_is?"
      config.inclusion_method_suffix = "_in?"
      config.transition_method_suffix = "_name="
      config.flags_method_name = "labelizer_flags"
    end

    def self.included(m)
      label_class_name = "#{m.to_s.gsub("::","__")}AnsLabels".to_sym

      config = Ans::Labelizer.config

      locale_path = config.locale_path
      hash_method_suffix = config.hash_method_suffix
      name_hash_method_suffix = config.name_hash_method_suffix
      inverse_method_suffix = config.inverse_method_suffix
      name_inverse_method_suffix = config.name_inverse_method_suffix
      values_method_suffix = config.values_method_suffix
      label_method_suffix = config.label_method_suffix
      name_method_suffix = config.name_method_suffix
      get_method_suffix = config.get_method_suffix
      confirm_method_suffix = config.confirm_method_suffix
      inclusion_method_suffix = config.inclusion_method_suffix
      transition_method_suffix = config.transition_method_suffix
      flags_method_name = config.flags_method_name

      klass = (class << m; self; end)

      flags = {}

      ::I18n.t("#{locale_path}.#{m.model_name.singular}", default: {}).each do |column,hash|
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

        flags[column] = {
          name: name_hash,
          label: label_hash,
          name_inverse: name_inverse,
          label_inverse: label_inverse,
        }

        klass.class_eval do
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
              unless name_inverse.has_key?(key)
                raise KeyError, "label key not found. [#{name}] -- all keys: #{name_inverse.keys.inspect}"
              end
              name_inverse[key]
            }.compact
          end
          define_method :"#{column}#{get_method_suffix}" do |name|
            unless name_inverse.has_key?(name)
              raise KeyError, "label key not found. [#{name}] -- all keys: #{name_inverse.keys.inspect}"
            end
            name_inverse[name]
          end
          name_hash.each do |value,name|
            define_method :"#{column}_#{name}" do
              value
            end
          end
        end
        m.class_eval do
          define_method :"#{column}#{label_method_suffix}" do
            label_hash[send :"#{column}"]
          end
          define_method :"#{column}#{name_method_suffix}" do
            name_hash[send :"#{column}"]
          end

          define_method :"#{column}#{values_method_suffix}" do |*keys|
            keys.map{|key|
              unless name_inverse.has_key?(key)
                raise KeyError, "label key not found. [#{name}] -- all keys: #{name_inverse.keys.inspect}"
              end
              name_inverse[key]
            }.compact
          end
          define_method :"#{column}#{get_method_suffix}" do |name|
            unless name_inverse.has_key?(name)
              raise KeyError, "label key not found. [#{name}] -- all keys: #{name_inverse.keys.inspect}"
            end
            name_inverse[name]
          end
          define_method :"#{column}#{confirm_method_suffix}" do |name|
            unless name_inverse.has_key?(name)
              raise KeyError, "label key not found. [#{name}] -- all keys: #{name_inverse.keys.inspect}"
            end
            send(:"#{column}") == name_inverse[name]
          end
          define_method :"#{column}#{inclusion_method_suffix}" do |*names|
            value = send(:"#{column}")
            names.any?{|name|
              unless name_inverse.has_key?(name)
                raise KeyError, "label key not found. [#{name}] -- all keys: #{name_inverse.keys.inspect}"
              end
              value == name_inverse[name]
            }
          end
          define_method :"#{column}#{transition_method_suffix}" do |name|
            unless name_inverse.has_key?(name)
              raise KeyError, "label key not found. [#{name}] -- all keys: #{name_inverse.keys.inspect}"
            end
            send(:"#{column}=", name_inverse[name])
          end

          name_hash.each do |value,name|
            define_method :"#{column}_#{name}" do
              value
            end
            define_method :"#{column}_#{name}?" do
              send(:"#{column}") == value
            end
            define_method :"#{column}_#{name}!" do
              send(:"#{column}=", value)
            end
          end
        end
      end

      klass.class_eval do
        define_method :"#{flags_method_name}" do
          flags
        end
      end

    end
  end
end
