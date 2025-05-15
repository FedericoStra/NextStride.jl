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
