package com.smartfoxserver.v3.entities.data;

#if (!js && target.atomics)
typedef AtomicBool = haxe.atomic.AtomicBool;

#elseif (target.threaded)
import sys.thread.Mutex;

class AtomicBool {
    private var mutex:Mutex;
    private var value:Bool;

    public function new(value:Bool) {
        this.value = value;
        this.mutex = new Mutex(); // DÜZELTME 1: Mutex başlatıldı
    }

    public inline function load():Bool {
        mutex.acquire(); // DÜZELTME 2: lock() yerine acquire()
        var val = this.value;
        mutex.release(); // DÜZELTME 2: unlock() yerine release()
        return val;
    }

    /**
       Atomically stores `value`.
       Returns the value that has been stored.
    **/
    public inline function store(value:Bool):Bool {
        mutex.acquire(); // DÜZELTME 2
        this.value = value;
        mutex.release(); // DÜZELTME 2
        return value;
    }
}

#else
abstract AtomicBool(Bool) {
    public inline function new(value:Bool) {
        this = value;
    }

    public inline function load():Bool {
        return this;
    }

    public inline function store(value:Bool):Bool {
        return this = value;
    }
}
#end