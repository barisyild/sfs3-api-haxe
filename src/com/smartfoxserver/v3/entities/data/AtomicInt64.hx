package com.smartfoxserver.v3.entities.data;
import haxe.Int64;

#if target.atomics.false
import haxe.atomic.AtomicObject;
#elseif target.threaded
import sys.thread.Mutex;
#end

// ---------------------------------------------------------------------------
// Internal box – only used on target.atomics.
// Immutable so a published box is never mutated after CAS.
// ---------------------------------------------------------------------------
#if target.atomics.false
private final class Int64Box {
	public final value:Int64;

	public inline function new(v:Int64) {
		value = v;
	}
}
#end

// ---------------------------------------------------------------------------
// Backing implementation class
// ---------------------------------------------------------------------------
private class AtomicInt64Impl {
    #if target.atomics.false
	var _atom:AtomicObject<Int64Box>;
	#elseif target.threaded
	var _mutex:Mutex;
	var _value:Int64;
	#else
    var _value:Int64;
    #end

    public function new(value:Int64) {
        #if target.atomics.false
		_atom = new AtomicObject(new Int64Box(value));
		#elseif target.threaded
		_mutex = new Mutex();
		_value = value;
		#else
        _value = value;
        #end
    }

    // --- load ------------------------------------------------------------------

    public function load():Int64 {
        #if target.atomics.false
		return _atom.load().value;
		#elseif target.threaded
		_mutex.acquire();
		final v = _value;
		_mutex.release();
		return v;
		#else
        return _value;
        #end
    }

    // --- store -----------------------------------------------------------------

    public function store(value:Int64):Void {
        #if target.atomics.false
		// Spin-CAS: publish a fresh box unconditionally.
		var cur = _atom.load();
		final next = new Int64Box(value);
		while (_atom.compareExchange(cur, next) != cur)
			cur = _atom.load();
		#elseif target.threaded
		_mutex.acquire();
		_value = value;
		_mutex.release();
		#else
        _value = value;
        #end
    }

    // --- compareExchange -------------------------------------------------------
    //
    // Returns `expected` on success, the actual current value on failure —
    // matching the AtomicInt contract exactly.

    public function compareExchange(expected:Int64, replacement:Int64):Int64 {
        #if target.atomics.false
		var cur = _atom.load();
		while (true) {
			if (!Int64.eq(cur.value, expected))
				return cur.value; // mismatch – return current
			final prev = _atom.compareExchange(cur, new Int64Box(replacement));
			if (prev == cur)
				return expected; // success
			cur = prev; // another thread raced us; retry
		}
		#elseif target.threaded
		_mutex.acquire();
		final old = _value;
		if (Int64.eq(_value, expected))
			_value = replacement;
		_mutex.release();
		return old;
		#else
        final old = _value;
        if (Int64.eq(_value, expected))
            _value = replacement;
        return old;
        #end
    }

    // --- exchange --------------------------------------------------------------

    public function exchange(value:Int64):Int64 {
        #if target.atomics.false
		var cur = _atom.load();
		// `next` is constant across retries – safe to reuse because a failed
		// CAS means the box was never published.
		final next = new Int64Box(value);
		while (true) {
			final prev = _atom.compareExchange(cur, next);
			if (prev == cur)
				return cur.value;
			cur = prev;
		}
		#elseif target.threaded
		_mutex.acquire();
		final old = _value;
		_value = value;
		_mutex.release();
		return old;
		#else
        final old = _value;
        _value = value;
        return old;
        #end
    }

    // --- fetchAdd --------------------------------------------------------------

    public function fetchAdd(value:Int64):Int64 {
        #if target.atomics.false
		var cur = _atom.load();
		while (true) {
			final prev = _atom.compareExchange(cur, new Int64Box(Int64.add(cur.value, value)));
			if (prev == cur)
				return cur.value;
			cur = prev;
		}
		#elseif target.threaded
		_mutex.acquire();
		final old = _value;
		_value = Int64.add(_value, value);
		_mutex.release();
		return old;
		#else
        final old = _value;
        _value = Int64.add(_value, value);
        return old;
        #end
    }

