package js.lib;

@:native("BigInt")
private extern class NativeBigInt {}

abstract BigInt(NativeBigInt) from NativeBigInt to NativeBigInt {
    public inline function new(v:NativeBigInt)
        this = v;

    public static inline function fromInt(v:Int):BigInt
        return js.Syntax.code("BigInt({0})", v);

    public static inline function fromString(v:String):BigInt
        return js.Syntax.code("BigInt({0})", v);

    @:op(A + B) static inline function add(a:BigInt, b:BigInt):BigInt return js.Syntax.code("{0} + {1}", a, b);
    @:op(A - B) static inline function sub(a:BigInt, b:BigInt):BigInt return js.Syntax.code("{0} - {1}", a, b);
    @:op(A * B) static inline function mul(a:BigInt, b:BigInt):BigInt return js.Syntax.code("{0} * {1}", a, b);
    @:op(A / B) static inline function div(a:BigInt, b:BigInt):BigInt return js.Syntax.code("{0} / {1}", a, b);
    @:op(A % B) static inline function mod(a:BigInt, b:BigInt):BigInt return js.Syntax.code("{0} % {1}", a, b);

    @:op(A >> B) static inline function shr(a:BigInt, b:BigInt):BigInt return js.Syntax.code("{0} >> {1}", a, b);
    @:op(A << B) static inline function shl(a:BigInt, b:BigInt):BigInt return js.Syntax.code("{0} << {1}", a, b);
    @:op(A & B)  static inline function band(a:BigInt, b:BigInt):BigInt return js.Syntax.code("{0} & {1}", a, b);
    @:op(A | B)  static inline function bor(a:BigInt, b:BigInt):BigInt return js.Syntax.code("{0} | {1}", a, b);
    @:op(A ^ B)  static inline function bxor(a:BigInt, b:BigInt):BigInt return js.Syntax.code("{0} ^ {1}", a, b);
    @:op(~A)     static inline function bnot(a:BigInt):BigInt return js.Syntax.code("~{0}", a);

    @:op(A == B) static inline function eq(a:BigInt, b:BigInt):Bool  return js.Syntax.code("{0} === {1}", a, b);
    @:op(A != B) static inline function neq(a:BigInt, b:BigInt):Bool return js.Syntax.code("{0} !== {1}", a, b);
    @:op(A > B)  static inline function gt(a:BigInt, b:BigInt):Bool  return js.Syntax.code("{0} > {1}", a, b);
    @:op(A >= B) static inline function gte(a:BigInt, b:BigInt):Bool return js.Syntax.code("{0} >= {1}", a, b);
    @:op(A < B)  static inline function lt(a:BigInt, b:BigInt):Bool  return js.Syntax.code("{0} < {1}", a, b);
    @:op(A <= B) static inline function lte(a:BigInt, b:BigInt):Bool return js.Syntax.code("{0} <= {1}", a, b);

    public inline function toString():String
        return js.Syntax.code("{0}.toString()", this);

    public inline function toInt():Int
        return js.Syntax.code("Number({0})", this);

    public inline function toFloat():Float
        return js.Syntax.code("Number({0})", this);
}
