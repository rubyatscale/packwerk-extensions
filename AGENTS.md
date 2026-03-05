# AGENTS.md

This file provides guidance to AI coding agents when working with code in this repository.

## What this project is

`packwerk-extensions` provides checker extensions for [packwerk](https://github.com/Shopify/packwerk) 3, a gradual modularization platform for Ruby. It ships `privacy`, `visibility`, `folder_privacy`, and `layer` checkers that enforce boundaries between packages.

## Commands

```bash
bundle install

# Run all tests (minitest)
bundle exec rake test

# Run a single test file
bundle exec ruby -Ilib -Itest test/path/to/test.rb

# Lint
bundle exec rubocop
bundle exec rubocop -a  # auto-correct

# Type checking (Sorbet)
bundle exec srb tc
```

## Architecture

- `lib/packwerk/` — checker implementations, each as a class that implements the packwerk checker interface
- `test/` — minitest tests; `test/fixtures/` holds sample Rails app structures used in tests
- Each checker (e.g. `privacy.rb`, `visibility.rb`, `layer_checker.rb`) reads `package.yml` metadata and decides whether a reference crosses a boundary
