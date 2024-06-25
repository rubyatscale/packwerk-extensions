# packwerk-extensions

`packwerk-extensions` is a home for checker extensions for [packwerk](https://github.com/Shopify/packwerk) 3.

Currently, it ships the following checkers to help improve the boundaries between packages. These checkers are:
- A `privacy` checker that ensures other packages are using your package's public API
- A `visibility` checker that allows packages to be private except to an explicit group of other packages.
- A `folder_privacy` checker that allows packages to their sibling packs and parent pack (to be used in an application that uses folder packs)
- A `layer` (formerly `architecture`) checker that allows packages to specify their "layer" and requires that each layer only communicate with layers below it.

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
  - packwerk/folder_privacy/checker
  - packwerk/layer/checker
```

## Privacy Checker
The privacy checker extension was originally extracted from [packwerk](https://github.com/Shopify/packwerk).

A package's privacy boundary is violated when there is a reference to the package's private constants from a source outside the package.

To enforce privacy for your package, set `enforce_privacy` to `true` or `strict` on your pack:

```yaml
# components/merchandising/package.yml
enforce_privacy: true
```

Setting `enforce_privacy` to `true` will make all references to private constants in your package a violation.

Setting `enforce_privacy` to `strict` will forbid all references to private constants in your package. **This includes violations that have been added to other packages' `package_todo.yml` files.**

Note: You will need to remove all existing privacy violations before setting `enforce_privacy` to `strict`.

### Using public folders
You may enforce privacy either way mentioned above and still expose a public API for your package by placing constants in the public folder, which by default is `app/public`. The constants in the public folder will be made available for use by the rest of the application.

### Defining your own public folder

You may prefer to override the default public folder, you can do so on a per-package basis by defining a `public_path`.

Example:

```yaml
public_path: my/custom/path/
```

### Defining public constants through sigil

> [!WARNING]
> This way of of defining the public API of a package should be considered WIP. It is not supported by all tooling in the RubyAtScale ecosystem, as @alexevanczuk pointed out in a [comment on the PR](https://github.com/rubyatscale/packwerk-extensions/pull/35#discussion_r1334331797):
>
> There are a couple of other places that will require changes related to this sigil. Namely, everything that is coupled to the public folder implementation of privacy.
>
> In the rubyatscale org:
>
> * pack_stats, example https://github.com/rubyatscale/pack_stats/blob/main/lib/pack_stats/private/metrics/public_usage.rb. (IMO though we can just remove this metric – it has never been useful)
> * Other places that mention public_path or app/public.
>   * Org wide search for app/public link
>   * Org wide search for public_path link
>   * packs (the Rust port of packwerk – I could take this one over unless someone is interested in implementing whatever we come up with there



You may make individual files public within a private package by usage of a comment within the first 5 lines of the `.rb` file containing `pack_public: true`.

Example:

```ruby
# pack_public: true
module Foo
  class Update
  end
end
```
Now `Foo::Update` is considered public even though the `foo` package might be set to `enforce_privacy: (true || strict)`.

It's important to note that when combining `public_api: true` with the declaration of `private_constants`,
`packwerk validate` will raise an exception if both are used for the same constant. This must be resolved by removing
the sigil from the `.rb` file or removing the constant from the list of `private_constants`.

If you are using rubocop, it may be configured in such a way that there must be an empty line after the magic keywords at the top of the file. Currently, this extension is not modifying rubocop in any way so it does not recognize `pack_public: true` as a valid magic keyword option. That means placing it at the end of the magic keywords will throw a rubocop exception. However, you can place it first in the list to avoid an exception in rubocop.
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
end => Less than ideal. This won't raise an issue in rubocop, however, only the first 5 lines are scanned for the magic comment of pack_public so there is risk at it being missed. It also is requiring extra empty lines in the group of magic comments.

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

### Ignore strict mode for violation coming from specific path patterns
If you want to activate `'strict'` mode on your package but have a few privacy violations you know you will deal with later,
you can set a list of patterns to exclude.

```yaml
enforce_privacy: strict
strict_privacy_ignored_patterns:
- engines/another_engine/test/**/*
```

In this example, violations on constants of your engine referenced in those files `engines/another_engine/test/**/*` will not fail Packwerk checks.

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
The visibility checker can be used to allow a package to be a private implementation detail of other packages.

To enforce visibility for your package, set `enforce_visibility` to `true` on your pack and specify `visible_to` for other packages that can use your package.

```yaml
# components/merchandising/package.yml
enforce_visibility: true
visible_to:
  - components/other_package
```

## Folder-Visibility Checker
The folder privacy checker can be used to allow a package to be private to their sibling packs and parent packs and will create todos if used by any other package.

To enforce folder privacy for your package, set `enforce_folder_privacy` to `true` on your pack.

```yaml
# components/merchandising/package.yml
enforce_folder_privacy: true
```

Here is an example of paths and whether their use of `packs/b/packs/e` is OK or not, assuming that protects itself via `enforce_folder_privacy`

```
.                         OK (parent of parent)
packs/a                   VIOLATION
packs/b                   OK (parent)
packs/b/packs/d           OK (sibling)
packs/b/packs/e           ENFORCE_NESTED_VISIBILITY: TRUE
packs/b/packs/e/packs/f   VIOLATION
packs/b/packs/e/packs/g   VIOLATION
packs/b/packs/h           OK (sibling)
packs/c                   VIOLATION
```

## Layer Checker
The layer checker can be used to enforce constraints on what can depend on what.

To enforce layers for your package, first define the `layers` in `packwerk.yml`, for example:
```
layers:
  - package
  - utility
```

Then, turn on the checker in your package:
```yaml
# components/merchandising/package.yml
enforce_layers: true
layer: utility
```

Now this pack can only depend on other utility packages.

### Deprecated Architecture Checker
The "Layer Checker" was formerly named "Architecture Checker". The associated keys were:
- packwerk.yml `architecture_layers`, which is now `layers`
- package.yml `enforce_architecture`, which is now `enforce_layers`
- package.yml `layer` is still a valid key
- package_todo.yml - `architecture`, which is now `layer`

```bash
  # script to migrate code from deprecated "architecture" violations to "layer" violations
  # sed and ripgrep required

  # replace 'architecture_layers' with 'layers' in packwerk.yml
  sed -i '' 's/architecture_layers/layers/g' ./packwerk.yml

  # replace 'enforce_architecture' with 'enforce_layers' in package.yml files
  `rg -l 'enforce_architecture' -g 'package.yml' | xargs sed -i '' 's,enforce_architecture,enforce_layers,g'`

  # replace '- architecture' with '- layer' in package_todo.yml files
  `rg -l 'architecture' -g 'package_todo.yml' | xargs sed -i '' 's/- architecture/- layer/g'`
```


## Contributing

Got another checker you would like to add? Add it to this repo!

Please ensure these commands pass for you locally:

```
bundle
srb tc
bin/rubocop
bin/rake test
```

Then, submit a PR!