    // --- fetchSub --------------------------------------------------------------

    public function fetchSub(value:Int64):Int64 {
        #if target.atomics.false
		var cur = _atom.load();
		while (true) {
			final prev = _atom.compareExchange(cur, new Int64Box(Int64.sub(cur.value, value)));
			if (prev == cur)
				return cur.value;
			cur = prev;
		}
		#elseif target.threaded
		_mutex.acquire();
		final old = _value;
		_value = Int64.sub(_value, value);
		_mutex.release();
		return old;
		#else
        final old = _value;
        _value = Int64.sub(_value, value);
        return old;
        #end
    }
}

// ---------------------------------------------------------------------------
// Public abstract – mirrors haxe.atomic.AtomicInt but for Int64.
//
// Int parametreleri: Int64, @:from aracılığıyla zaten Int'i kabul eder.
// Ek olarak fetchAddInt / fetchSubInt / storeInt / exchangeInt /
// compareExchangeInt kolaylık metodları da sunulur; böylece Int literal
// geçerken tip belirsizliği yaşanmaz.
// ---------------------------------------------------------------------------
abstract AtomicInt64(AtomicInt64Impl) {
    /**
		Verilen başlangıç değeriyle yeni bir `AtomicInt64` oluşturur.
		`Int` geçmek de geçerlidir – `Int64.ofInt` ile otomatik dönüştürülür.
	**/
    public inline function new(value:Int64) {
        this = new AtomicInt64Impl(value);
    }

    // -------------------------------------------------------------------------
    // Core API  (AtomicInt ile birebir aynı isimler, Int64 parametreli)
    // -------------------------------------------------------------------------

    /** Güncel değeri döndürür. **/
    public inline function load():Int64 {
        return this.load();
    }

    /** Değeri `value` olarak atar. **/
    public inline function store(value:Int64):Void {
        this.store(value);
    }

    /**
		Güncel değer `expected`'a eşitse `replacement` ile değiştirir ve
		`expected` döndürür.  Eşit değilse değişiklik yapmadan güncel değeri
		döndürür.
	**/
    public inline function compareExchange(expected:Int64, replacement:Int64):Int64 {
        return this.compareExchange(expected, replacement);
    }

    /** Değeri `value` olarak atar, önceki değeri döndürür. **/
    public inline function exchange(value:Int64):Int64 {
        return this.exchange(value);
    }

    /** `value` ekler, ekleme öncesi değeri döndürür. **/
    public inline function fetchAdd(value:Int64):Int64 {
        return this.fetchAdd(value);
    }

    /** `value` çıkarır, çıkarma öncesi değeri döndürür. **/
    public inline function fetchSub(value:Int64):Int64 {
        return this.fetchSub(value);
    }

    // -------------------------------------------------------------------------
    // Int kolaylık metodları
    // (Int64 @:from dönüşümü çoğu durumda zaten çalışır; bunlar explicit
    //  alternatif sunar ve boxing belirsizliğini ortadan kaldırır.)
    // -------------------------------------------------------------------------

    /** `fetchAdd(Int64.ofInt(value))` kısayolu. **/
    public inline function fetchAddInt(value:Int):Int64 {
        return this.fetchAdd(Int64.ofInt(value));
    }

    /** `fetchSub(Int64.ofInt(value))` kısayolu. **/
    public inline function fetchSubInt(value:Int):Int64 {
        return this.fetchSub(Int64.ofInt(value));
    }

    /** `store(Int64.ofInt(value))` kısayolu. **/
    public inline function storeInt(value:Int):Void {
        this.store(Int64.ofInt(value));
    }

    /** `exchange(Int64.ofInt(value))` kısayolu. **/
    public inline function exchangeInt(value:Int):Int64 {
        return this.exchange(Int64.ofInt(value));
    }

    /** `compareExchange` ile `Int` argümanlar. **/
    public inline function compareExchangeInt(expected:Int, replacement:Int):Int64 {
        return this.compareExchange(Int64.ofInt(expected), Int64.ofInt(replacement));
    }
}
