# frozen_string_literal: true

RSpec.shared_context "with context for class methods via scope 'class << self'" do
  # NOTE: This use of `before(:all)` is a performance optimization that shaves
  # minutes off of our test suite, especially in older versions of Ruby.
  before(:all) do
    @_class_with_memo = Class.new do
      class << self
        prepend MemoWise

        DefineMethodsForTestingMemoWise.define_methods_for_testing_memo_wise(
          target: self,
          via: :instance
        )
      end

      # Counter for calls to instance method '#no_args', see below.
      def instance_no_args_counter
        @instance_no_args_counter || 0
      end

      # See: "with non-memoized method with same name as memoized method"
      #
      # Used by that spec to verify that `memo_wise self: :no_args` memoizes
      # only the class method, and not this instance method sharing the same
      # name.
      def no_args
        @instance_no_args_counter = instance_no_args_counter + 1
        "instance_no_args"
      end

      # Counter for calls to instance method '#with_one_positional_arg', see
      # below.
      def instance_one_positional_arg_counter
        @instance_one_positional_arg_counter || 0
      end

      # See: "with non-memoized method with same name as memoized method"
      #
      # Used by that spec to verify that `memo_wise self: :with_one_positional_arg`
      # memoizes only the class method, and not this instance method sharing
      # the same name.
      def with_one_positional_arg(a) # rubocop:disable Naming/MethodParameterName
        @instance_one_positional_arg_counter = instance_one_positional_arg_counter + 1
        "instance_with_one_positional_arg: a=#{a}"
      end

      # Counter for calls to instance method '#with_positional_args', see below.
      def instance_positional_args_counter
        @instance_positional_args_counter || 0
      end

      # See: "with non-memoized method with same name as memoized method"
      #
      # Used by that spec to verify that `memo_wise self: :with_positional_args`
      # memoizes only the class method, and not this instance method sharing
      # the same name.
      def with_positional_args(a, b) # rubocop:disable Naming/MethodParameterName
        @instance_positional_args_counter = instance_positional_args_counter + 1
        "instance_with_positional_args: a=#{a}, b=#{b}"
      end
    end
  end

  let(:class_with_memo) do
    # Because we now have shared state between tests, we need to ensure that we
    # reset memo_wise, as well as any test state, for each individual test.
    # rubocop:disable RSpec/InstanceVariable
    @_class_with_memo.reset_memo_wise
    @_class_with_memo.instance_variables.each do |var|
      # reset test method counters from DefineMethodsForTestingMemoWise
      @_class_with_memo.instance_variable_set(var, 0) if @_class_with_memo.instance_variable_get(var).is_a?(Integer)
    end
    @_class_with_memo
    # rubocop:enable RSpec/InstanceVariable
  end
end
