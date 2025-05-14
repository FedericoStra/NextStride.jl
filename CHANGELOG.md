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

<!-- next-url -->
[0.1.0]: https://github.com/FedericoStra/NextStride.jl/compare/v0.0.0...v0.1.0
[0.0.0]: https://github.com/FedericoStra/NextStride.jl/releases/tag/v0.0.0
