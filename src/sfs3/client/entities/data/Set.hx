package sfs3.client.entities.data;

abstract Set<T>(Array<T>) {

    // ── Yapıcı & Dönüşümler ───────────────────────────────────────

    public inline function new()
    this = [];

    @:from
    public static function fromArray<T>(arr:Array<T>):Set<T> {
        var s = new Set<T>();
        for (v in arr) s.push(v);
        return s;
    }

    @:to
    public inline function toArray():Array<T>
    return this.copy();

    // ── length ────────────────────────────────────────────────────

    public var length(get, never):Int;
    inline function get_length():Int return this.length;

    // ── Array yazma/okuma erişimi  (s[i]) ─────────────────────────

    @:arrayAccess
    public inline function get(i:Int):T
    return this[i];

    @:arrayAccess
    public function set(i:Int, v:T):T {
        if (this.indexOf(v) == -1)
            this[i] = v;
        return v;
    }

    // ── push / pop / shift / unshift ──────────────────────────────

    public function push(v:T):Int {
        if (this.indexOf(v) == -1) this.push(v);
        return this.length;
    }

    public inline function pop():Null<T>
    return this.pop();

    public inline function shift():Null<T>
    return this.shift();

    public function unshift(v:T):Int {
        if (this.indexOf(v) == -1) this.unshift(v);
        return this.length;
    }

    // ── splice / slice / insert ───────────────────────────────────

    public function splice(pos:Int, len:Int, ?rest:Array<T>):Array<T> {
        var removed = this.splice(pos, len);
        if (rest != null)
            for (v in rest)
                push(v);
        return removed;
    }

    public function slice(pos:Int, ?end:Int):Set<T>
    return fromArray(this.slice(pos, end));

    public function insert(pos:Int, v:T):Void {
        if (this.indexOf(v) == -1) this.insert(pos, v);
    }

    // ── Arama ─────────────────────────────────────────────────────

    public inline function indexOf(v:T, ?fromIndex:Int):Int
    return this.indexOf(v, fromIndex);

    public inline function lastIndexOf(v:T, ?fromIndex:Int):Int
    return this.lastIndexOf(v, fromIndex);

    public inline function contains(v:T):Bool
    return this.indexOf(v) != -1;

    // ── remove (Array API'sinde de var) ───────────────────────────

    public function remove(v:T):Bool
    return this.remove(v);

    // ── Sıralama & Tersine çevirme ────────────────────────────────

    public inline function sort(cmp:T->T->Int):Void
    this.sort(cmp);

    public inline function reverse():Void
    this.reverse();

    // ── Fonksiyonel API ───────────────────────────────────────────

    public function map<U>(fn:T->U):Set<U> {
        var r = new Set<U>();
        for (v in this) r.push(fn(v));
        return r;
    }

    public function filter(fn:T->Bool):Set<T> {
        var r = new Set<T>();
        for (v in this) if (fn(v)) r.push(v);
        return r;
    }

    public inline function iter(fn:T->Void):Void
    for (v in this) fn(v);

    public function fold<A>(fn:A->T->A, init:A):A {
        var acc = init;
        for (v in this) acc = fn(acc, v);
        return acc;
    }

    public function exists(fn:T->Bool):Bool {
        for (v in this) if (fn(v)) return true;
        return false;
    }

    public function every(fn:T->Bool):Bool {
        for (v in this) if (!fn(v)) return false;
        return true;
    }

    public inline function join(sep:String):String
    return this.join(sep);

    public function concat(other:Set<T>):Set<T>
    return union(other);

    public inline function clear():Void
    this.splice(0, this.length);

    public inline function isEmpty():Bool
    return this.length == 0;

    public inline function copy():Set<T>
    return fromArray(this.copy());

    public inline function iterator():Iterator<T>
    return this.iterator();

    public inline function keyValueIterator():KeyValueIterator<Int, T>
    return this.keyValueIterator();

    /** A ∪ B */
    public function union(other:Set<T>):Set<T> {
        var r = copy();
        for (v in (other : Array<T>)) r.push(v);
        return r;
    }

    /** A ∩ B */
    public function intersection(other:Set<T>):Set<T> {
        var r = new Set<T>();
        for (v in this) if (other.contains(v)) r.push(v);
        return r;
    }

    /** A \ B */
    public function difference(other:Set<T>):Set<T> {
        var r = new Set<T>();
        for (v in this) if (!other.contains(v)) r.push(v);
        return r;
    }

    /** (A \ B) ∪ (B \ A) */
    public function symmetricDifference(other:Set<T>):Set<T>
    return difference(other).union(other.difference(cast this));

    /** A ⊆ B */
    public function isSubsetOf(other:Set<T>):Bool {
        for (v in this) if (!other.contains(v)) return false;
        return true;
    }

    /** A ⊇ B */
    public inline function isSupersetOf(other:Set<T>):Bool
    return other.isSubsetOf(cast this);

    /** A ∩ B = ∅ */
    public function isDisjoint(other:Set<T>):Bool {
        for (v in this) if (other.contains(v)) return false;
        return true;
    }

    /** Eleman sayısı ve içerik bakımından eşit mi? */
    public function equals(other:Set<T>):Bool
    return length == other.length && isSubsetOf(other);

    // ── Operators ───────────────────────────────────────────────

    @:op(A | B) public inline function opUnion(b:Set<T>):Set<T>        return union(b);
    @:op(A & B) public inline function opIntersection(b:Set<T>):Set<T> return intersection(b);
    @:op(A - B) public inline function opDifference(b:Set<T>):Set<T>   return difference(b);
    @:op(A ^ B) public inline function opSymDiff(b:Set<T>):Set<T>      return symmetricDifference(b);

    // ── toString ──────────────────────────────────────────────────

    public inline function toString():String
    return '{' + this.join(', ') + '}';
}
