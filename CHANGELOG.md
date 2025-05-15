# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com),
and this project adheres to [Semantic Versioning](https://semver.org).

<!--
Types of changes:
- `Added` for new features;
- `Changed` for changes in existing functionality;
- `Deprecated` for soon-to-be removed features;
- `Removed` for now removed features;
- `Fixed` for any bug fixes;
- `Security` in case of vulnerabilities.
-->

## [Unreleased]

## [0.2.0]

## Added

- Functions to set the behavior of `stride(A::AbstractArray, k::Integer)` for `k > ndims(A)`:
  - `virtual_strides_return_error`,
  - `virtual_strides_return_zero`,
  - `virtual_strides_return_next_stride`,
  - `virtual_strides_call_next_stride`.
- Function `set_virtual_strides_behavior(::VirtualStridesBehavior)` to set the behavior of
  `stride(A::AbstractArray, k::Integer)` for `k > ndims(A)` via an instance of
  the enumeration `VirtualStridesBehavior`.

## Changed

- Allow the package to be precompiled by moving some code into `__init__()`.

## [0.1.0]

## Added

- Function `next_stride`.
- Rectify the definition of `stride(A::AbstractArray, k::Integer)` to
  - return an error if `k < 1`,
  - return `next_stride(A)` if `k > ndims(A)`.
- Delete the methods of `stride(A, k::Integer)` specialised for
  - `Union{DenseArray,StridedReshapedArray,StridedReinterpretArray}`,
  - `SubArray`.

## [0.0.0]

Empty project.

[Unreleased]: https://github.com/FedericoStra/NextStride.jl/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/FedericoStra/NextStride.jl/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/FedericoStra/NextStride.jl/compare/v0.0.0...v0.1.0
[0.0.0]: https://github.com/FedericoStra/NextStride.jl/releases/tag/v0.0.0
