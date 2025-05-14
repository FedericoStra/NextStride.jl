module NextStride

export next_stride

# Marking items with `public` requires `VERSION >= v"1.11"`.
# We can do so if we elevate the minimum supported Julia version.
#
# public virtual_strides_return_error
# public virtual_strides_return_zero
# public virtual_strides_return_next_stride
# public virtual_strides_call_next_stride
# public set_virtual_strides_behavior
# public VirtualStridesBehavior


"""
    next_stride(A::AbstractArray) :: Integer

Return the length (in elements, not bytes) of the shortest contiguous memory region accessed by `A`.

This is the smallest positive stride which, if assigned to the first virtual axis beyond `ndims(A)`, would prevent overlap between successive arrays of the same type of `A`.

For example, if `ndims(A) == 2`, we could have an array `B` with `ndims(B) == 3` such that
`A == B[:,:,1]`; `next_stride(A)` is the smallest positive `stride(B, 3)` that guarantees that
`B[:,:,1]` and `B[:,:,2]` do not overlap in memory.

# Examples

```jldoctest
julia> a = zeros(3,5,7);

julia> p = PermutedDimsArray(a, (2,3,1));

julia> v = view(p, :, 7:-2:1, 3:-1:1);

julia> next_stride(a), next_stride(p), next_stride(v)
(105, 105, 105)
```
"""
function next_stride end

# We want `next_stride` to be as flexible as possible, so we do not check the types
# returned by `size(A)` and `strides(A)`.
#
# Here we are relying on the assumption `all(size(A) .> 0)`,
# otherwise we should put `size(A) .- 1.` inside `abs.()`.
@inline next_stride(A::AbstractArray)::Integer = sum((size(A) .- 1) .* abs.(strides(A)); init=1)


"""
    virtual_strides_return_error()

Set the behavior of [`stride(A::AbstractArray, k::Integer)`](@extref Base.stride)
to return an error if `k > ndims(A)`.
"""
function virtual_strides_return_error()
    @eval function Base.stride(A::AbstractArray{T,N}, k::Integer)::Integer where {T,N}
        st = strides(A) :: NTuple{N,Integer}
        if 1 <= k && k <= N
            return st[k]
        else
            error("array strides: dimension must be positive")
        end
    end
end


"""
    virtual_strides_return_zero

Set the behavior of [`stride(A::AbstractArray, k::Integer)`](@extref Base.stride)
to return `0` if `k > ndims(A)`.
"""
function virtual_strides_return_zero()
    @eval function Base.stride(A::AbstractArray{T,N}, k::Integer)::Integer where {T,N}
        st = strides(A) :: NTuple{N,Integer}
        if 1 <= k && k <= N
            return st[k]
        else
            return 0
        end
    end
end


"""
    virtual_strides_return_next_stride

Set the behavior of [`stride(A::AbstractArray, k::Integer)`](@extref Base.stride)
to return the "next stride" if `k > ndims(A)`.
"""
function virtual_strides_return_next_stride()
    @eval function Base.stride(A::AbstractArray{T,N}, k::Integer)::Integer where {T,N}
        st = strides(A) :: NTuple{N,Integer}
        if 1 <= k && k <= N
            return st[k]
        else
            sz = size(A) :: NTuple{N,Integer}
            return sum((sz .- 1) .* abs.(st); init=1)
        end
    end
end


"""
    virtual_strides_call_next_stride

Set the behavior of [`stride(A::AbstractArray, k::Integer)`](@extref Base.stride)
to call [`next_stride(A)`](@ref) if `k > ndims(A)`.
"""
function virtual_strides_call_next_stride()
    @eval function Base.stride(A::AbstractArray{T,N}, k::Integer)::Integer where {T,N}
        st = strides(A) :: NTuple{N,Integer}
        if 1 <= k && k <= N
            return st[k]
        else
            return next_stride(A)
        end
    end
end


