require 'rubygems'
require 'active_resource'
require 'active_support'

module Acts
  module Callbacks
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def acts_with_callbacks(options = {})

        class << self
          include ActiveSupport::Callbacks

          def do_callbacks(trigger_position, callback_method, trigger_methods)
            define_callbacks callback_method

            trigger_methods.each do |trigger_method|
              set_callback callback_method, trigger_position, trigger_method
            end

            class_eval %{
              def #{callback_method.to_s}(&block)
                run_callbacks(:#{callback_method.to_s}) do
                  yield if block_given?
                  super
                end
              end
            }
          end

          def method_missing(method_symbol, *arguments)
            method_name = method_symbol.to_s

            if method_name =~ /^(before|after)?_(save|destroy)?$/
              self.send :do_callbacks, $1.to_sym, $2.to_sym, arguments
            else
              super
            end
          end
        end
      end
    end
  end
end

ActiveResource::Base.send :include, Acts::Callbacks