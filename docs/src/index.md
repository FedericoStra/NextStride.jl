```@meta
CurrentModule = NextStride
```

# NextStride

Documentation for [FedericoStra/NextStride.jl](https://github.com/FedericoStra/NextStride.jl).

!!! note

    This is an *experimental* project to work around the issue
    <https://github.com/JuliaLang/julia/issues/58403>.

    It redefines methods in the [`Base`](@extref ) module and may not be safe
    for space travel.

By default, the [`stride(A, k::Integer)`](@extref Base.stride) function comes with three methods,
which differ in behavior when `k > ndims(A)`, specialized for arrays `A` of type:

1. `AbstractArray`: this version returns the value `sum(strides(A) .* size(A))`;
2. `SubArray`: this version returns the value `strides(A)[end] * size(A)[end]`;
3. `Union{DenseArray,Base.StridedReshapedArray,Base.StridedReinterpretArray}`:
   this version returns the value `length(A)`.

Loading this package removes specializations (2)−(3) and leaves only the following:

```jldoctest; filter = r"@ NextStride (.*)" => s"@ NextStride <source file>"
julia> methods(stride)
# 1 method for generic function "stride" from Base:
 [1] stride(A::AbstractArray{T, N}, k::Integer) where {T, N}
     @ NextStride <source file>
```

This new method is standardized in the following way:

- if `k < 1`, then it returns an error;
- if `1 ≤ k ≤ ndims(A)`, then it returns [`strides(A)[k]`](@extref Base.strides);
- if `k > ndims(A)`, then it returns the length (in elements, not bytes)
  of the shortest contiguous memory region accessed by `A`.

The integer returned in the third case is called *next stride* and can also be
computed directly via the function [`next_stride(A)`](@ref).

---

For example, we have

```jldoctest
julia> using NextStride

julia> a = zeros(3,5,7);

julia> p = PermutedDimsArray(a, (2,3,1));

julia> v = view(p, :, 7:-2:1, 3:-1:1);

julia> stride(a, 4), stride(p, 4), stride(v, 4)
(105, 105, 105)
```

whereas this code would return `(105, 123, -3)` without loading [`NextStride`](@ref).

### Configuring the behavior

The behavior of [`stride(A::AbstractArray, k::Integer)`](@extref Base.stride)
for `k > ndims(A)` can be configured by calling the function
[`set_virtual_strides_behavior(B::VirtualStridesBehavior)`](@ref)
with one of the following instances of the enumeration [`VirtualStridesBehavior`](@ref):

1. `ReturnError`: returns an error;
2. `ReturnZero`: returns `0` (use with caution!);
3. `ReturnNextStride`: returns the "next stride" of `A`;
4. `Call_next_stride`: calls [`next_stride(A)`](@ref).

Notice that with option (3) the functions [`stride`](@extref Base.stride) and
[`next_stride`](@ref) remain independent of one another (and can therefore be specialized
separately), whereas with option (4) they become coupled (adding methods to
[`next_stride`](@ref) will affect the value returned by [`stride`](@extref Base.stride)).

!!! warning
    Options (1) and especially (2) may break stuff!

Option (1) is always "safe" to use, because the worse it can do is throw an error if
some code tries to call [`stride(A::AbstractArray, k::Integer)`](@extref Base.stride)
with `k > ndims(A)`.

On the other hand, option (2) *might not be safe* because there is code in Julia's base
libraries that accidentally relies on
[`stride(A::AbstractArray, k::Integer)`](@extref Base.stride) returning a non-zero value
for `k > ndims(A)`.
One such example is [`LinearAlgebra.mul!(y, A, x)`](@extref LinearAlgebra.mul!) when
called with a vector as second argument instead of a matrix. It treats it as a 1-column
matrix and calls `stride(A, 2)` expecting a non-zero stride which is valid to pass to the
underlying [`LinearAlgebra.BLAS.gemv!`](@extref) function (BLAS `gemv` functions
explicitly require that `lda` must be positive). Setting the behavior of `stride(A, 2)` to
return `0` instead may result in code that *appears* to be working, but it is definitely
not correct.

```jldoctest
julia> using LinearAlgebra

julia> mul!(zeros(3), [1., 2., 3.], [10.])
3-element Vector{Float64}:
 10.0
 20.0
 30.0

julia> using NextStride

julia> mul!(zeros(3), [1., 2., 3.], [10.]) # no problems here
3-element Vector{Float64}:
 10.0
 20.0
 30.0

julia> NextStride.set_virtual_strides_behavior(NextStride.ReturnZero)

julia> mul!(zeros(3), [1., 2., 3.], [10.]) # still *appears* to work correctly...
3-element Vector{Float64}:
 10.0
 20.0
 30.0

julia> NextStride.set_virtual_strides_behavior(NextStride.ReturnError)

julia> mul!(zeros(3), [1., 2., 3.], [10.])
ERROR: array strides: dimension out of range
Stacktrace:
```

## API

### Index

```@index
```

### Public

#### Exported

```@autodocs
Modules = [NextStride]
Private = false
```

#### Non exported

```@autodocs
Modules = [NextStride]
Public = false
```
