package com.smartfoxserver.v3.entities.data;

#if python
abstract PlatformInt64(Int) from Int to Int {
    public inline function new(v:Int) this = v;

    // ── high / low ───────────────────────────────────────────────────────────
    public var high(get, set):Int;
    public var low(get, set):Int;

    private inline function get_high():Int return (this >> 32) & 0xFFFFFFFF;
    private inline function get_low():Int  return this & 0xFFFFFFFF;

    private inline function set_high(v:Int):Int {
        this = ((v & 0xFFFFFFFF) << 32) | (this & 0xFFFFFFFF);
        return v;
    }
    private inline function set_low(v:Int):Int {
        this = (this & (0xFFFFFFFF << 32)) | (v & 0xFFFFFFFF);
        return v;
    }

    public static inline function make(high:Int, low:Int):PlatformInt64
        return new PlatformInt64(((high & 0xFFFFFFFF) << 32) | (low & 0xFFFFFFFF));

    // ── operators ────────────────────────────────────────────────────────────
    @:op(A + B) public static inline function add(a:PlatformInt64, b:PlatformInt64):PlatformInt64 return (a : Int) + (b : Int);
    @:op(A - B) public static inline function sub(a:PlatformInt64, b:PlatformInt64):PlatformInt64 return (a : Int) - (b : Int);
    @:op(A * B) public static inline function mul(a:PlatformInt64, b:PlatformInt64):PlatformInt64 return (a : Int) * (b : Int);
    @:op(A / B) public static inline function div(a:PlatformInt64, b:PlatformInt64):PlatformInt64 return Std.int((a : Int) / (b : Int));
    @:op(A % B) public static inline function mod(a:PlatformInt64, b:PlatformInt64):PlatformInt64 return (a : Int) % (b : Int);

    @:op(A == B) public static inline function eq (a:PlatformInt64, b:PlatformInt64):Bool return (a : Int) == (b : Int);
    @:op(A != B) public static inline function neq(a:PlatformInt64, b:PlatformInt64):Bool return (a : Int) != (b : Int);
    @:op(A >  B) public static inline function gt (a:PlatformInt64, b:PlatformInt64):Bool return (a : Int) >  (b : Int);
    @:op(A >= B) public static inline function gte(a:PlatformInt64, b:PlatformInt64):Bool return (a : Int) >= (b : Int);
    @:op(A <  B) public static inline function lt (a:PlatformInt64, b:PlatformInt64):Bool return (a : Int) <  (b : Int);
    @:op(A <= B) public static inline function lte(a:PlatformInt64, b:PlatformInt64):Bool return (a : Int) <= (b : Int);

    // ── conversions ──────────────────────────────────────────────────────────
    public inline function toInt():Int       return this;
    public inline function toString():String return Std.string(this);

    public static inline function fromInt(v:Int):PlatformInt64     return new PlatformInt64(v);
    public static inline function ofString(s:String):PlatformInt64 return new PlatformInt64(Std.parseInt(s));
}

#elseif js

abstract PlatformInt64(js.lib.BigInt) from js.lib.BigInt to js.lib.BigInt {
    static final MASK32:js.lib.BigInt = js.lib.BigInt.fromString("4294967295");
    static final SHIFT32:js.lib.BigInt = js.lib.BigInt.fromInt(32);

    public inline function new(v:js.lib.BigInt) this = v;

    // ── high / low ───────────────────────────────────────────────────────────
    public var high(get, set):Int;
    public var low(get, set):Int;

    private inline function get_high():Int return ((this >> SHIFT32) & MASK32).toInt();
    private inline function get_low():Int  return (this & MASK32).toInt();

    private inline function set_high(v:Int):Int {
        this = (js.lib.BigInt.fromInt(v) << SHIFT32) | (this & MASK32);
        return v;
    }
    private inline function set_low(v:Int):Int {
        this = (this >> SHIFT32 << SHIFT32) | (js.lib.BigInt.fromInt(v) & MASK32);
        return v;
    }

    public static inline function make(high:Int, low:Int):PlatformInt64 {
        return new PlatformInt64((js.lib.BigInt.fromInt(high) << SHIFT32) | (js.lib.BigInt.fromInt(low) & MASK32));
    }

    // ── operators ────────────────────────────────────────────────────────────
    @:op(A + B) public static inline function add(a:PlatformInt64, b:PlatformInt64):PlatformInt64 return (a : js.lib.BigInt) + (b : js.lib.BigInt);
    @:op(A - B) public static inline function sub(a:PlatformInt64, b:PlatformInt64):PlatformInt64 return (a : js.lib.BigInt) - (b : js.lib.BigInt);
    @:op(A * B) public static inline function mul(a:PlatformInt64, b:PlatformInt64):PlatformInt64 return (a : js.lib.BigInt) * (b : js.lib.BigInt);
    @:op(A / B) public static inline function div(a:PlatformInt64, b:PlatformInt64):PlatformInt64 return (a : js.lib.BigInt) / (b : js.lib.BigInt);
    @:op(A % B) public static inline function mod(a:PlatformInt64, b:PlatformInt64):PlatformInt64 return (a : js.lib.BigInt) % (b : js.lib.BigInt);

    @:op(A == B) public static inline function eq (a:PlatformInt64, b:PlatformInt64):Bool return (a : js.lib.BigInt) == (b : js.lib.BigInt);
    @:op(A != B) public static inline function neq(a:PlatformInt64, b:PlatformInt64):Bool return (a : js.lib.BigInt) != (b : js.lib.BigInt);
    @:op(A >  B) public static inline function gt (a:PlatformInt64, b:PlatformInt64):Bool return (a : js.lib.BigInt) >  (b : js.lib.BigInt);
    @:op(A >= B) public static inline function gte(a:PlatformInt64, b:PlatformInt64):Bool return (a : js.lib.BigInt) >= (b : js.lib.BigInt);
    @:op(A <  B) public static inline function lt (a:PlatformInt64, b:PlatformInt64):Bool return (a : js.lib.BigInt) <  (b : js.lib.BigInt);
    @:op(A <= B) public static inline function lte(a:PlatformInt64, b:PlatformInt64):Bool return (a : js.lib.BigInt) <= (b : js.lib.BigInt);

    // ── conversions ──────────────────────────────────────────────────────────
    public inline function toInt():Int       return (this : js.lib.BigInt).toInt();
    public inline function toString():String return (this : js.lib.BigInt).toString();

    public static inline function fromInt(v:Int):PlatformInt64     return new PlatformInt64(js.lib.BigInt.fromInt(v));
    public static inline function ofString(s:String):PlatformInt64 return new PlatformInt64(js.lib.BigInt.fromString(s));
}

