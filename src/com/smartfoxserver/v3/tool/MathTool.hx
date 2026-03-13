package com.smartfoxserver.v3.tool;
class MathTool {
    public static inline function hypot(clazz:Class<Math>, x:Float, y:Float):Float {
        return Math.sqrt(x * x + y * y);
    }
}
