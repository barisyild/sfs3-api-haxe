package macro.python;

#if macro
import haxe.macro.Context;
import haxe.macro.Type;
import haxe.macro.Expr;
using StringTools;
using haxe.macro.TypeTools;
#end

class MinifyMacro {
	static final EXPOSE_PREFIX = "SFS3.";

	public static function run() {
		#if macro
		Context.onGenerate(function(types:Array<Type>) {
			var renamed = 0;

			for (type in types) {
				switch (type.follow()) {
					case TInst(_.get() => cl, _):
						if (cl.isExtern || cl.meta.has(":native"))
							continue;
						if (tryRenameFromExpose(cl.meta))
							renamed++;

					case TEnum(_.get() => en, _):
						if (en.isExtern || en.meta.has(":native"))
							continue;
						if (tryRenameFromExpose(en.meta))
							renamed++;

					default:
				}
			}

			trace('[PythonMinify] Renamed: $renamed');
		});
		#end
	}

	#if macro
	static function tryRenameFromExpose(meta:MetaAccess):Bool {
		if (!meta.has(":expose"))
			return false;

		var entries = meta.extract(":expose");
		if (entries.length == 0)
			return false;

		var entry = entries[0];
		if (entry.params == null || entry.params.length == 0)
			return false;

		var exposeValue:String = switch (entry.params[0].expr) {
			case EConst(CString(s, _)): s;
			default: null;
		};

		if (exposeValue == null)
			return false;

		var nativeName = exposeValue.startsWith(EXPOSE_PREFIX)
			? exposeValue.substr(EXPOSE_PREFIX.length)
			: exposeValue;

		meta.add(":native", [macro $v{nativeName}], Context.currentPos());
		return true;
	}
	#end
}