#else
@:access(haxe.Int64)
// jvm, cpp, hl, cs, neko — haxe.Int64 primitive long'a derlenir
abstract PlatformInt64(haxe.Int64) from haxe.Int64 to haxe.Int64 {
    public inline function new(v:haxe.Int64) this = v;

    // ── high / low ───────────────────────────────────────────────────────────
    public var high(get, set):Int;
    public var low(get, set):Int;

    private inline function get_high():Int return this.high;
    private inline function get_low():Int  return this.low;

    private inline function set_high(v:Int):Int {
        this = haxe.Int64.make(v, this.low);
        return v;
    }
    private inline function set_low(v:Int):Int {
        this = haxe.Int64.make(this.high, v);
        return v;
    }

    public static inline function make(high:Int, low:Int):PlatformInt64
    return new PlatformInt64(haxe.Int64.make(high, low));

    // ── operators ────────────────────────────────────────────────────────────
    @:op(A + B) public static inline function add(a:PlatformInt64, b:PlatformInt64):PlatformInt64 return haxe.Int64.add(a, b);
    @:op(A - B) public static inline function sub(a:PlatformInt64, b:PlatformInt64):PlatformInt64 return haxe.Int64.sub(a, b);
    @:op(A * B) public static inline function mul(a:PlatformInt64, b:PlatformInt64):PlatformInt64 return haxe.Int64.mul(a, b);
    @:op(A / B) public static inline function div(a:PlatformInt64, b:PlatformInt64):PlatformInt64 return haxe.Int64.div(a, b);
    @:op(A % B) public static inline function mod(a:PlatformInt64, b:PlatformInt64):PlatformInt64 return haxe.Int64.mod(a, b);

    @:op(A == B) public static inline function eq (a:PlatformInt64, b:PlatformInt64):Bool return haxe.Int64.eq(a,  b);
    @:op(A != B) public static inline function neq(a:PlatformInt64, b:PlatformInt64):Bool return haxe.Int64.neq(a, b);
    @:op(A >  B) public static inline function gt (a:PlatformInt64, b:PlatformInt64):Bool return haxe.Int64.gt(a,  b);
    @:op(A >= B) public static inline function gte(a:PlatformInt64, b:PlatformInt64):Bool return haxe.Int64.gte(a, b);
    @:op(A <  B) public static inline function lt (a:PlatformInt64, b:PlatformInt64):Bool return haxe.Int64.lt(a,  b);
    @:op(A <= B) public static inline function lte(a:PlatformInt64, b:PlatformInt64):Bool return haxe.Int64.lte(a, b);

    // ── conversions ──────────────────────────────────────────────────────────
    public inline function toInt():Int       return haxe.Int64.toInt(this);
    public inline function toString():String return haxe.Int64.toStr(this);

    public static inline function fromInt(v:Int):PlatformInt64     return new PlatformInt64(haxe.Int64.ofInt(v));
    public static inline function ofString(s:String):PlatformInt64 return new PlatformInt64(haxe.Int64.parseString(s));
}
#end