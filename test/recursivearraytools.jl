using RecursiveArrayTools, LabelledArrays, Test

ABC = @SLVector (:a, :b, :c);
A = ABC(1, 2, 3);
B = RecursiveArrayTools.DiffEqArray([A, A], [0.0, 2.0]);
@test getindex(B, :a) == [1, 1]

B_with_parameters = RecursiveArrayTools.DiffEqArray([A, A], [0.0, 2.0], (1,))
@test getindex(B_with_parameters, :b) == [2, 2]
