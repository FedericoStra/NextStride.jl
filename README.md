# NextStride

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://FedericoStra.github.io/NextStride.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://FedericoStra.github.io/NextStride.jl/dev/)
[![Build Status](https://github.com/FedericoStra/NextStride.jl/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/FedericoStra/NextStride.jl/actions/workflows/CI.yml?query=branch%3Amaster)
[![Coverage](https://codecov.io/gh/FedericoStra/NextStride.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/FedericoStra/NextStride.jl)
![Lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)
[![ColPrac: Contributor's Guide on Collaborative Practices for Community Packages](https://img.shields.io/badge/ColPrac-Contributor's%20Guide-blueviolet)](https://github.com/SciML/ColPrac)

Control the value returned by `stride(A, i)` when `i ∉ 1:ndims(A)`.
