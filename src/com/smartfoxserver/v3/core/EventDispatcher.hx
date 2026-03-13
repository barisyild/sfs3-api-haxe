package com.smartfoxserver.v3.core;
import hx.concurrent.collection.SynchronizedMap;
import hx.concurrent.collection.CopyOnWriteArray;
import haxe.Exception;
class EventDispatcher {
    private final listeners:SynchronizedMap<String, CopyOnWriteArray<IEventListener>>;
    private final target:Dynamic;
    private final log:Logger;

    public function new(target:Dynamic)
    {
        this.target = target;
        listeners = SynchronizedMap.newStringMap();

        log = LoggerFactory.getLogger(Type.getClass(this));
    }

    public function addEventListener(eventType:String, listener:IEventListener):Void
    {
        var list:CopyOnWriteArray<IEventListener> = listeners.get(eventType);

        if (list == null)
        {
            list = new CopyOnWriteArray<IEventListener>();
            listeners.set(eventType, list);
        }

        if (!list.contains(listener))
            list.add(listener);
    }

    public function removeEventListener(eventType:String, listener:IEventListener):Void
    {
        var list:CopyOnWriteArray<IEventListener> = listeners.get(eventType);

        if (list == null)
            return;

        list.remove(listener);
    }

    public function dispatchEvent(evt:ApiEvent):Void
    {
        var list:CopyOnWriteArray<IEventListener> = listeners.get(evt.getType());

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
