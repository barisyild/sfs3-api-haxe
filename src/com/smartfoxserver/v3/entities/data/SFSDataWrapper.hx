package com.smartfoxserver.v3.entities.data;

class SFSDataWrapper {
    private var typeId:SFSDataType;
    private var object:Dynamic;

    public function new(typeId:SFSDataType, object:Dynamic) {
        this.typeId = typeId;
        this.object = object;
    }

    public function getTypeId():SFSDataType {
        return this.typeId;
    }

    public function getObject():Dynamic {
        return this.object;
    }
}
