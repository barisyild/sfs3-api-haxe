package com.smartfoxserver.v3.entities.data;

#if target.threaded

import sys.thread.Mutex;

class Queue<T> {
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

    public inline function enqueue(item:T):Void {
        mutex.acquire();
        items.push(item);
        mutex.release();
    }

    public inline function dequeue():Null<T> {
        mutex.acquire();
        var item = items.length > 0 ? items.shift() : null;
        mutex.release();
        return item;
    }

    public inline function pop():Null<T> {
        mutex.acquire();
        var item = items.pop();
        mutex.release();
        return item;
    }

    public inline function peek():Null<T> {
        mutex.acquire();
        var item = items.length > 0 ? items[0] : null;
        mutex.release();
        return item;
    }

    public inline function isEmpty():Bool {
        mutex.acquire();
        var empty = items.length == 0;
        mutex.release();
        return empty;
    }

    public inline function remove(item:T):Bool {
        mutex.acquire();
        var removed = items.remove(item);
        mutex.release();
        return removed;
    }

    public inline function clear():Void {
        mutex.acquire();
        items = [];
        mutex.release();
    }

     public inline function push(v:T):Void {
        return enqueue(v);
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

class Queue<T> {
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

    public inline function enqueue(item:T):Void {
        items.push(item);
    }

    public inline function dequeue():Null<T> {
        return items.length > 0 ? items.shift() : null;
    }

    public inline function pop():Null<T> {
        return items.pop();
    }

    public inline function peek():Null<T> {
        return items.length > 0 ? items[0] : null;
    }

    public inline function isEmpty():Bool {
        return items.length == 0;
    }

    public inline function remove(item:T):Bool {
        return items.remove(item);
    }

    public inline function clear():Void {
        items = [];
    }

    public inline function push(v:T):Void {
        return enqueue(v);
    }

    public function iterator():Iterator<T> {
        return items.copy().iterator();
    }

    public function keyValueIterator():KeyValueIterator<Int, T> {
        return items.copy().keyValueIterator();
    }
}

#end