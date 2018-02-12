# Copyright 2018 Martin Holters
# See accompanying license file.

using Compat

if VERSION ≥ v"0.6.0"
    macro pfunction(sig, params, body)
        esc(Expr(:function, Expr(:where, sig, params.args...), body))
    end
else
    macro pfunction(sig, params, body)
        esc(Expr(:function,
                 Expr(:call, Expr(:curly, sig.args[1], params.args...),
                      sig.args[2:end]...),
                 body))
    end
end

if VERSION ≥ v"0.6.0"
    @eval macro $(:struct)(head, body)
        Expr(Meta.parse("struct Foo end").head, false, esc(head), Expr(:block, esc.(body.args)...))
    end
    macro mutable_struct(head, body)
        Expr(Meta.parse("struct Foo end").head, true, esc(head), Expr(:block, esc.(body.args)...))
    end
else
    @eval macro $(:struct)(head, body)
        Expr(:type, false, esc(head), Expr(:block, esc.(body.args)...))
    end
    macro mutable_struct(head, body)
        Expr(:type, true, esc(head), Expr(:block, esc.(body.args)...))
    end
end

if !isdefined(@__MODULE__, :copyto!) # prior to 0.7.0-DEV.3057
    global const copyto! = Base.copy!
end

if !isdefined(@__MODULE__, :findall) # prior to 0.7.0-DEV.3415
    global const findall = Base.find
end

if !isdefined(@__MODULE__, Symbol("@warn")) # prior to 0.7.0-DEV.2988
    macro warn(args...)
        :(warn($args...))
    end
end

if isdefined(Base, :NamedTuple) # 0.7.0-DEV.2738 to 0.7.0-DEV.3226
    kwargs_pairs(kwargs::NamedTuple) = pairs(kwargs)
end
kwargs_pairs(kwargs) = kwargs

for f in (:min, :max)
    argf = Symbol(:arg, f)
    if !isdefined(@__MODULE__, argf) # prior to 0.7.0-DEV.3516
        indf = Symbol(:ind, f)
        eval(@__MODULE__, quote
            $argf(x::AbstractVector) = $indf(x)
            function $argf(x::AbstractArray)
                idx = $indf(x)
                if !isa(idx, CartesianIndex)
                    return CartesianIndex(ind2sub(x, idx))
                else
                    return idx
                end
            end
        end)
    end
end

if VERSION ≥ v"0.7.0-DEV.3589"
    using Markdown # for @doc_str
end

if !isdefined(@__MODULE__, :rmul!) # prior to 0.7.0-DEV.3665
    if VERSION < v"0.7.0-DEV.3563"
        const rmul! = scale!
    else
        const rmul! = mul1!
    end
end
