# typed: strict

module Packwerk
  class Reference
    Reference = Struct.new(:source_package, :relative_path, :constant, :source_location)
    sig { returns(Package) }
    def source_package; end

    sig { returns(String) }
    def relative_path; end

    sig { returns(ConstantDiscovery::ConstantContext) }
    def constant; end

    sig { returns(String) }
    def source_location; end
  end

  class ConstantDiscovery::ConstantContext < ::Struct
    sig { returns(String) }
    def location; end

    sig { returns(Package) }
    def package; end
  end
end
