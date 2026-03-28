package com.smartfoxserver.v3.core;
import com.smartfoxserver.v3.entities.data.PlatformStringMap;

/**
 * This is the base class of all the events dispatched by the SmartFoxServer 3
 * Java Client API. In particular, check the <b>SFSEvent</b> and
 * <b>SFSBuddyEvent</b> children classes for more information.
 *
 * @see SFSEvent
 * @see SFSBuddyEvent
 */
class ApiEvent {
    /**
	 * Specifies the object containing the parameters of the event.
	 */
    private var params:PlatformStringMap<Dynamic>;

    private var type:String;
    private var target:Dynamic;

    /**
	 * @internal
	 */
    public function getTarget():Dynamic {
        return target;
    }

    /**
	 * @internal
	 */
    public function setTarget(target:Dynamic):Void {
        this.target = target;
    }

    /**
	 * Returns the type of the event.
	 *
	 * @return A string representing the type of the event.
	 */
    public function getType():String {
        return this.type;
    }

    /**
	 * Generates a string containing all the properties of the <em>BaseEvent</em>
	 * object.
	 *
	 * @return A string containing all the properties of the <em>BaseEvent</em>
	 *         object.
	 */
    public function toString():String {
        var className:String = Type.getClassName(Type.getClass(this));
        var simpleClassName:String = className.substring(className.lastIndexOf(".") + 1);
        return '($simpleClassName.$type params: ${params != null ? params.toString() : "null"})';
    }

    /**
	 * @internal
	 *
	 * @return A new <em>BaseEvent</em> object that is identical to the original.
	 */
    public function clone():ApiEvent {
        return new ApiEvent(type, getParams());
    }

    /**
	 * @internal
	 *
	 * @param type      The type of event.
	 * @param params An object containing the parameters of the event.
	 */
    public function new(type:String, params:PlatformStringMap<Dynamic>) {
        this.type = type;
        if(params != null)
            setParams(params);

        if(this.getParams() == null)
            this.setParams(new PlatformStringMap<Dynamic>());
    }

    /**
	 * @internal
	 */
    public function setParams(arguments:PlatformStringMap<Dynamic>):Void {
        this.params = arguments;
    }

    /**
	 * Returns a <em>Map&lt;String, Object&gt;</em> containing the parameters of the
	 * event.
	 *
	 * @return A <em>Map&lt;String, Object&gt;</em> containing the parameters of the
	 *         event.
	 */
    public function getParams():PlatformStringMap<Dynamic> {
        return params;
    }

    public function hasParam(name:String):Bool {
        return params.exists(name);
    }

    public function getParam(name:String):Dynamic {
        return params.get(name);
    }
}
