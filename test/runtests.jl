using NextStride
using Test

@testset "NextStride.jl" begin
    @test next_stride(Array{Float32,0}(undef)) == 1

    for shape in [(3,), (3,5), (3,5,7), (3,5,7,11)]
        @testset "$(shape)" begin
            n = length(shape)
            len = prod(shape)

            a = reshape(Vector(1:len), shape)
            @test next_stride(a) == len

            # identity permutation
            p = PermutedDimsArray(a, ntuple(identity, n))
            @test next_stride(p) == len

            v = view(p, ntuple(Returns(:), n)...)
            @test next_stride(v) == len

            # reverse permutation
            p = PermutedDimsArray(a, (n+1) .- ntuple(identity, n))
            @test next_stride(p) == len

            v = view(p, ntuple(Returns(:), n)...)
            @test next_stride(v) == len
        end
    end

    @testset "permuted and strided" begin
        a = zeros(3,5,7)
        p = PermutedDimsArray(a, (2,3,1))
        v = @view p[:, 7:-2:1, 3:-1:1]
        @test next_stride(a) == 3*5*7
        @test next_stride(p) == 3*5*7
        @test next_stride(v) == 3*5*7
        v = @view p[:, 6:-1:1, 3:-1:1]
        @test next_stride(v) == 3*5*6
    end
end
