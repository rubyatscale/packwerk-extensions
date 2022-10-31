# typed: strict
# frozen_string_literal: true

require "constant_resolver"
require "pathname"
require "yaml"

module Packwerk
  module ValidatorInterface
    extend T::Sig
    extend T::Helpers

    abstract!

    class << self
      extend T::Sig

      sig { params(base: Class).void }
      def included(base)
        @validators ||= T.let(@validators, T.nilable(T::Array[Class]))
        @validators ||= []
        @validators << base
      end

      sig { returns(T::Array[ValidatorInterface]) }
      def all
        T.unsafe(@validators).map(&:new)
      end
    end

    sig { abstract.returns(T::Array[String]) }
    def permitted_keys
    end

    sig { abstract.params(package_set: PackageSet, configuration: Configuration).returns(ApplicationValidator::Result) }
    def call(package_set, configuration)
    end
  end
end
