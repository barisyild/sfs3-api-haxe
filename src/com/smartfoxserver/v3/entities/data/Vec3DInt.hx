package com.smartfoxserver.v3.entities.data;
class Vec3DInt extends Vec3D<Int> {
    public function new(ix:Int, iy:Int, iz:Int)
    {
        super(ix, iy, iz);
        useFloat = false;
    }
}
