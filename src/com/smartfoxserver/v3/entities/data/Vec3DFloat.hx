package com.smartfoxserver.v3.entities.data;
@:expose("SFS3.Vec3D")
class Vec3DFloat extends Vec3D<Float> {
    public function new(ix:Float = 0, iy:Float = 0, iz:Float = 0)
    {
        super(ix, iy, iz);
        useFloat = true;
    }
}
