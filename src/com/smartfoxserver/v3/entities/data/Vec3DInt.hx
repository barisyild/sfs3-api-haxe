package com.smartfoxserver.v3.entities.data;
class Vec3DInt extends Vec3D<Int> {
    public function new(ix:Int = 0, iy:Int = 0, iz:Int = 0)
    {
        super(ix, iy, iz);
        useFloat = false;
    }
}
