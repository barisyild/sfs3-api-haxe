package hx.concurrent.lock;

import hx.concurrent.lock.Acquirable.AbstractAcquirable;
import hx.concurrent.internal.Dates;
import hx.concurrent.thread.Threads;

class RLock extends AbstractAcquirable {

   public static inline final isSupported = #if (threads || flash) true #else false #end;

   #if (cpp || cs || (threads && eval) || java || neko || hl)
   final _rlock = new sys.thread.Mutex();
   #elseif python
      final _rlock = new python.lib.threading.RLock();
   #end

   var _holder:Null<Dynamic> = null;
   var _holderEntranceCount = 0;


   function get_availablePermits():Int
      return isAcquiredByAnyThread ? 0 : 1;


   public var isAcquiredByAnyThread(get, never):Bool;
   inline function get_isAcquiredByAnyThread():Bool
      return _holder != null;


   public var isAcquiredByCurrentThread(get, never):Bool;
   inline function get_isAcquiredByCurrentThread():Bool
      return _holder == Threads.current;


   public var isAcquiredByOtherThread(get, never):Bool;
   inline function get_isAcquiredByOtherThread():Bool
      return isAcquiredByAnyThread && !isAcquiredByCurrentThread;


   inline //
   public function new() {
   }


   public function acquire():Void {
      #if (cpp || cs || (threads && eval) || java || neko || hl || python)
         _rlock.acquire();
      #end

      _holder = Threads.current;
      _holderEntranceCount++;
   }


   public function tryAcquire(timeoutMS = 0):Bool {
      if (timeoutMS < 0) throw "[timeoutMS] must be >= 0";

      if (tryAcquireInternal(timeoutMS)) {
         _holder = Threads.current;
         _holderEntranceCount++;
         return true;
      }

      return false;
   }


   private function tryAcquireInternal(timeoutMS = 0):Bool {
      #if (cpp || cs || (threads && eval) || java || neko || hl)
         return Threads.await(() -> _rlock.tryAcquire(), timeoutMS);
      #elseif python
         return Threads.await(() -> _rlock.acquire(false), timeoutMS);
      #else
         return _holder == null || _holder == Threads.current;
      #end
   }


   public function release():Void {
      if (isAcquiredByCurrentThread) {
         _holderEntranceCount--;
         if (_holderEntranceCount == 0)
            _holder = null;
      } else if (isAcquiredByOtherThread) {
         throw "Lock was acquired by another thread!";
      } else
         throw "Lock was not acquired by any thread!";

      #if (cpp || cs || (threads && eval) || java || neko || hl || python)
         _rlock.release();
      #end
   }
}
