# Puppet profiles [![Build Status](https://github.com/cultuurnet/puppet-profiles/actions/workflows/ci.yml/badge.svg)](https://github.com/cultuurnet/puppet-profiles/actions?query=workflow%3ACI)

## Description

The profiles puppet module bundles useful, site-specific functionality in
meaningful classes that can be applied to systems.
This module is thoroughly unit tested (acceptance tests are coming), to make
inevitable larger refactoring less painful.

Profile classes can be arbitrarily nested, and this is highly recommended, to
prevent them from becoming large conglomerates of resources.
