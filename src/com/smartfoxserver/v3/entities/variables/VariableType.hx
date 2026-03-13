package com.smartfoxserver.v3.entities.variables;

enum abstract VariableType(Int) from Int to Int {
    var NULL = 0;
    var BOOL = 1;
    var BYTE = 2;
    var SHORT = 3;
    var INT = 4;
    var LONG = 5;
    var FLOAT = 6;
    var DOUBLE = 7;
    var STRING = 8;
    var OBJECT = 9;
    var ARRAY = 10;
    var VECTOR2 = 11;
    var VECTOR3 = 12;

    // Java'daki getId() yerine doğrudan kendisi Int olarak kullanılabilir
    public inline function getId():Int {
        return this;
    }

    // Java: fromString
    public static function fromString(id:String):VariableType {
        return switch (id.toUpperCase()) {
            case "NULL": NULL;
            case "BOOL": BOOL;
            case "BYTE": BYTE;
            case "SHORT": SHORT;
            case "INT": INT;
            case "LONG": LONG;
            case "FLOAT": FLOAT;
            case "DOUBLE": DOUBLE;
            case "STRING": STRING;
            case "OBJECT": OBJECT;
            case "ARRAY": ARRAY;
            case "VECTOR2": VECTOR2;
            case "VECTOR3": VECTOR3;
            default: throw 'Unknown VariableType: $id';
        }
    }

    // Java: fromId
    public static function fromId(id:Int):Null<VariableType> {
        if (id >= 0 && id <= 12) {
            return cast id;
        }
        return null;
    }
}