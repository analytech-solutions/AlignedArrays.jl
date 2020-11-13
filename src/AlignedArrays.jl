module AlignedArrays
	import Mmap
	
	
	export AlignedArray, AlignedVector, AlignedMatrix, AlignedVecOrMat
	export PageAlignedArray, PageAlignedVector, PageAlignedMatrix, PageAlignedVecOrMat
	
	
	const PAGESIZE = Mmap.PAGESIZE
	
	
	struct AlignedArray{T, N, A} <: DenseArray{T, N}
		parent::Array{T, N}
		addr::Ref{Ptr{Cvoid}}
		
		function AlignedArray{T, N, A}(::UndefInitializer, dims::NTuple{N, Integer}) where {T, N, A}
			ispow2(A) || error("Alignment must be a power of two")
			isconcretetype(T) || error("Element type must be a concrete type")
			
			size = isempty(dims) ? 0 : reduce(*, dims)
			@static if Sys.islinux()
				addr = Ref(C_NULL)
				ccall(:posix_memalign, Cint, (Ptr{Ptr{Cvoid}}, Csize_t, Csize_t), addr, A, size) == 0 || error("Failed to allocate aligned memory")
			else
				error("Operating system not yet supported")
			end
			
			a = new{T, N, A}(unsafe_wrap(Array{T, N}, reinterpret(Ptr{T}, addr[]), dims, own = false), addr)
			finalizer(a.addr) do x
				@static if Sys.islinux()
					ccall(:free, Cvoid, (Ptr{Cvoid},), x[])
				end
			end
			return a
		end
	end
	
	AlignedArray{T, N, A}(u::UndefInitializer, dims::Integer...) where {T, N, A} = AlignedArray{T, N, A}(u, dims)
	
	const AlignedVector{T, A} = AlignedArray{T, 1, A}
	const AlignedMatrix{T, A} = AlignedArray{T, 2, A}
	const AlignedVecOrMat{T, A} = Union{AlignedVector{T, A}, AlignedMatrix{T, A}}
	
	const PageAlignedArray{T, N} = AlignedArray{T, N, PAGESIZE}
	const PageAlignedVector{T} = AlignedVector{T, PAGESIZE}
	const PageAlignedMatrix{T} = AlignedMatrix{T, PAGESIZE}
	const PageAlignedVecOrMat{T} = AlignedVecOrMat{T, PAGESIZE}
	
	
	Base.parent(a::AlignedArray) = a.parent
	
	Base.pointer(a::AlignedArray) = pointer(parent(a))
	
	Base.size(a::AlignedArray) = size(parent(a))
	Base.length(a::AlignedArray) = length(parent(a))
	Base.axes(a::AlignedArray) = axes(parent(a))
	
	Base.IndexStyle(::Type{A}) where {T, N, A<:AlignedArray{T, N}} = IndexStyle(Array{T, N})
	Base.getindex(a::AlignedArray, args...) = getindex(parent(a), args...)
	Base.setindex!(a::AlignedArray, args...) = setindex!(parent(a), args...)
	Base.iterate(a::AlignedArray, args...) = iterate(parent(a), args...)
	
	Base.similar(a::AlignedArray, args...) = similar(parent(a), args...)
	
	Base.show(io::IO, m::MIME"text/plain", a::AlignedArray) = show(io, m, parent(a))
end
