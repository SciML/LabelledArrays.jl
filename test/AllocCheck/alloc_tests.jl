using LabelledArrays
using AllocCheck
using Test
using StaticArrays

@testset "AllocCheck - Zero Allocation Tests" begin
    @testset "SLArray (Static) Zero Allocations" begin
        sv = SLVector(a = 1.0, b = 2.0, c = 3.0)
        sm = (@SLArray (2, 2) (:a, :b, :c, :d))(1.0, 2.0, 3.0, 4.0)

        # Property access should be allocation-free
        @check_allocs function test_slarray_property_a(
                arr::SLArray{Tuple{3}, Float64, 1, 3, (:a, :b, :c)}
            )
            arr.a
        end
        @test test_slarray_property_a(sv) == 1.0

        # Integer indexing should be allocation-free
        @check_allocs function test_slarray_getindex_int(
                arr::SLArray{Tuple{3}, Float64, 1, 3, (:a, :b, :c)}, i::Int
            )
            arr[i]
        end
        @test test_slarray_getindex_int(sv, 1) == 1.0
        @test test_slarray_getindex_int(sv, 2) == 2.0
        @test test_slarray_getindex_int(sv, 3) == 3.0

        # Val-based symbol access should be allocation-free
        @check_allocs function test_slarray_getindex_val(
                arr::SLArray{Tuple{3}, Float64, 1, 3, (:a, :b, :c)}
            )
            getindex(arr, Val(:a))
        end
        @test test_slarray_getindex_val(sv) == 1.0

        # Broadcasting between SLArrays should be allocation-free
        sv2 = SLVector(a = 4.0, b = 5.0, c = 6.0)
        @check_allocs function test_slarray_broadcast_add(
                arr1::SLArray{Tuple{3}, Float64, 1, 3, (:a, :b, :c)},
                arr2::SLArray{Tuple{3}, Float64, 1, 3, (:a, :b, :c)}
            )
            arr1 .+ arr2
        end
        result = test_slarray_broadcast_add(sv, sv2)
        @test result.a == 5.0
        @test result.b == 7.0
        @test result.c == 9.0

        # Scalar broadcasting should be allocation-free
        @check_allocs function test_slarray_broadcast_scalar(
                arr::SLArray{Tuple{3}, Float64, 1, 3, (:a, :b, :c)}, x::Float64
            )
            arr .* x
        end
        result = test_slarray_broadcast_scalar(sv, 2.0)
        @test result.a == 2.0
        @test result.b == 4.0
        @test result.c == 6.0

        # NamedTuple conversion should be allocation-free
        @check_allocs function test_slarray_namedtuple(
                arr::SLArray{Tuple{3}, Float64, 1, 3, (:a, :b, :c)}
            )
            convert(NamedTuple, arr)
        end
        nt = test_slarray_namedtuple(sv)
        @test nt == (a = 1.0, b = 2.0, c = 3.0)

        # copy should be allocation-free for SLArray
        @check_allocs function test_slarray_copy(
                arr::SLArray{Tuple{3}, Float64, 1, 3, (:a, :b, :c)}
            )
            copy(arr)
        end
        @test test_slarray_copy(sv) == sv

        # symbols function should be allocation-free
        @check_allocs function test_slarray_symbols(
                arr::SLArray{Tuple{3}, Float64, 1, 3, (:a, :b, :c)}
            )
            symbols(arr)
        end
        @test test_slarray_symbols(sv) == (:a, :b, :c)

        # 2D SLArray property access should be allocation-free
        @check_allocs function test_slarray_2d_property(
                arr::SLArray{Tuple{2, 2}, Float64, 2, 4, (:a, :b, :c, :d)}
            )
            arr.c
        end
        @test test_slarray_2d_property(sm) == 3.0
    end

    @testset "LArray (Mutable) Zero Allocations" begin
        lv = LVector(a = 1.0, b = 2.0, c = 3.0)
        lm = @LArray Float64 (2, 2) (:a, :b, :c, :d)
        lm .= reshape([1.0, 2.0, 3.0, 4.0], 2, 2)

        # Property access should be allocation-free
        @check_allocs function test_larray_property_a(
                arr::LArray{Float64, 1, Vector{Float64}, (:a, :b, :c)}
            )
            arr.a
        end
        @test test_larray_property_a(lv) == 1.0

        # Integer indexing should be allocation-free
        @check_allocs function test_larray_getindex_int(
                arr::LArray{Float64, 1, Vector{Float64}, (:a, :b, :c)}, i::Int
            )
            arr[i]
        end
        @test test_larray_getindex_int(lv, 1) == 1.0
        @test test_larray_getindex_int(lv, 2) == 2.0
        @test test_larray_getindex_int(lv, 3) == 3.0

        # Val-based symbol access should be allocation-free
        @check_allocs function test_larray_getindex_val(
                arr::LArray{Float64, 1, Vector{Float64}, (:a, :b, :c)}
            )
            getindex(arr, Val(:a))
        end
        @test test_larray_getindex_val(lv) == 1.0

        # Property write should be allocation-free
        @check_allocs function test_larray_setproperty(
                arr::LArray{Float64, 1, Vector{Float64}, (:a, :b, :c)}, val::Float64
            )
            arr.a = val
        end
        test_larray_setproperty(lv, 10.0)
        @test lv.a == 10.0
        lv.a = 1.0  # Reset

        # Integer setindex should be allocation-free
        @check_allocs function test_larray_setindex_int(
                arr::LArray{Float64, 1, Vector{Float64}, (:a, :b, :c)}, val::Float64, i::Int
            )
            arr[i] = val
        end
        test_larray_setindex_int(lv, 20.0, 1)
        @test lv[1] == 20.0
        lv[1] = 1.0  # Reset

        # Note: In-place broadcasting (dest .= src .+ 1.0) shows 0 allocations
        # with @btime but AllocCheck detects internal broadcasting machinery allocations.
        # This is a limitation of Julia's broadcast implementation, not LabelledArrays.

        # copyto! should be allocation-free
        lv_dest2 = LVector(a = 0.0, b = 0.0, c = 0.0)
        @check_allocs function test_larray_copyto!(
                dest::LArray{Float64, 1, Vector{Float64}, (:a, :b, :c)},
                src::LArray{Float64, 1, Vector{Float64}, (:a, :b, :c)}
            )
            copyto!(dest, src)
        end
        test_larray_copyto!(lv_dest2, lv)
        @test lv_dest2 == lv

        # NamedTuple conversion should be allocation-free
        @check_allocs function test_larray_namedtuple(
                arr::LArray{Float64, 1, Vector{Float64}, (:a, :b, :c)}
            )
            convert(NamedTuple, arr)
        end
        nt = test_larray_namedtuple(lv)
        @test nt == (a = 1.0, b = 2.0, c = 3.0)

        # symbols function should be allocation-free
        @check_allocs function test_larray_symbols(
                arr::LArray{Float64, 1, Vector{Float64}, (:a, :b, :c)}
            )
            symbols(arr)
        end
        @test test_larray_symbols(lv) == (:a, :b, :c)

        # 2D LArray property access should be allocation-free
        @check_allocs function test_larray_2d_property(
                arr::LArray{Float64, 2, Matrix{Float64}, (:a, :b, :c, :d)}
            )
            arr.c
        end
        @test test_larray_2d_property(lm) == 3.0

        # size should be allocation-free
        @check_allocs function test_larray_size(
                arr::LArray{Float64, 1, Vector{Float64}, (:a, :b, :c)}
            )
            size(arr)
        end
        @test test_larray_size(lv) == (3,)
    end

    @testset "Range-Based Labels Zero Allocations" begin
        # Range-based label access returns views which should be allocation-free
        lv_range = @LArray [1.0, 2.0, 3.0, 4.0, 5.0, 6.0] (x = 1:3, y = 4:6)

        # Note: Range-based property access returns a view, which should be allocation-free
        @check_allocs function test_range_property(
                arr::LArray{Float64, 1, Vector{Float64}, (x = 1:3, y = 4:6)}
            )
            arr.x
        end
        v = test_range_property(lv_range)
        @test v == [1.0, 2.0, 3.0]
    end
end
