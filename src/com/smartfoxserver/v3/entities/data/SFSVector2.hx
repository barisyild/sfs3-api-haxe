package com.smartfoxserver.v3.entities.data;
import com.smartfoxserver.v3.exceptions.IllegalArgumentException;

class SFSVector2 {
    private static final EPSILON:Float = 1.0E-5;
    public var x:Float;
    public var y:Float;

    public static function empty():SFSVector2 {
        return new SFSVector2(0.0, 0.0);
    }

    public function new(x:Float, y:Float) {
        this.x = x;
        this.y = y;
    }

    public static function fromSFSVector2(vec2:SFSVector2):SFSVector2 {
        return new SFSVector2(vec2.x, vec2.y);
    }

    private function lengthSquared():Float {
        return this.x * this.x + this.y * this.y;
    }

    public function length():Float {
        return Math.hypot(this.x, this.y);
    }

    public function isNormalized():Bool {
        return Math.abs(this.lengthSquared() - 1.0) < EPSILON;
    }

    public function sum(vec:SFSVector2):SFSVector2 {
        if (vec == null) {
            throw new IllegalArgumentException("Vector argument cannot be null");
        } else {
            return new SFSVector2(this.x + vec.x, this.y + vec.y);
        }
    }

    public function sub(vec:SFSVector2):SFSVector2 {
        if (vec == null) {
            throw new IllegalArgumentException("Vector argument cannot be null");
        } else {
            return new SFSVector2(this.x - vec.x, this.y - vec.y);
        }
    }

    public function mult(vec:SFSVector2):SFSVector2 {
        if (vec == null) {
            throw new IllegalArgumentException("Vector argument cannot be null");
        } else {
            return new SFSVector2(this.x * vec.x, this.y * vec.y);
        }
    }

    public function divide(vec:SFSVector2):SFSVector2 {
        if (vec == null) {
            throw new IllegalArgumentException("Vector argument cannot be null");
        } else {
            return new SFSVector2(this.x / vec.x, this.y / vec.y);
        }
    }

    public function normalize():SFSVector2 {
        var len:Float = this.length();
        return len < EPSILON ? new SFSVector2(0.0, 0.0) : new SFSVector2(this.x / len, this.y / len);
    }

    public function angle():Float {
        return Math.atan2(this.y, this.x);
    }

    public function rotate(angle:Float):SFSVector2 {
        var cos:Float = Math.cos(angle);
        var sin:Float = Math.sin(angle);
        return new SFSVector2(this.x * cos - this.y * sin, this.x * sin + this.y * cos);
    }

    public function dot(vec:SFSVector2):Float {
        if (vec == null) {
            throw new IllegalArgumentException("Vector argument cannot be null");
        } else {
            return this.x * vec.x + this.y * vec.y;
        }
    }

    public function cross(vec:SFSVector2):Float {
        if (vec == null) {
            throw new IllegalArgumentException("Vector argument cannot be null");
        } else {
            return this.x * vec.y - this.y * vec.x;
        }
    }

    public function distanceTo(vec:SFSVector2):Float {
        if (vec == null) {
            throw new IllegalArgumentException("Vector argument cannot be null");
        } else {
            return Math.hypot(this.x - vec.x, this.y - vec.y);
        }
    }

    public function distanceSquaredTo(vec:SFSVector2):Float {
        if (vec == null) {
            throw new IllegalArgumentException("Vector argument cannot be null");
        } else {
            var dx:Float = this.x - vec.x;
            var dy:Float = this.y - vec.y;
            return dx * dx + dy * dy;
        }
    }

    public function abs():SFSVector2 {
        return new SFSVector2(Math.abs(this.x), Math.abs(this.y));
    }

    public function min(vec:SFSVector2):SFSVector2 {
        if (vec == null) {
            throw new IllegalArgumentException("Vector argument cannot be null");
        } else {
            return new SFSVector2(Math.min(this.x, vec.x), Math.min(this.y, vec.y));
        }
    }

    public function max(vec:SFSVector2):SFSVector2 {
        if (vec == null) {
            throw new IllegalArgumentException("Vector argument cannot be null");
        } else {
            return new SFSVector2(Math.max(this.x, vec.x), Math.max(this.y, vec.y));
        }
    }

    public function floor():SFSVector2 {
        return new SFSVector2(Math.floor(this.x), Math.floor(this.y));
    }

    public function ceil():SFSVector2 {
        return new SFSVector2(Math.ceil(this.x), Math.ceil(this.y));
    }

    public function round():SFSVector2 {
        return new SFSVector2(Math.round(this.x), Math.round(this.y));
    }

    public function lerp(vec:SFSVector2, weight:Float):SFSVector2 {
        if (vec == null) {
            throw new IllegalArgumentException("Vector argument cannot be null");
        } else {
            return new SFSVector2(this.x + (vec.x - this.x) * weight, this.y + (vec.y - this.y) * weight);
        }
    }

    public function aspect():Float {
        return this.x / this.y;
    }

    public function equals(other:Dynamic):Bool {
        if (other is SFSVector2) {
            var otherVec:SFSVector2 = cast other;
            return otherVec.x == this.x && otherVec.y == this.y;
        } else {
            return false;
        }
    }

    public function toString():String {
        return '(${this.x}, ${this.y})';
    }
}
