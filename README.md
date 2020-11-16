# AlignedArrays.jl

[![Build Status](https://github.com/analytech-solutions/AlignedArrays.jl/workflows/CI/badge.svg)](https://github.com/analytech-solutions/AlignedArrays.jl/actions)

Array wrappers for working with aligned memory allocations suitable for efficient GPU and RDMA transfers.


# Usage

AlignedArrays.jl is still in early development, and currently only works for Linux systems.
Basic usage follows that of standard Array, Vector, Matrix types, but with the added parameter depicting the alignment of the array's memory.
Use `AlignedArray`, `AlignedVector`, or `AlignedMatrix` to specify memory alignment as a type parameter.
We provide  `PageAlignedArray`, `PageAlignedVector`, and `PageAlignedMatrix` for convenience when allocations using the system's page-alignment is desired.

```jl
julia> using AlignedArrays

julia> x = Vector{Int32}(undef, 5)
5-element Array{Int32,1}:
 1897413280
      32662
 1826880912
      32662
 1730212208

julia> y = PageAlignedVector{Int32}(undef, 5)
5-element Array{Int32,1}:
 0
 0
 0
 0
 0

julia> z = AlignedVector{Int32, 1024}(undef, 5)
5-element Array{Int32,1}:
 -1
 -1
 -1
 -1
 -1

julia> typeof(y)
AlignedArray{Int32,1,4096}

julia> typeof(z)
AlignedArray{Int32,1,1024}

julia> pointer(x)
Ptr{Int32} @0x00007f966a213850

julia> pointer(y)
Ptr{Int32} @0x00000000029cf000

julia> pointer(z)
Ptr{Int32} @0x00000000029fd800

julia> y .= x
5-element Array{Int32,1}:
 1897413280
      32662
 1826880912
      32662
 1730212208

julia> for i in y
           println(i)
       end
1897413280
32662
1826880912
32662
1730212208

```

