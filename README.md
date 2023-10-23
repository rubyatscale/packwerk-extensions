# packwerk-extensions

`packwerk-extensions` is a home for checker extensions for [packwerk](https://github.com/Shopify/packwerk) 3.

Currently, it ships the following checkers to help improve the boundaries between packages. These checkers are:
- A `privacy` checker that ensures other packages are using your package's public API
- A `visibility` checker that allows packages to be private except to an explicit group of other packages.
- A `folder_visibility` checker that allows packages to their sibling packs and parent pack (to be used in an application that uses folder packs)
- An `architecture` checker that allows packages to specify their "layer" and requires that each layer only communicate with layers below it.

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
  - packwerk/folder_visibility/checker
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

## Folder-Visibility Checker
The folder visibility checker can be used to allow a package to be private to their sibling packs and parent packs and will create todos if used by any other package.

To enforce visibility for your package, set `enforce_folder_visibility` to `true` on your pack.

```yaml
# components/merchandising/package.yml
enforce_folder_visibility: true
```

Here is an example of paths and whether their use of `packs/b/packs/e` is OK or not, assuming that protects itself via `enforce_folder_visibility`

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
