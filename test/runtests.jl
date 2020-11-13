using Test: @testset, @test, @test_throws, @test_broken
using AlignedArrays


@testset "AlignedArrays" begin
	@testset "AlignedArrays" begin
		a = AlignedVector{Int, 256}(undef, 3)
		@test eltype(a) === Int
		@test length(a) === 3
		@test reinterpret(Int, pointer(a)) % 256 == 0
		
		a[1] = 1234
		@test a[1] == 1234
		a .= zeros(Int, 3)
		@test a[1] == a[2] == a[3] == 0
	end
	
	
	@testset "PageAlignedArrays" begin
		a = PageAlignedVector{Int}(undef, 3)
		@test eltype(a) === Int
		@test length(a) === 3
		@test reinterpret(Int, pointer(a)) % AlignedArrays.PAGESIZE == 0
		
		a[1] = 1234
		@test a[1] == 1234
		a .= zeros(Int, 3)
		@test a[1] == a[2] == a[3] == 0
	end
end

