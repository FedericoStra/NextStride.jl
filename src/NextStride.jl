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


end # module NextStride
