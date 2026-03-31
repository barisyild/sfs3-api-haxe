package sfs3.client.entities.data;
import sfs3.client.exceptions.IllegalArgumentException;
class SFSVector3 {
    private static final EPSILON:Float = 1.0E-5;
    public var x:Float;
    public var y:Float;
    public var z:Float;

    public static function empty():SFSVector3 {
        return new SFSVector3(0.0, 0.0, 0.0);
    }

    public function new(x:Float, y:Float, z:Float) {
        this.x = x;
        this.y = y;
        this.z = z;
    }

    public static function fromSFSVector3(vec3:SFSVector3):SFSVector3 {
        return new SFSVector3(vec3.x, vec3.y, vec3.z);
    }

    private function lengthSquared():Float {
        return this.x * this.x + this.y * this.y + this.z * this.z;
    }

    public function length():Float {
        return Math.sqrt(this.lengthSquared());
    }

    public function isNormalized():Bool {
        return Math.abs(this.lengthSquared() - 1.0) < EPSILON;
    }

    public function sum(vec:SFSVector3):SFSVector3 {
        if (vec == null) {
            throw new IllegalArgumentException("Vector argument cannot be null");
        } else {
            return new SFSVector3(this.x + vec.x, this.y + vec.y, this.z + vec.z);
        }
    }

    public function sub(vec:SFSVector3):SFSVector3 {
        if (vec == null) {
            throw new IllegalArgumentException("Vector argument cannot be null");
        } else {
            return new SFSVector3(this.x - vec.x, this.y - vec.y, this.z - vec.z);
        }
    }

    public function mult(vec:SFSVector3):SFSVector3 {
        if (vec == null) {
            throw new IllegalArgumentException("Vector argument cannot be null");
        } else {
            return new SFSVector3(this.x * vec.x, this.y * vec.y, this.z * vec.z);
        }
    }

    public function divide(vec:SFSVector3):SFSVector3 {
        if (vec == null) {
            throw new IllegalArgumentException("Vector argument cannot be null");
        } else {
            return new SFSVector3(this.x / vec.x, this.y / vec.y, this.z / vec.z);
        }
    }

    public function normalize():SFSVector3 {
        var len:Float = this.length();
        return len < EPSILON ? new SFSVector3(0.0, 0.0, 0.0) : new SFSVector3(this.x / len, this.y / len, this.z / len);
    }

    public function dot(vec:SFSVector3):Float {
        if (vec == null) {
            throw new IllegalArgumentException("Vector argument cannot be null");
        } else {
            return this.x * vec.x + this.y * vec.y + this.z * vec.z;
        }
    }

    public function distanceTo(vec:SFSVector3):Float {
        if (vec == null) {
            throw new IllegalArgumentException("Vector argument cannot be null");
        } else {
            var dx:Float = this.x - vec.x;
            var dy:Float = this.y - vec.y;
            var dz:Float = this.z - vec.z;
            return Math.sqrt((dx * dx + dy * dy + dz * dz));
        }
    }

    public function distanceSquaredTo(vec:SFSVector3):Float {
        if (vec == null) {
            throw new IllegalArgumentException("Vector argument cannot be null");
        } else {
            var dx:Float = this.x - vec.x;
            var dy:Float = this.y - vec.y;
            var dz:Float = this.z - vec.z;
            return dx * dx + dy * dy + dz * dz;
        }
    }

    public function abs():SFSVector3 {
        return new SFSVector3(Math.abs(this.x), Math.abs(this.y), Math.abs(this.z));
    }

    public function min(vec:SFSVector3):SFSVector3 {
        if (vec == null) {
            throw new IllegalArgumentException("Vector argument cannot be null");
        } else {
            return new SFSVector3(Math.min(this.x, vec.x), Math.min(this.y, vec.y), Math.min(this.z, vec.z));
        }
    }

    public function max(vec:SFSVector3):SFSVector3 {
        if (vec == null) {
            throw new IllegalArgumentException("Vector argument cannot be null");
        } else {
            return new SFSVector3(Math.max(this.x, vec.x), Math.max(this.y, vec.y), Math.max(this.z, vec.z));
        }
    }

    public function floor():SFSVector3 {
        return new SFSVector3(Math.floor(this.x), Math.floor(this.y), Math.floor(this.z));
    }

    public function ceil():SFSVector3 {
        return new SFSVector3(Math.ceil(this.x), Math.ceil(this.y), Math.ceil(this.z));
    }

    public function round():SFSVector3 {
        return new SFSVector3(Math.round(this.x), Math.round(this.y), Math.round(this.z));
    }

    public function lerp(vec:SFSVector3, weight:Float):SFSVector3 {
        if (vec == null) {
            throw new IllegalArgumentException("Vector argument cannot be null");
        } else {
            return new SFSVector3(this.x + (vec.x - this.x) * weight, this.y + (vec.y - this.y) * weight, this.z + (vec.z - this.z) * weight);
        }
    }

    public function cross(vec:SFSVector3):SFSVector3 {
        if (vec == null) {
            throw new IllegalArgumentException("Vector argument cannot be null");
        } else {
            return new SFSVector3(this.y * vec.z - this.z * vec.y, this.z * vec.x - this.x * vec.z, this.x * vec.y - this.y * vec.x);
        }
    }

    public function rotate(axis:SFSVector3, angle:Float):SFSVector3 {
        if (axis == null) {
            throw new IllegalArgumentException("Axis argument cannot be null");
        } else if (!axis.isNormalized()) {
            throw new IllegalArgumentException("Axis argument must be a normalized vector");
        } else {
            var cos:Float = Math.cos(angle);
            var sin = Math.sin(angle);
            var oneMinusCos:Float = 1.0 - cos;
            var dotProduct:Float = axis.dot(this);
            var crossProduct:SFSVector3 = axis.cross(this);
            return new SFSVector3(this.x * cos + crossProduct.x * sin + axis.x * dotProduct * oneMinusCos, this.y * cos + crossProduct.y * sin + axis.y * dotProduct * oneMinusCos, this.z * cos + crossProduct.z * sin + axis.z * dotProduct * oneMinusCos);
        }
    }

    public function equals(other:Dynamic):Bool {
        if (other is SFSVector3) {
            var otherVec:SFSVector3 = cast other;
            return otherVec.x == this.x && otherVec.y == this.y && otherVec.z == this.z;
        } else {
            return false;
        }
    }

    public function toString():String {
        return '(${this.x}, ${this.y}, ${this.z})';
    }
}
