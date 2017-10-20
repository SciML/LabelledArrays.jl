using LabelledArrays, StaticArrays
using Base.Test

names = @SArray [:a,:b,:c]
values = @MArray [1,2,3]
A = LMArray(names,values)

@test A[1] == A[:a]
@test A[2] == A[:b]
@test A[3] == A[:c]

c = @LMVector Float64 [a,b,c]
d = @LMVector Float64 [:a,:b,:c] [1,2,3]

@test d[:a] == 1
@test d[:b] == 2
@test d[:c] == 3
@test d[1] == d[:a]
@test d[2] == d[:b]
@test d[3] == d[:c]

@test typeof(d) <: LabelledArrays.LMArray{Tuple{3},Int64,1,3}
c.+d
c.=2d
@test c == [2,4,6]
