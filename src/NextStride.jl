# WARNING: precompilation must be disabled because otherwise we get the error
#
# ```
# [ Info: Precompiling NextStride [3731ef4a-0417-4ff6-800c-39cc403a0cfc]
# ERROR: LoadError: Method deletion is not possible during Module precompile.
# Stacktrace:
#  [...]
# ERROR: Failed to precompile NextStride [3731ef4a-0417-4ff6-800c-39cc403a0cfc]
# ```
__precompile__(false)


module NextStride

export next_stride


"""
    next_stride(A::AbstractArray)

Compute the smallest positive stride for the first virtual axis beyond `ndims(A)` that would prevent overlap.

This is the length (in elements, not bytes) of the shortest contiguous memory region accessed by `A`.
"""
function next_stride end

# We want `next_stride` to be as flexible as possible, so we do not check the types
# returned by `size(A)` and `strides(A)`.
#
# Here we are relying on the assumption `all(size(A) .> 0)`,
# otherwise we should put `size(A) .- 1.` inside `abs.()`.
@inline next_stride(A::AbstractArray) = sum((size(A) .- 1) .* abs.(strides(A)); init=1)


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
function Base.stride(A::AbstractArray{T,N}, k::Integer) where {T,N}
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


# <https://github.com/JuliaLang/julia/blob/v1.11.5/base/reinterpretarray.jl#L196-L197>
#
# ```julia
# stride(A::Union{DenseArray,StridedReshapedArray,StridedReinterpretArray}, k::Integer) =
#     k ≤ ndims(A) ? strides(A)[k] : length(A)
# ```
Base.delete_method(methods(
    stride,
    Tuple{Union{DenseArray,Base.StridedReshapedArray,Base.StridedReinterpretArray}, Integer}
)[1])


# <https://github.com/JuliaLang/julia/blob/v1.11.5/base/subarray.jl#L430>
#
# ```julia
# stride(V::SubArray, d::Integer) = d <= ndims(V) ? strides(V)[d] : strides(V)[end] * size(V)[end]
# ```
Base.delete_method(methods(
    stride,
    Tuple{SubArray, Integer}
)[1])


end # module NextStride
