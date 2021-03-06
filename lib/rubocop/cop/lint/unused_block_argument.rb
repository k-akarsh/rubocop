# encoding: utf-8

module Rubocop
  module Cop
    module Lint
      # This cop checks for unused block arguments.
      #
      # @example
      #
      #   do_something do |used, unused, _unused_but_allowed|
      #     puts used
      #   end
      class UnusedBlockArgument < Cop
        include UnusedArgument
        include Util

        def check_argument(variable)
          return unless variable.block_argument?
          super
        end

        def message(variable)
          message = "Unused block argument - `#{variable.name}`. "

          scope = variable.scope
          all_arguments = scope.variables.each_value.select(&:block_argument?)

          if lambda?(scope.node)
            message << message_for_lambda(variable, all_arguments)
          else
            message << message_for_normal_block(variable, all_arguments)
          end

          message
        end

        def message_for_normal_block(variable, all_arguments)
          if all_arguments.none?(&:referenced?)
            if all_arguments.count > 1
              "You can omit all the arguments if you don't care about them."
            else
              "You can omit the argument if you don't care about it."
            end
          else
            message_for_underscore_prefix(variable)
          end
        end

        def message_for_lambda(variable, all_arguments)
          message = message_for_underscore_prefix(variable)

          if all_arguments.none?(&:referenced?)
            message << ' Also consider using a proc without arguments ' \
                       'instead of a lambda if you want it ' \
                        "to accept any arguments but don't care about them."
          end

          message
        end

        def message_for_underscore_prefix(variable)
          "If it's necessary, use `_` or `_#{variable.name}` " \
          "as an argument name to indicate that it won't be used."
        end
      end
    end
  end
end
