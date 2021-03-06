# This file is part of TaylorSeries.jl, MIT licensed
#

using TaylorSeries
using Compat

if VERSION < v"0.7.0-DEV.2004"
    using Base.Test
    eeuler = Base.e
else
    using Test
    using LinearAlgebra
    eeuler = Base.MathConstants.e
end

@testset "Tests for HomogeneousPolynomial and TaylorN" begin
    @test HomogeneousPolynomial <: AbstractSeries
    @test HomogeneousPolynomial{Int} <: AbstractSeries{Int}
    @test TaylorN{Float64} <: AbstractSeries{Float64}

    _taylorNparams = TaylorSeries.ParamsTaylorN(6, 2, String["x₁", "x₂"])
    @test _taylorNparams.order == get_order()
    @test _taylorNparams.num_vars == get_numvars()
    @test _taylorNparams.variable_names == get_variable_names()
    @test _taylorNparams.variable_symbols == get_variable_symbols()

    @test eltype(set_variables(Int, "x", numvars=2, order=6)) == TaylorN{Int}
    @test eltype(set_variables("x", numvars=2, order=6)) == TaylorN{Float64}
    @test eltype(set_variables(BigInt, "x y", order=6)) == TaylorN{BigInt}
    @test eltype(set_variables("x y", order=6)) == TaylorN{Float64}
    @test eltype(set_variables(Int, :x, numvars=2, order=6)) == TaylorN{Int}
    @test eltype(set_variables(:x, numvars=2, order=6)) == TaylorN{Float64}
    @test eltype(set_variables(BigInt, [:x,:y], order=6)) == TaylorN{BigInt}
    @test eltype(set_variables([:x,:y], order=6)) == TaylorN{Float64}
    @test @compat typeof(show_params_TaylorN()) == Nothing
    @test @compat typeof(show_monomials(2)) == Nothing

    @test TaylorSeries.coeff_table[2][1] == [1,0]
    @test TaylorSeries.index_table[2][1] == 7
    @test TaylorSeries.in_base(get_order(),[2,1]) == 15
    @test TaylorSeries.pos_table[4][15] == 2

    @test get_order() == 6
    @test get_numvars() == 2

    @test get_variables()[1].order == get_order()
    @test get_variables(order=2)[1].order == 2
    @test get_variables(order=3)[1] == TaylorN(1,order=3)

    x, y = set_variables("x y", order=6)
    @test x.order == 6
    @test TaylorSeries.set_variable_names(["x","y"]) == nothing
    @test TaylorSeries._params_TaylorN_.variable_names == ["x","y"]
    @test TaylorSeries._params_TaylorN_.variable_symbols == [:x, :y]
    @test get_variable_symbols() == [:x, :y]
    @test TaylorSeries.lookupvar(:x) == 1
    @test TaylorSeries.lookupvar(:α) == 0
    @test TaylorSeries.get_variable_names() == ["x", "y"]
    @test x == HomogeneousPolynomial(Float64, 1)
    @test x == HomogeneousPolynomial(1)
    @test y == HomogeneousPolynomial(Float64, 2)
    @test y == HomogeneousPolynomial(2)
    @test !isnan(x)

    set_variables("x", numvars=2, order=17)
    v = [1,2]
    @test @compat typeof(TaylorSeries.resize_coeffsHP!(v,2)) == Nothing
    @test v == [1,2,0]
    @test_throws AssertionError TaylorSeries.resize_coeffsHP!(v,1)
    HomogeneousPolynomial(v)[3] = 3
    @test v == [1,2,3]
    HomogeneousPolynomial(v)[1:3] = 3
    @test v == [3,3,3]

    xH = HomogeneousPolynomial([1,0])
    yH = HomogeneousPolynomial([0,1],1)
    @test HomogeneousPolynomial(0,0)  == 0
    xT = TaylorN(xH, 17)
    yT = TaylorN(Int64, 2, order=17)
    zeroT = zero( TaylorN([xH],1) )
    @test zeroT.coeffs == zeros(HomogeneousPolynomial{Int}, 1)
    @test length(zeros(HomogeneousPolynomial{Int}, 1)) == 2
    @test one(HomogeneousPolynomial(1,1)) == HomogeneousPolynomial([1,1])
    uT = one(convert(TaylorN{Float64},yT))
    @test uT == one(HomogeneousPolynomial)
    @test zeroT[0] == HomogeneousPolynomial(0, 0)
    @test uT[0] == HomogeneousPolynomial(1, 0)
    @test ones(xH,1) == [1, xH+yH]
    @test typeof(ones(xH,2)) == Array{HomogeneousPolynomial{Int},1}
    @test length(ones(xH,2)) == 3
    @test ones(HomogeneousPolynomial{Complex{Int}},0) ==
        [HomogeneousPolynomial([complex(1,0)], 0)]
    @test !isnan(uT)
    @test TaylorSeries.fixorder(xH,yH) == (xH,yH)
    @test_throws AssertionError TaylorSeries.fixorder(zeros(xH,0)[1],yH)

    @test get_order(zeroT) == 1
    @test xT[1][1] == 1
    @test yH[2] == 1
    @test getcoeff(xT,(1,0)) == getcoeff(xT,[1,0]) == 1
    @test getcoeff(yH,(1,0)) == getcoeff(yH,[1,0]) == 0
    @test typeof(convert(HomogeneousPolynomial,1im)) ==
        HomogeneousPolynomial{Complex{Int}}
    @test convert(HomogeneousPolynomial,1im) ==
        HomogeneousPolynomial([complex(0,1)], 0)
    @test convert(HomogeneousPolynomial{Int64},[1,1]) == xH+yH
    @test convert(HomogeneousPolynomial{Float64},[2,-1]) == 2.0xH-yH
    @test typeof(convert(TaylorN,1im)) == TaylorN{Complex{Int}}
    @test convert(TaylorN, 1im) ==
        TaylorN([HomogeneousPolynomial([complex(0,1)], 0)], 0)
    @test convert(TaylorN{Float64}, yH) == 1.0*yT
    @test convert(TaylorN{Float64}, [xH,yH]) == xT+1.0*yT
    @test convert(TaylorN{Int}, [xH,yH]) == xT+yT
    @test promote(xH, [1,1])[2] == xH+yH
    @test promote(xH, yT)[1] == xT
    @test promote(xT, [xH,yH])[2] == xT+yT
    @test typeof(promote(im*xT,[xH,yH])[2]) == TaylorN{Complex{Int64}}
    # @test TaylorSeries.fixorder(TaylorN(1, order=1),17) == xT
    @test iszero(zeroT.coeffs)
    @test iszero(zero(xH))
    @test !iszero(uT)
    @test iszero(zeroT)

    @test eltype(xH) == Int
    @test length(xH) == 2
    @test zero(xH) == 0*xH
    @test one(yH) == xH+yH
    @test xH * true == xH
    @test false * yH == zero(yH)
    @test get_order(yH) == 1
    @test get_order(xT) == 17
    @test xT * true == xT
    @test false * yT == zero(yT)
    @test HomogeneousPolynomial([1.0])*xH == xH

    @test xT == TaylorN([xH])
    @test one(xT) == TaylorN(1,5)
    @test TaylorN(uT) == convert(TaylorN{Complex},1)
    @test get_numvars() == 2
    @test length(uT) == get_order()+1
    @test eltype(convert(TaylorN{Complex{Float64}},1)) == Complex{Float64}

    @test 1+xT+yT == TaylorN(1,1) + TaylorN([xH,yH],1)
    @test xT-yT-1 == TaylorN([-1,xH-yH])
    @test xT*yT == TaylorN([HomogeneousPolynomial([0,1,0],2)])
    @test (1/(1-xT))[3] == HomogeneousPolynomial([1.0],3)
    @test xH^20 == HomogeneousPolynomial([0], get_order())
    @test (yT/(1-xT))[4] == xH^3 * yH
    @test mod(1+xT,1) == +xT
    @test (rem(1+xT,1))[0] == 0
    @test mod(1+xT,1.0) == +xT
    @test (rem(1+xT,1.0))[0] == 0
    @test abs(1-xT)  == 1-xT
    @test abs(-1-xT)  == 1+xT
    @test derivative(yH,1) == derivative(xH, :x₂)
    @test derivative(mod2pi(2pi+yT^3),2) == derivative(yT^3, :x₂)
    @test derivative(yT^3, :x₂) == derivative(yT^3, (0,1))
    @test derivative(yT) == zeroT == derivative(yT, (1,0))
    @test derivative((0,1), yT) == 1
    @test -xT/3im == im*xT/3
    @test (xH/3im)' == im*xH/3
    @test xT/BigInt(3) == TaylorN(BigFloat,1)/3
    @test xT/complex(0,BigInt(3)) == -im*xT/BigInt(3)
    @test (xH/complex(0,BigInt(3)))' ==
        im*HomogeneousPolynomial([BigInt(1),0])/3
    @test evaluate(xH) == zero(eltype(xH))
    @test xH() == zero(eltype(xH))
    @test xH([1,1]) == evaluate(xH, [1,1])
    @test xH((1,1)) == 1
    hp = -5.4xH+6.89yH
    @test hp([1,1]) == evaluate(hp, [1,1])
    vr = rand(2)
    @test hp(vr) == evaluate(hp, vr)

    @test integrate(yH,1) == integrate(xH, :x₂)
    p = (xT-yT)^6
    @test integrate(derivative(p, 1), 1, yT^6) == p
    @test integrate(derivative(p, :x₁), :x₁, yT^6) == p
    @test derivative(integrate(p, 2), 2) == p
    @test derivative(integrate(p, :x₂), :x₂) == p
    @test derivative(TaylorN(1.0, get_order())) == TaylorN(0.0, get_order())
    @test integrate(TaylorN(6.0, get_order()), 1) == 6xT
    @test integrate(TaylorN(0.0, get_order()), 2) == TaylorN(0.0, get_order())
    @test integrate(TaylorN(0.0, get_order()), 2, xT) == xT
    @test integrate(TaylorN(0.0, get_order()), :x₂, xT) == xT
    @test integrate(xT^17, 2) == TaylorN(0.0, get_order())
    @test integrate(xT^17, 1, yT) == yT
    @test integrate(xT^17, 1, 2.0) == TaylorN(2.0, get_order())
    @test integrate(xT^17, :x₁, 2.0) == TaylorN(2.0, get_order())
    @test_throws AssertionError integrate(xT, 1, xT)
    @test_throws AssertionError integrate(xT, :x₁, xT)
    @test_throws AssertionError derivative(xT, (1,))
    @test_throws AssertionError derivative(xT, (1,2,3))
    @test_throws AssertionError derivative(xT, (-1,2))
    @test_throws AssertionError derivative((1,), xT)
    @test_throws AssertionError derivative((1,2,3), xT)
    @test_throws AssertionError derivative((-1,2), xT)


    @test derivative(2xT*yT^2, (8,8)) == 0
    @test derivative((8,8), 2xT*yT^2) == 0
    @test derivative(2xT*yT^2, 1) == 2yT^2
    @test derivative((1,0), 2xT*yT^2) == 0
    @test derivative(2xT*yT^2, (1,2)) == 4*one(yT)
    @test derivative((1,2), 2xT*yT^2) == 4
    @test xT*xT^3 == xT^4
    txy = 1.0 + xT*yT - 0.5*xT^2*yT + (1/3)*xT^3*yT + 0.5*xT^2*yT^2
    @test getindex((1+TaylorN(1))^TaylorN(2),0:4) == txy.coeffs[1:5]
    @test ( (1+TaylorN(1))^TaylorN(2) )[:] == ( (1+TaylorN(1))^TaylorN(2) ).coeffs[:]
    @test txy.coeffs[:] == txy[:]
    @test txy.coeffs[:] == txy[0:end]
    txy[:] .= ( -1.0 + 3xT*yT - xT^2*yT + (4/3)*xT^3*yT + (1/3)*xT*yT^3 + 0.5*xT^2*yT^2 + 0.5*xT*yT^3 )[:]
    @test txy[:] == ( -1.0 + 3xT*yT - xT^2*yT + (4/3)*xT^3*yT + (1/3)*xT*yT^3 + 0.5*xT^2*yT^2 + 0.5*xT*yT^3 )[:]
    txy[2:end-1] .= ( 1.0 - xT*yT + 0.5*xT^2*yT - (2/3)*xT*yT^3 - 0.5*xT^2*yT^2  + 7*xT^3*yT )[2:end-1]
    @test txy[2:end-1] == ( 1.0 - xT*yT + 0.5*xT^2*yT - (2/3)*xT*yT^3 - 0.5*xT^2*yT^2  + 7*xT^3*yT )[2:end-1]

    a = -5.0 + sin(xT+yT^2)
    b = deepcopy(a)
    @test a[:] == a[0:end]
    @test a[:] == b[:]
    @test a[1:end] == b[1:end]
    @test a[end][:] == b[end][:]
    @test a[end][1:end] == b[end][1:end]
    a[end][:] .= rand.()
    rv = a[end][:]
    @test a[end][:] == rv
    @test a[end][:] != b[end][:]
    a[end][1:end] .= rand.()
    rv = a[end][1:end]
    @test a[end][1:end] == rv
    @test a[end][1:end] != b[end][1:end]

    hp = HomogeneousPolynomial(1)^8
    rv1 = rand( length(hp) )
    hp[:] = rv1
    @test rv1 == hp[:]
    rv2 = rand( length(hp)-2 )
    hp[1:end-2] = rv2
    @test hp[1:end-2] == rv2
    @test hp[end-1:end] == rv1[end-1:end]
    hp[3:4] = 0.0
    @test hp[1:2] == rv2[1:2]
    @test hp[3:4] == zeros(2)
    @test hp[5:end-2] == rv2[5:end]
    @test hp[end-1:end] == rv1[end-1:end]
    hp[:] = 0.0
    @test hp[:] == zero(rv1)

    pol = sin(xT+yT*xT)+yT^2-(1-xT)^3
    q = deepcopy(pol)
    q[:] = 0.0
    @test get_order.(q[:]) == collect(0:q.order)
    @test q[:] == zero(q[:])
    q[:] = pol.coeffs
    @test q == pol
    @test q[:] == pol[:]
    q[2:end-1] = 0.0
    @test q[2:end-1] == zero.(q[2:end-1])
    @test q[1] == pol[1]
    @test q[end] == pol[end]
    # q[:] = pol.coeffs
    # zH0 = zero(HomogeneousPolynomial{Float64})
    q[:] = 1.0
    @test q[1] == HomogeneousPolynomial([1,0])
    @test q[2] == HomogeneousPolynomial([1,0,0])
    q[:] = pol.coeffs
    q[2:end-1] = one.(q[2:end-1])
    @test q[2:end-1] == one.(q[2:end-1])
    @test q[2] == HomogeneousPolynomial([1,1,1])
    @test q[1] == pol[1]
    @test q[end] == pol[end]
    q[:] = pol.coeffs
    zHall = zeros(HomogeneousPolynomial{Float64}, q.order)
    q[:] = zHall
    @test q[:] == zHall
    q[:] = pol.coeffs
    q[1:end-1] .= zHall[2:end-1]
    @test q[1:end-1] == zHall[2:end-1]
    q[:] = pol.coeffs
    @test q[:] != zeros(q.order+1)
    q[:] = zeros(q.order+1)
    @test q[:] == zeros(q.order+1)
    q[:] = pol.coeffs
    q[1:end-1] = zeros(q.order+1)[2:end-1]
    @test q != pol
    @test q[:] != pol[:]
    @test q[1:end-1] == zeros(q.order+1)[2:end-1]
    @test q[0] == pol[0]
    @test q[end] == pol[end]
    q[:] = pol.coeffs
    pol2 = cos(sin(xT)-yT^3*xT)-3yT^2+sqrt(1-xT)
    q[2:end-2] .= pol2.coeffs[3:end-2]
    @test q[0:1] == pol[0:1]
    @test q[2:end-2] == pol2[2:end-2]
    @test q[end-1:end] == pol[end-1:end]


    if VERSION < v"0.7.0-DEV"
        @test_throws DomainError yT^(-2)
    else
        @test_throws AssertionError yT^(-2)
    end
    @test_throws AssertionError yT^(-2.0)
    @test (1+xT)^(3//2) == ((1+xT)^0.5)^3
    @test real(xH) == xH
    @test imag(xH) == zero(xH)
    @test conj(im*yH) == (im*yH)'
    @test conj(im*yT) == (im*yT)'
    @test real( exp(1im * xT)) == cos(xT)
    @test getcoeff(convert(TaylorN{Rational{Int}},cos(xT)),(4,0)) ==
        1//factorial(4)
    cr = convert(TaylorN{Rational{Int}},cos(xT))
    @test getcoeff(cr,(4,0)) == 1//factorial(4)
    @test imag((exp(yT))^(-1im)') == sin(yT)
    exy = exp( xT+yT )
    @test evaluate(exy) == 1
    @test evaluate(exy, 0.1im, 0.01im) == exp(0.11im)
    @test exy(0.1im, 0.01im) == exp(0.11im)
    @test evaluate(exy,(0.1im, 0.01im)) == exp(0.11im)
    @test exy((0.1im, 0.01im)) == exp(0.11im)
    @test evaluate(exy,[0.1im, 0.01im]) == exp(0.11im)
    @test exy([0.1im, 0.01im]) == exp(0.11im)
    @test isapprox(evaluate(exy, (1,1)), eeuler^2)
    @test exy(:x₁, 0.0) == exp(yT)
    txy = tan(xT+yT)
    @test getcoeff(txy,(8,7)) == 929569/99225
    ptxy = xT + yT + (1/3)*( xT^3 + yT^3 ) + xT^2*yT + xT*yT^2
    @test getindex(tan(TaylorN(1)+TaylorN(2)),0:4) == ptxy.coeffs[1:5]
    @test evaluate(xH*yH, 1.0, 2.0) == (xH*yH)(1.0, 2.0) == 2.0
    @test evaluate(xH*yH, (1.0, 2.0)) == 2.0
    @test evaluate(xH*yH, [1.0, 2.0]) == 2.0
    @test ptxy(:x₁, -1.0) == -1 + yT + (-1.0+yT^3)/3 + yT - yT^2
    @test ptxy(:x₁ => -1.0) == -1 + yT + (-1.0+yT^3)/3 + yT - yT^2
    @test evaluate(ptxy, :x₁ => -1.0) == -1 + yT + (-1.0+yT^3)/3 + yT - yT^2
    @test evaluate(ptxy, :x₁, -1.0) == -1 + yT + (-1.0+yT^3)/3 + yT - yT^2
    v = zeros(Int, 2)
    @test evaluate!([xT, yT], ones(Int, 2), v) == nothing
    @test v == ones(2)
    A_TN = [xT 2xT 3xT; yT 2yT 3yT]
    @test evaluate(A_TN, ones(2)) == [1.0 2.0 3.0; 1.0 2.0 3.0]
    @test evaluate(A_TN) == [0.0 0.0 0.0; 0.0 0.0 0.0]
    @test A_TN() == [0.0  0.0  0.0; 0.0  0.0  0.0]
    @test (view(A_TN,:,:))() == [0.0 0.0 0.0; 0.0 0.0 0.0]
    t = Taylor1(10)
    @test A_TN([t,t^2]) == [t 2t 3t; t^2 2t^2 3t^2]
    @test view(A_TN, :, :)(ones(2)) == A_TN(ones(2))
    @test view(A_TN, :, 1)(ones(2)) == A_TN[:,1](ones(2))

    @test evaluate(sin(asin(xT+yT)), [1.0,0.5]) == 1.5
    @test evaluate(asin(sin(xT+yT)), [1.0,0.5]) == 1.5
    @test tan(atan(xT+yT)) == xT+yT
    @test atan(tan(xT+yT)) == xT+yT
    @test asin(xT+yT) + acos(xT+yT) == pi/2

    @test -sinh(xT+yT) + cosh(xT+yT) == exp(-(xT+yT))
    @test  sinh(xT+yT) + cosh(xT+yT) == exp(xT+yT)
    @test evaluate(- sinh(xT+yT)^2 + cosh(xT+yT)^2 , rand(2)) == 1
    @test evaluate(- sinh(xT+yT)^2 + cosh(xT+yT)^2 , zeros(2)) == 1
    @test tanh(xT + yT + 0im) == -1im * tan((xT+yT)*1im)
    @test cosh(xT+yT) == real(cos(im*(xT+yT)))
    @test sinh(xT+yT) == imag(sin(im*(xT+yT)))

    xx = 1.0*zeroT
    TaylorSeries.add!(xx, 1.0*xT, 2yT, 1)
    @test xx[1] == HomogeneousPolynomial([1,2])
    TaylorSeries.add!(xx, 5.0, 0)
    @test xx[0] == HomogeneousPolynomial([5.0])
    TaylorSeries.add!(xx, -5.0, 1)
    @test xx[1] == zero(xx[1])
    TaylorSeries.subst!(xx, 1.0*xT, yT, 1)
    @test xx[1] == HomogeneousPolynomial([1,-1])
    TaylorSeries.subst!(xx, 5.0, 0)
    @test xx[0] == HomogeneousPolynomial([-5.0])
    TaylorSeries.subst!(xx, -5.0, 1)
    @test xx[1] == zero(xx[end])
    TaylorSeries.div!(xx, 1.0+xT, 1.0+xT, 0)
    @test xx[0] == HomogeneousPolynomial([1.0])
    TaylorSeries.pow!(xx, 1.0+xT, 0.5, 1)
    @test xx[1] == HomogeneousPolynomial([0.5,0.0])
    xx = 1.0*zeroT
    TaylorSeries.pow!(xx, 1.0+xT, 1.5, 0)
    @test xx[0] == HomogeneousPolynomial([1.0])
    TaylorSeries.pow!(xx, 1.0+xT, 1.5, 1)
    @test xx[1] == HomogeneousPolynomial([1.5,0.0])
    xx = 1.0*zeroT
    TaylorSeries.pow!(xx, 1.0+xT, 0, 0)
    @test xx[0] == HomogeneousPolynomial([1.0])
    TaylorSeries.pow!(xx, 1.0+xT, 1, 1)
    @test xx[1] == HomogeneousPolynomial([1.0,0.0])
    xx = 1.0*zeroT
    TaylorSeries.pow!(xx, 1.0+xT, 2, 0)
    @test xx[0] == HomogeneousPolynomial([1.0])
    TaylorSeries.pow!(xx, 1.0+xT, 2, 1)
    @test xx[1] == HomogeneousPolynomial([2.0,0.0])
    xx = 1.0*zeroT
    TaylorSeries.sqrt!(xx, 1.0+xT, 0)
    TaylorSeries.sqrt!(xx, 1.0+xT, 1)
    @test xx[0] == 1.0
    @test xx[1] == HomogeneousPolynomial([0.5,0.0])
    xx = 1.0*zeroT
    TaylorSeries.exp!(xx, 1.0*xT, 0)
    TaylorSeries.exp!(xx, 1.0*xT, 1)
    @test xx[0] == 1.0
    @test xx[1] == HomogeneousPolynomial([1.0,0.0])
    xx = 1.0*zeroT
    TaylorSeries.log!(xx, 1.0+xT, 0)
    TaylorSeries.log!(xx, 1.0+xT, 1)
    @test xx[0] == 0.0
    @test xx[1] == HomogeneousPolynomial(1.0,1)
    xx = 1.0*zeroT
    cxx = zero(xx)
    TaylorSeries.sincos!(xx, cxx, 1.0*xT, 0)
    TaylorSeries.sincos!(xx, cxx, 1.0*xT, 1)
    @test xx[0] == 0.0
    @test xx[1] == HomogeneousPolynomial(1.0,1)
    @test cxx[0] == 1.0
    @test cxx[1] == HomogeneousPolynomial(0.0,1)
    xx = 1.0*zeroT
    cxx = zero(xx)
    TaylorSeries.tan!(xx, 1.0*xT, cxx, 0)
    TaylorSeries.tan!(xx, 1.0*xT, cxx, 1)
    @test xx[0] == 0.0
    @test xx[1] == HomogeneousPolynomial(1.0,1)
    @test cxx[0] == 0.0
    @test cxx[1] == HomogeneousPolynomial(0.0,1)
    xx = 1.0*zeroT
    cxx = zero(xx)
    TaylorSeries.asin!(xx, 1.0*xT, cxx, 0)
    TaylorSeries.asin!(xx, 1.0*xT, cxx, 1)
    @test xx[0] == 0.0
    @test xx[1] == HomogeneousPolynomial(1.0,1)
    @test cxx[0] == 1.0
    @test cxx[1] == HomogeneousPolynomial(0.0,1)
    xx = 1.0*zeroT
    cxx = zero(xx)
    TaylorSeries.acos!(xx, 1.0*xT, cxx, 0)
    TaylorSeries.acos!(xx, 1.0*xT, cxx, 1)
    @test xx[0] == acos(0.0)
    @test xx[1] == HomogeneousPolynomial(-1.0,1)
    @test cxx[0] == 1.0
    @test cxx[1] == HomogeneousPolynomial(0.0,1)
    xx = 1.0*zeroT
    cxx = zero(xx)
    TaylorSeries.atan!(xx, 1.0*xT, cxx, 0)
    TaylorSeries.atan!(xx, 1.0*xT, cxx, 1)
    @test xx[0] == 0.0
    @test xx[1] == HomogeneousPolynomial(1.0,1)
    @test cxx[0] == 1.0
    @test cxx[1] == HomogeneousPolynomial(0.0,1)
    xx = 1.0*zeroT
    cxx = zero(xx)
    TaylorSeries.sinhcosh!(xx, cxx, 1.0*xT, 0)
    TaylorSeries.sinhcosh!(xx, cxx, 1.0*xT, 1)
    @test xx[0] == 0.0
    @test xx[1] == HomogeneousPolynomial(1.0,1)
    @test cxx[0] == 1.0
    @test cxx[1] == HomogeneousPolynomial(0.0,1)
    xx = 1.0*zeroT
    cxx = zero(xx)
    TaylorSeries.tanh!(xx, 1.0*xT, cxx, 0)
    TaylorSeries.tanh!(xx, 1.0*xT, cxx, 1)
    @test xx[0] == 0.0
    @test xx[1] == HomogeneousPolynomial(1.0,1)
    @test cxx[0] == 0.0
    @test cxx[1] == HomogeneousPolynomial(0.0,1)

    g1(x, y) = x^3 + 3y^2 - 2x^2 * y - 7x + 2
    g2(x, y) = y + x^2 - x^4
    f1 = g1(xT, yT)
    f2 = g2(xT, yT)
    @test gradient(f1) == [ 3*xT^2-4*xT*yT-TaylorN(7,0), 6*yT-2*xT^2 ]
    @test ∇(f2) == [2*xT - 4*xT^3, TaylorN(1,0)]
    @test jacobian([f1,f2], [2,1]) == jacobian( [g1(xT+2,yT+1), g2(xT+2,yT+1)] )
    @compat jac = Array{Int64}(undef, 2, 2)
    jacobian!(jac, [g1(xT+2,yT+1), g2(xT+2,yT+1)])
    @test jac == jacobian( [g1(xT+2,yT+1), g2(xT+2,yT+1)] )
    jacobian!(jac, [f1,f2], [2,1])
    @test jac == jacobian([f1,f2], [2,1])
    @test hessian( f1*f2 ) ==
        [derivative((2,0), f1*f2) derivative((1,1), (f1*f2));
         derivative((1,1), f1*f2) derivative((0,2), (f1*f2))] == [4 -7; -7 0]
    @test hessian( f1*f2, [xT, yT] ) ==
        [derivative(f1*f2, (2,0)) derivative((f1*f2), (1,1));
         derivative(f1*f2, (1,1)) derivative((f1*f2), (0,2))]
    @test [xT yT]*hessian(f1*f2)*[xT, yT] == [ 2*TaylorN((f1*f2)[2]) ]
    @test hessian(f1^2)/2 == [ [49,0] [0,12] ]
    @test hessian(f1-f2-2*f1*f2) == (hessian(f1-f2-2*f1*f2))'
    @test hessian(f1-f2,[1,-1]) == hessian(g1(xT+1,yT-1)-g2(xT+1,yT-1))
    @compat hes = Array{Int64}(undef, 2, 2)
    hessian!(hes, f1*f2)
    @test hes == hessian(f1*f2)
    @test [xT yT]*hes*[xT, yT] == [ 2*TaylorN((f1*f2)[2]) ]
    hessian!(hes, f1^2)
    @test hes/2 == [ [49,0] [0,12] ]
    hessian!(hes, f1-f2-2*f1*f2)
    @test hes == hes'
    @compat hes1 = Array{Int64}(undef, 2, 2)
    hessian!(hes1, f1-f2,[1,-1])
    hessian!(hes, g1(xT+1,yT-1)-g2(xT+1,yT-1))
    @test hes1 == hes

    displayBigO(false)
    @test string(-xH) == " - 1 x₁"
    @test string(xT^2) == " 1 x₁²"
    @test string(1im*yT) == " ( 1 im ) x₂"
    @test string(xT-im*yT) == "  ( 1 ) x₁ - ( 1 im ) x₂"
    displayBigO(true)
    @test string(-xH) == " - 1 x₁"
    @test string(xT^2) == " 1 x₁² + 𝒪(‖x‖¹⁸)"
    @test string(1im*yT) == " ( 1 im ) x₂ + 𝒪(‖x‖¹⁸)"
    @test string(xT-im*yT) == "  ( 1 ) x₁ - ( 1 im ) x₂ + 𝒪(‖x‖¹⁸)"

    @test_throws ArgumentError abs(xT)
    @test_throws AssertionError 1/x
    @test_throws AssertionError zero(x)/zero(x)
    @test_throws ArgumentError sqrt(x)
    @test_throws AssertionError x^(-2)
    @test_throws ArgumentError log(x)
    @test_throws AssertionError cos(x)/sin(y)
    @test_throws BoundsError xH[20]
    @test_throws BoundsError xT[20]

    a = 3x + 4y +6x^2 + 8x*y
    @test typeof( norm(x) ) == Float64
    @test norm(x) > 0
    @test norm(a) == norm([3,4,6,8.0])
    @test norm(a, 4) == sum([3,4,6,8.0].^4)^(1/4.)
    @test norm(a, Inf) == 8.0
    @test norm((3.0 + 4im)*x) == abs(3.0 + 4im)

    @test TaylorSeries.rtoldefault(TaylorN{Int64}) == 0
    @test TaylorSeries.rtoldefault(TaylorN{Float64}) == sqrt(eps(Float64))
    @test TaylorSeries.rtoldefault(TaylorN{BigFloat}) == sqrt(eps(BigFloat))
    @test TaylorSeries.real(TaylorN{Float64}) == TaylorN{Float64}
    @test TaylorSeries.real(TaylorN{Complex{Float64}}) == TaylorN{Float64}
    @test isfinite(a)
    @test a[0] ≈ a[0]
    @test a[1] ≈ a[1]
    @test a[2] ≈ a[2]
    @test a[3] ≈ a[3]
    @test a ≈ a
    @test a .≈ a
    b = deepcopy(a)
    b[2][3] = Inf
    @test !isfinite(b)
    b[2][3] = NaN
    @test !isfinite(b)
    b[2][3] = a[2][3]+eps()
    @test isapprox(a[2], b[2], rtol=eps())
    @test a ≈ b
    b[2][2] = a[2][2]+sqrt(eps())
    @test a[2] ≈ b[2]
    @test a ≈ b

    f11(a,b) = (a+b)^a - cos(a*b)*b
    f22(a) = (a[1] + a[2])^a[1] - cos(a[1]*a[2])*a[2]
    @test taylor_expand(f11, 1.0,2.0) == taylor_expand(f22, [1,2.0])
    @test evaluate(taylor_expand(x->x[1] + x[2], [1,2])) == 3.0
    f33(x,y) = 3x+y
    @test eltype(taylor_expand(f33,1,1)) == eltype(1)
    x,y = get_variables()
    xysq = x^2 + y^2
    update!(xysq,[1.0,-2.0])
    @test xysq == (x+1.0)^2 + (y-2.0)^2
    update!(xysq,[-1.0,2.0])
    @test xysq == x^2 + y^2

    #test function-like behavior for TaylorN
    @test exy() == 1
    @test exy([0.1im,0.01im]) == exp(0.11im)
    @test isapprox(exy([1,1]), eeuler^2)
    @test sin(asin(xT+yT))([1.0,0.5]) == 1.5
    @test asin(sin(xT+yT))([1.0,0.5]) == 1.5
    @test ( -sinh(xT+yT)^2 + cosh(xT+yT)^2 )(rand(2)) == 1
    @test ( -sinh(xT+yT)^2 + cosh(xT+yT)^2 )(zeros(2)) == 1
    #number of variables changed to 4...
    dx = set_variables("x", numvars=4, order=10)
    P = sin.(dx)
    v = [1.0,2,3,4]
    for i in 1:4
        @test P[i](v) == evaluate(P[i], v)
    end
    @test P.(fill(v, 4)) == fill(P(v), 4)
    F(x) = [sin(sin(x[4]+x[3])), sin(cos(x[3]-x[2])), cos(sin(x[1]^2+x[2]^2)), cos(cos(x[2]*x[3]))]
    Q = F(v+dx)
    @test Q.( fill(v, 4) ) == fill(Q(v), 4)
    vr = map(x->rand(4), 1:4)
    @test Q.(vr) == map(x->Q(x), vr)
    for i in 1:4
        @test P[i]() == evaluate(P[i])
        @test Q[i]() == evaluate(Q[i])
    end
    @test P() == evaluate.(P)
    @test P() == evaluate(P)
    @test Q() == evaluate.(Q)
    @test Q() == evaluate(Q)
    @test Q[1:3]() == evaluate(Q[1:3])

    dx = set_variables("x", numvars=4, order=10)
    for i in 1:4
        @test deg2rad(180+dx[i]) == pi + deg2rad(1.0)dx[i]
        @test rad2deg(pi+dx[i]) == 180.0+rad2deg(1.0)dx[i]
    end
    p = sin(exp(dx[1]*dx[2])+dx[3]*dx[2])/(1.0+dx[4]^2)
    q = zero(p)
    TaylorSeries.deg2rad!(q, p, 0)
    @test q[0] == p[0]*(pi/180)
    TaylorSeries.deg2rad!.(q, p, [1,3,5])
    for i in [0,1,3,5]
        @test q[i] == p[i]*(pi/180)
    end
    TaylorSeries.rad2deg!(q, p, 0)
    @test q[0] == p[0]*(180/pi)
    TaylorSeries.rad2deg!.(q, p, [1,3,5])
    for i in [0,1,3,5]
        @test q[i] == p[i]*(180/pi)
    end
    xT = 5+TaylorN(Int64, 1, order=10)
    yT = TaylorN(2, order=10)
    TaylorSeries.deg2rad!(yT, xT, 0)
    @test yT[0] == xT[0]*(pi/180)
    TaylorSeries.rad2deg!(yT, xT, 0)
    @test yT[0] == xT[0]*(180/pi)
end

@testset "Integrate for several variables" begin

    t, x, y = set_variables("t x y")

    @test integrate(t, 1) == 0.5*t^2
    @test integrate(t, 2) == t * x
    @test integrate(t, 3) == t * y
    @test integrate(x, 1) == t * x
    @test integrate(x, 2) == 0.5*x^2
    @test integrate(y, 2) == x * y

end
