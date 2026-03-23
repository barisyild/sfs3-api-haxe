package com.smartfoxserver.v3.entities.data;

#if (js || flash)
/**
 * Tamamen Reflect üzerine kurulu Object Wrapper.
 * Herhangi bir platformda {} (anonim obje) üzerinde çalışır.
 */
abstract PlatformStringMap<T>(Dynamic) from Dynamic to Dynamic {

    public inline function new() {
        this = {};
    }

    @:arrayAccess
    public inline function set(key:String, value:T):T {
        Reflect.setField(this, key, value);
        return value;
    }

    @:arrayAccess
    public inline function get(key:String):Null<T> {
        return Reflect.field(this, key);
    }

    public inline function exists(key:String):Bool {
        return Reflect.hasField(this, key);
    }

    public inline function remove(key:String):Bool {
        return Reflect.deleteField(this, key);
    }

    public inline function keys():Array<String> {
        return Reflect.fields(this);
    }

    /**
     * Obje içindeki tüm değerleri dizi olarak döner.
     */
    public function values():Array<T> {
        var v = [];
        for (f in Reflect.fields(this)) {
            v.push(Reflect.field(this, f));
        }
        return v;
    }

    public function toString():String {
        return this;
    }
}
#else
typedef PlatformStringMap<V> = haxe.ds.StringMap<V>;
#end