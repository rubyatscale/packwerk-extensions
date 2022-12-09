# typed: true
# frozen_string_literal: true

module FactoryHelper
  def build_reference(
    source_package: Packwerk::Package.new(name: 'components/source', config: {}),
    destination_package: Packwerk::Package.new(name: 'components/destination', config: {}),
    path: 'some/path.rb',
    constant_name: '::SomeName',
    constant_location: 'some/location.rb',
    source_location: Packwerk::Node::Location.new(2, 12)
  )
    constant = Packwerk::ConstantDiscovery::ConstantContext.new(
      constant_name,
      constant_location,
      destination_package
    )

    Packwerk::Reference.new(
      package: source_package,
      relative_path: path,
      constant: constant,
      source_location: source_location
    )
  end
end
