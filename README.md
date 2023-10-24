# packwerk-extensions

`packwerk-extensions` is a home for checker extensions for [packwerk](https://github.com/Shopify/packwerk) 3.

Currently, it ships the following checkers to help improve the boundaries between packages. These checkers are:
- A `privacy` checker that ensures other packages are using your package's public API
- A `visibility` checker that allows packages to be private except to an explicit group of other packages.
- An experimental `architecture` checker that allows packages to specify their "layer" and requires that each layer only communicate with layers below it.

## Installation

Add `packwerk-extensions` to your `Gemfile`.

To register all checkers included in this gem, add the following to your `packwerk.yml`:

```yaml
require:
  - packwerk-extensions
```

Alternatively, you can require individual checkers:

```yaml
require:
  - packwerk/privacy/checker
  - packwerk/visibility/checker
  - packwerk/architecture/checker
```

## Privacy Checker
The privacy checker extension was originally extracted from [packwerk](https://github.com/Shopify/packwerk).

A package's privacy boundary is violated when there is a reference to the package's private constants from a source outside the package.

To enforce privacy for your package, set `enforce_privacy` to `true` on your pack:

```yaml
# components/merchandising/package.yml
enforce_privacy: true
```

Setting `enforce_privacy` to true will make all references to private constants in your package a violation.

### Using public folders
You may enforce privacy either way mentioned above and still expose a public API for your package by placing constants in the public folder, which by default is `app/public`. The constants in the public folder will be made available for use by the rest of the application.

### Defining your own public folder

You may prefer to override the default public folder, you can do so on a per-package basis by defining a `public_path`.

Example:

```yaml
public_path: my/custom/path/
```

### Defining public constants through sigil
You may make individual files public withhin a private package by usage of a comment within the first 5 lines of the `.rb` file containing `pack_public: true`.

Example:

```ruby
# pack_public: true
module Foo
  class Update
  end
end
```
Now `Foo::Update` is considered public even though the `foo` package might be set to `enforce_private: (true || :strict)`.

It's important to note that when combining `public_api: true` with the declaration of `private_constants`,
`packwerk validate` will raise an exception if both are used for the same constant. This must be resolved by removing
the sigil from the `.rb` file or removing the constant from the list of `private_constants`.

If you are using rubocop, it may be configured in such a way that there must be an empty line after the magic keywords at the top of the file. Currently, this extension is not modifying rubocop in anyway so it does not recognize `public_pack: true` as a valid magic keyword option. That means placing it at the end of the magic keywords will throw a rubocop exception. However, you can place it first in the list to avoid an exception in rubocop.
```
-----
# typed: ignore
# frozen_string_literal: true
# pack_public: true

class Foo
...
end => Layout/EmptyLineAfterMagicComment: Add an empty line after magic comments.

------
# typed: ignore
# frozen_string_literal: true

# pack_public: true

class Foo
...
end => Less than ideal. This won't raise an issue in rubocop, however, only the first 5 lines are scanned for the magic comment of public_pack so there is risk at it being missed. It also is requiring extra empty lines in the group of magic comments.

-----
# pack_public: true
# typed: ignore
# frozen_string_literal: true

class Foo
...
end => Ideal solution. No exceptions from rubocop and very low risk of the magic comment being out of range since
```

### Using specific private constants
Sometimes it is desirable to only enforce privacy on a subset of constants in a package. You can do so by defining a `private_constants` list in your package.yml. Note that `enforce_privacy` must be set to `true` or `'strict'` for this to work.

### Package Privacy violation
Packwerk thinks something is a privacy violation if you're referencing a constant, class, or module defined in the private implementation (i.e. not the public folder) of another package. We care about these because we want to make sure we only use parts of a package that have been exposed as public API.

#### Interpreting Privacy violation

> /Users/JaneDoe/src/github.com/sample-project/user/app/controllers/labels_controller.rb:170:30
> Privacy violation: '::Billing::CarrierInvoiceTransaction' is private to 'billing' but referenced from 'user'.
> Is there a public entrypoint in 'billing/app/public/' that you can use instead?
>
> Inference details: 'Billing::CarrierInvoiceTransaction' refers to ::Billing::CarrierInvoiceTransaction which seems to be defined in billing/app/models/billing/carrier_invoice_transaction.rb.

There has been a privacy violation of the package `billing` in the package `user`, through the use of the constant `Billing::CarrierInvoiceTransaction` in the file `user/app/controllers/labels_controller.rb`.

#### Suggestions
You may be accessing the implementation of a piece of functionality that is supposed to be accessed through a public interface on the package. Try to use the public interface instead. A package’s public interface should be defined in its `app/public` folder and documented.

The functionality you’re looking for may not be intended to be reused across packages at all. If there is no public interface for it but you have a good reason to use it from outside of its package, find the people responsible for the package and discuss a solution with them.

## Visibility Checker
The visibility checker can be used to allow a package to be private implementation detail of other packages.

To enforce visibility for your package, set `enforce_visibility` to `true` on your pack and specify `visible_to` for other packages that can use your package.

```yaml
# components/merchandising/package.yml
enforce_visibility: true
visible_to:
  - components/other_package
```

## Architecture Checker
The architecture checker can be used to enforce constraints on what can depend on what.

To enforce architecture for your package, first define the `architecture_layers` in `packwerk.yml`, for example:
```
architecture_layers:
  - package
  - utility
```

Then, turn on the checker in your package:
```yaml
# components/merchandising/package.yml
enforce_architecture: true
layer: utility
```

Now this pack can only depend on other utility packages.
