package com.smartfoxserver.v3.entities.data;

#if target.threaded

import sys.thread.Mutex;

class Deque<T> {
    private var mutex:Mutex;
    private var items:Array<T>;

    public var length(get, never):Int;

    public function new() {
        this.items = [];
        this.mutex = new Mutex();
    }

    inline function get_length():Int {
        mutex.acquire();
        var len = items.length;
        mutex.release();
        return len;
    }

    @:arrayAccess
    public inline function get(index:Int):Null<T> {
        mutex.acquire();
        var item = items[index];
        mutex.release();
        return item;
    }

    // Öne ekle
    public inline function pushFront(item:T):Void {
        mutex.acquire();
        items.unshift(item);
        mutex.release();
    }

    // Sona ekle
    public inline function pushBack(item:T):Void {
        mutex.acquire();
        items.push(item);
        mutex.release();
    }

    // Önden çıkar
    public inline function popFront():Null<T> {
        mutex.acquire();
        var item = items.length > 0 ? items.shift() : null;
        mutex.release();
        return item;
    }

    // Sondan çıkar
    public inline function popBack():Null<T> {
        mutex.acquire();
        var item = items.pop();
        mutex.release();
        return item;
    }

    public inline function peekFront():Null<T> {
        mutex.acquire();
        var item = items.length > 0 ? items[0] : null;
        mutex.release();
        return item;
    }

    public inline function peekBack():Null<T> {
        mutex.acquire();
        var item = items.length > 0 ? items[items.length - 1] : null;
        mutex.release();
        return item;
    }

    public inline function remove(item:T):Bool {
        mutex.acquire();
        var removed = items.remove(item);
        mutex.release();
        return removed;
    }

    public inline function isEmpty():Bool {
        mutex.acquire();
        var empty = items.length == 0;
        mutex.release();
        return empty;
    }

    public inline function clear():Void {
        mutex.acquire();
        items = [];
        mutex.release();
    }

    public function iterator():Iterator<T> {
        mutex.acquire();
        var snapshot = items.copy();
        mutex.release();
        return snapshot.iterator();
    }

    public function keyValueIterator():KeyValueIterator<Int, T> {
        mutex.acquire();
        var snapshot = items.copy();
        mutex.release();
        return snapshot.keyValueIterator();
    }
}

#else

class Deque<T> {
    private var items:Array<T>;

    public var length(get, never):Int;

    public function new() {
        this.items = [];
    }

    inline function get_length():Int {
        return items.length;
    }

    @:arrayAccess
    public inline function get(index:Int):Null<T> {
        return items[index];
    }

    public inline function pushFront(item:T):Void {
        items.unshift(item);
    }

    public inline function pushBack(item:T):Void {
        items.push(item);
    }

    public inline function popFront():Null<T> {
        return items.length > 0 ? items.shift() : null;
    }

    public inline function popBack():Null<T> {
        return items.pop();
    }

    public inline function peekFront():Null<T> {
        return items.length > 0 ? items[0] : null;
    }

    public inline function peekBack():Null<T> {
        return items.length > 0 ? items[items.length - 1] : null;
    }

    public inline function remove(item:T):Bool {
        return items.remove(item);
    }

    public inline function isEmpty():Bool {
        return items.length == 0;
    }

    public inline function clear():Void {
        items = [];
    }

    public function iterator():Iterator<T> {
        return items.copy().iterator();
    }

    public function keyValueIterator():KeyValueIterator<Int, T> {
        return items.copy().keyValueIterator();
    }
}

#end