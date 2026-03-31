package sfs3.client.core;
import hx.concurrent.collection.SynchronizedMap;
import hx.concurrent.collection.CopyOnWriteArray;
import haxe.Exception;
class EventDispatcher {
    private final listeners:SynchronizedMap<String, CopyOnWriteArray<IEventListener<ApiEvent>>>;
    private final target:Dynamic;
    private final log:Logger;

    public function new(target:Dynamic)
    {
        this.target = target;
        listeners = SynchronizedMap.newStringMap();

        log = LoggerFactory.getLogger(Type.getClass(this));
    }

    public function addEventListener<T:ApiEvent>(eventType:String, listener:IEventListener<T>):Void
    {
        var list:CopyOnWriteArray<IEventListener<T>> = cast listeners.get(eventType);

        if (list == null)
        {
            list = new CopyOnWriteArray<IEventListener<T>>();
            listeners.set(eventType, cast list);
        }

        if (!list.contains(listener))
            list.add(listener);
    }

    public function removeEventListener<T:ApiEvent>(eventType:String, listener:IEventListener<T>):Void
    {
        var list:CopyOnWriteArray<IEventListener<T>> = cast listeners.get(eventType);

        if (list == null)
            return;

        list.remove(listener);
    }

    public function dispatchEvent(evt:ApiEvent):Void
    {
        var list:CopyOnWriteArray<IEventListener<ApiEvent>> = listeners.get(evt.getType());

        if (list == null)
            return;

        evt.setTarget(this.target);

        if (log.isDebugEnabled())
            log.debug("Dispatching event {} to {} listeners", evt.getType(), list.length);

        try
        {
            for (listener in list)
                listener(evt);
        }
        catch (ex:Exception)
        {
            log.error("Error dispatching event {} ", evt.getType(), ex);
        }
    }

    public function removeAll():Void
    {
        listeners.clear();
    }
}
