package macro.hashlink;

class PatchFuture {
    public static function patch() {
        #if macro
        if (!haxe.macro.Context.defined("hl")) {
          return;
        }

        var tmp = Sys.getEnv("TMPDIR");
        if (tmp == null) tmp = Sys.getEnv("TEMP");
        if (tmp == null) tmp = Sys.getEnv("TMP");
        if (tmp == null) tmp = "/tmp";

        var dir = tmp + "/hx-patch/hx/concurrent";
        sys.FileSystem.createDirectory(dir);

        var src = haxe.macro.Context.resolvePath("hx/concurrent/Future.hx");
        trace(src);
        var content = sys.io.File.getContent(src);
        var patched = StringTools.replace(
          content,
          "typedef FutureCompletionListener<T> = (FutureResult<T>) -> Void;",
          "typedef FutureCompletionListener<T> = Any -> Void;"
        );
        sys.io.File.saveContent(dir + "/Future.hx", patched);
        haxe.macro.Compiler.addClassPath(tmp + "/hx-patch");
        #end
    }
}