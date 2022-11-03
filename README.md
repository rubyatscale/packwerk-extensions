# packwerk-extensions

`packwerk-extensions` is a home for checker extensions for packwerk.

#### Enforcing privacy boundary

The privacy checker extension was originally extracted from [packwerk](https://github.com/Shopify/packwerk).

A package's privacy boundary is violated when there is a reference to the package's private constants from a source outside the package.

There are two ways you can enforce privacy for your package:

1. Enforce privacy for all external sources

```yaml
# components/merchandising/package.yml
enforce_privacy: true  # will make everything private that is not in
                        # the components/merchandising/app/public folder
```

Setting `enforce_privacy` to true will make all references to private constants in your package a violation.

2. Enforce privacy for specific constants

```yaml
# components/merchandising/package.yml
enforce_privacy:
  - "::Merchandising::Product"
  - "::SomeNamespace"  # enforces privacy for the namespace and
                       # everything nested in it
```

It will be a privacy violation when a file outside of the `components/merchandising` package tries to reference `Merchandising::Product`.

##### Using public folders
You may enforce privacy either way mentioned above and still expose a public API for your package by placing constants in the public folder, which by default is `app/public`. The constants in the public folder will be made available for use by the rest of the application.

##### Defining your own public folder

You may prefer to override the default public folder, you can do so on a per-package basis by defining a `public_path`.

Example:

```yaml
public_path: my/custom/path/
```

### Package Privacy violation
A constant that is private to its package has been referenced from outside of the package. Constants are declared private in their package’s `package.yml`.

See: [USAGE.md - Enforcing privacy boundary](USAGE.md#Enforcing-privacy-boundary)

#### Interpreting Privacy violation

> /Users/JaneDoe/src/github.com/sample-project/user/app/controllers/labels_controller.rb:170:30
> Privacy violation: '::Billing::CarrierInvoiceTransaction' is private to 'billing' but referenced from 'user'.
> Is there a public entrypoint in 'billing/app/public/' that you can use instead?
>
> Inference details: 'Billing::CarrierInvoiceTransaction' refers to ::Billing::CarrierInvoiceTransaction which seems to be defined in billing/app/models/billing/carrier_invoice_transaction.rb.

There has been a privacy violation of the package `billing` in the package `user`, through the use of the constant `Billing::CarrierInvoiceTransaction` in the file `user/app/controllers/labels_controller.rb`.

##### Suggestions
You may be accessing the implementation of a piece of functionality that is supposed to be accessed through a public interface on the package. Try to use the public interface instead. A package’s public interface should be defined in its `app/public` folder and documented.

The functionality you’re looking for may not be intended to be reused across packages at all. If there is no public interface for it but you have a good reason to use it from outside of its package, find the people responsible for the package and discuss a solution with them.
