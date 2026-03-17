package;

#if macro
import haxe.macro.Context;
import haxe.macro.Type;
using StringTools;
using haxe.macro.TypeTools;
#end

class PythonMinifyMacro {
	static final TARGET_PACKAGE = "SFS3";

	public static function run() {
		#if macro
		Context.onGenerate(function(types:Array<Type>) {
			var nameCount = new Map<String, Int>();
			var candidates:Array<{name:String, meta:MetaAccess}> = [];

			for (type in types) {
				switch (type.follow()) {
					case TInst(_.get() => cl, _):
						if (cl.isExtern || cl.meta.has(":native"))
							continue;
						if (!cl.pack.join(".").startsWith("com.smartfoxserver"))
							continue;
						addCandidate(candidates, nameCount, cl.name, cl.meta);

					case TEnum(_.get() => en, _):
						if (en.isExtern || en.meta.has(":native"))
							continue;
						if (!en.pack.join(".").startsWith("com.smartfoxserver"))
							continue;
						addCandidate(candidates, nameCount, en.name, en.meta);

					default:
				}
			}

			var renamed = 0;
			var collisions = 0;

			for (c in candidates) {
				if (nameCount.get(c.name) > 1) {
					collisions++;
					continue;
				}
				c.meta.add(":native", [macro $v{c.name}], Context.currentPos());
				renamed++;
			}

			trace('[PythonMinify] Renamed: $renamed, Collisions skipped: $collisions');
		});
		#end
	}

	#if macro
	static function addCandidate(candidates:Array<{name:String, meta:MetaAccess}>, nameCount:Map<String, Int>, name:String, meta:MetaAccess) {
		candidates.push({name: name, meta: meta});
		nameCount.set(name, (nameCount.exists(name) ? nameCount.get(name) : 0) + 1);
	}
	#end
}
