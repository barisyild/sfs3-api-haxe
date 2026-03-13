package com.smartfoxserver.v3.entities.data;
class Vec3DFloat extends Vec3D<Float> {
    public function new(ix:Float, iy:Float, iz:Float)
    {
        super(ix, iy, iz);
        useFloat = true;
    }
}