"""
    VirtualStridesBehavior <: Enum

# Instances

- `ReturnError`
- `ReturnZero`
- `ReturnNextStride`
- `Call_next_stride`

# Usage

Instances of this enumeration are passed to the function
[`set_virtual_strides_behavior`](@ref) to configure the behavior of
[`stride(A::AbstractArray, k::Integer)`](@extref Base.stride)
for `k > ndims(A)` according to this specification:

- `ReturnError`: returns an error;
- `ReturnZero`: returns `0` (use with caution!);
- `ReturnNextStride`: returns the "next stride" of `A`;
- `Call_next_stride`: calls [`next_stride(A)`](@ref).
"""
@enum VirtualStridesBehavior begin
    ReturnError
    ReturnZero
    ReturnNextStride
    Call_next_stride
end


"""
    set_virtual_strides_behavior(B::VirtualStridesBehavior)

Set the behavior of [`stride(A::AbstractArray, k::Integer)`](@extref Base.stride)
for `k > ndims(A)` according to the specification `B`, which must be an instance
of the enumeration [`VirtualStridesBehavior`](@ref).
"""
function set_virtual_strides_behavior(B::VirtualStridesBehavior)
    @eval function Base.stride(A::AbstractArray{T,N}, k::Integer)::Integer where {T,N}
        st = strides(A) :: NTuple{N,Integer}
        if 1 <= k && k <= N
            return st[k]
        else
            $(
                if B == ReturnError
                    :(error("array strides: dimension must be positive"))
                elseif B == ReturnZero
                    :(return 0)
                elseif B == ReturnNextStride
                    quote
                        sz = size(A) :: NTuple{N,Integer}
                        # Here we are implicitly assuming that `all(sz .> 0)`,
                        # otherwise we should put `sz .- 1` inside `abs.()`.
                        return sum((sz .- 1) .* abs.(st); init=1)
                    end
                elseif B == Call_next_stride
                    :(return next_stride(A))
                else
                    error("unsupported VirtualStridesBehavior")
                end
            )
        end
    end
end


function __init__()
    # Redefine this method.
    #
    # <https://github.com/JuliaLang/julia/blob/v1.11.5/base/abstractarray.jl#L594-L604>
    #
    # ```julia
    # function stride(A::AbstractArray, k::Integer)
    #     st = strides(A)
    #     k ≤ ndims(A) && return st[k]
    #     ndims(A) == 0 && return 1
    #     sz = size(A)
    #     s = st[1] * sz[1]
    #     for i in 2:ndims(A)
    #         s += st[i] * sz[i]
    #     end
    #     return s  # == sum(size(A) .* strides(A))
    # end
    # ```
    #
    # `@eval` is needed because we are inside `__init__()`.
    @eval function Base.stride(A::AbstractArray{T,N}, k::Integer)::Integer where {T,N}
        # Both `size(A)` and `strides(A)` are documented to return a tuple;
        # it is not specified whether the elements should be `Int`,
        # so we relax it to be just `Integer` in the type assertions below.
        st = strides(A) :: NTuple{N,Integer}
        if k < 1
            error("array strides: dimension must be positive")
        elseif k <= N
            return st[k]
        else
            sz = size(A) :: NTuple{N,Integer}
            # Here we are implicitly assuming that `all(sz .> 0)`,
            # otherwise we should put `sz .- 1` inside `abs.()`.
            return sum((sz .- 1) .* abs.(st); init=1)
        end
    end

    # Delete the following methods.
    #
    # <https://github.com/JuliaLang/julia/blob/v1.11.5/base/reinterpretarray.jl#L196-L197>
    #
    # ```julia
    # stride(A::Union{DenseArray,StridedReshapedArray,StridedReinterpretArray}, k::Integer) =
    #     k ≤ ndims(A) ? strides(A)[k] : length(A)
    # ```
    #
    # <https://github.com/JuliaLang/julia/blob/v1.11.5/base/subarray.jl#L430>
    #
    # ```julia
    # stride(V::SubArray, d::Integer) = d <= ndims(V) ? strides(V)[d] : strides(V)[end] * size(V)[end]
    # ```

    for A in (Union{DenseArray,Base.StridedReshapedArray,Base.StridedReinterpretArray}, SubArray)
        m = methods(stride, Tuple{A, Integer})[1]
        if m.module != Base
            error("the method\n$(m)\nis not defined in module `Base`.")
        elseif m.sig != Tuple{typeof(stride), A, Integer}
            error("the method\n$(m)\ndoes not have the expected signature.")
        else
            Base.delete_method(m)
        end
    end
end # __init__()


end # module NextStride
