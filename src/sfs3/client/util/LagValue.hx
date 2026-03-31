package sfs3.client.util;

/**
 * Represents an immutable lag value with average, min, and max metrics.
 */
class LagValue
{
    public final average:Float;
    public final min:Float;
    public final max:Float;

    public function new(average:Float, min:Float, max:Float)
    {
        this.average = average;
        this.min = min;
        this.max = max;
    }

    public function toString():String
    {
        return 'Avg: ${formatFloat(average)} ms, Min: ${formatFloat(min)} ms, Max: ${formatFloat(max)} ms';
    }

    /**
     * Helper function to format a Float to 2 decimal places (like "%.2f").
     */
    private function formatFloat(value:Float):String
    {
        // Sayıyı en yakın iki ondalık basamağa yuvarla
        var rounded:Float = Math.round(value * 100) / 100;
        var str:String = Std.string(rounded);
        var dotIndex:Int = str.indexOf(".");

        // Eğer tam sayıysa (örn: 15) sonuna ".00" ekle
        if (dotIndex == -1) {
            return str + ".00";
        }

        // Eğer virgülden sonra tek hane varsa (örn: 15.5) sonuna "0" ekle
        if (str.length - dotIndex == 2) {
            return str + "0";
        }

        return str;
    }
}