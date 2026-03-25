#ifndef SFS3_SFSARRAY_HPP
#define SFS3_SFSARRAY_HPP

#include "SFS3_API.h"
#include "sfs3/Detail.hpp"
#include <string>

namespace sfs3 {

class SFSArray {
    SFS3_SFSArray* h_;
    bool owned_;

    void ensure() { if (!h_) { h_ = SFS3_SFSArray_create(); owned_ = true; } }

public:
    SFSArray() : h_(nullptr), owned_(true) {}
    explicit SFSArray(SFS3_SFSArray* h, bool own = false) : h_(h), owned_(own) {}
    ~SFSArray() { if (owned_ && h_) SFS3_SFSArray_release(h_); }

    SFSArray(SFSArray&& o) noexcept : h_(o.h_), owned_(o.owned_) { o.h_ = nullptr; o.owned_ = false; }
    SFSArray& operator=(SFSArray&& o) noexcept {
        if (this != &o) { if (owned_ && h_) SFS3_SFSArray_release(h_); h_ = o.h_; owned_ = o.owned_; o.h_ = nullptr; o.owned_ = false; }
        return *this;
    }
    SFSArray(const SFSArray&) = delete;
    SFSArray& operator=(const SFSArray&) = delete;

    explicit operator bool() const { return h_ != nullptr; }
    SFS3_SFSArray* handle() const { return h_; }
    int size() const { return h_ ? SFS3_SFSArray_size(h_) : 0; }

    SFSArray& addBool(bool v)        { ensure(); SFS3_SFSArray_addBool(h_, v); return *this; }
    SFSArray& addByte(int v)         { ensure(); SFS3_SFSArray_addByte(h_, v); return *this; }
    SFSArray& addShort(int v)        { ensure(); SFS3_SFSArray_addShort(h_, v); return *this; }
    SFSArray& addInt(int v)          { ensure(); SFS3_SFSArray_addInt(h_, v); return *this; }
    SFSArray& addLong(long long v)   { ensure(); SFS3_SFSArray_addLong(h_, v); return *this; }
    SFSArray& addFloat(float v)      { ensure(); SFS3_SFSArray_addFloat(h_, v); return *this; }
    SFSArray& addDouble(double v)    { ensure(); SFS3_SFSArray_addDouble(h_, v); return *this; }
    SFSArray& addString(const char* v){ ensure(); SFS3_SFSArray_addString(h_, v); return *this; }

    bool        getBool(int i)   const { return h_ && SFS3_SFSArray_getBool(h_, i); }
    int         getByte(int i)   const { return h_ ? SFS3_SFSArray_getByte(h_, i) : 0; }
    int         getShort(int i)  const { return h_ ? SFS3_SFSArray_getShort(h_, i) : 0; }
    int         getInt(int i)    const { return h_ ? SFS3_SFSArray_getInt(h_, i) : 0; }
    long long   getLong(int i)   const { return h_ ? SFS3_SFSArray_getLong(h_, i) : 0; }
    float       getFloat(int i)  const { return h_ ? SFS3_SFSArray_getFloat(h_, i) : 0.f; }
    double      getDouble(int i) const { return h_ ? SFS3_SFSArray_getDouble(h_, i) : 0.0; }
    std::string getString(int i) const { return h_ ? detail::toStr(SFS3_SFSArray_getString(h_, i)) : ""; }

    std::string toJson() const { return h_ ? detail::toStr(SFS3_SFSArray_toJson(h_)) : "[]"; }
    std::string getDump() const { return h_ ? detail::toStr(SFS3_SFSArray_getDump(h_)) : ""; }
};

} // namespace sfs3

#endif // SFS3_SFSARRAY_HPP
