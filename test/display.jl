using LabelledArrays, Test

AB = @SLVector (:a, :b)
x = AB(1, 2)
@test string(x) == "[a=1, b=2]"
@test string(Float16.(x)) == "Float16[a=1.0, b=2.0]"

y = @LArray [1 2; 3 4] (:a, :b, :c, :d)
@test string(y) == "[a=1 c=2; b=3 d=4]"
@test string(Float16.(y)) == "Float16[a=1.0 c=2.0; b=3.0 d=4.0]"
