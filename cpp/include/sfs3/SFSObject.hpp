#ifndef SFS3_SFSOBJECT_HPP
#define SFS3_SFSOBJECT_HPP

#include "SFS3_API.h"
#include "sfs3/Detail.hpp"
#include <string>

namespace sfs3 {

class SFSObject {
    SFS3_SFSObject* h_;
    bool owned_;

    void ensure() { if (!h_) { h_ = SFS3_SFSObject_create(); owned_ = true; } }

public:
    SFSObject() : h_(nullptr), owned_(true) {}
    explicit SFSObject(SFS3_SFSObject* h, bool own = false) : h_(h), owned_(own) {}
    ~SFSObject() { if (owned_ && h_) SFS3_SFSObject_release(h_); }

    SFSObject(SFSObject&& o) noexcept : h_(o.h_), owned_(o.owned_) { o.h_ = nullptr; o.owned_ = false; }
    SFSObject& operator=(SFSObject&& o) noexcept {
        if (this != &o) { if (owned_ && h_) SFS3_SFSObject_release(h_); h_ = o.h_; owned_ = o.owned_; o.h_ = nullptr; o.owned_ = false; }
        return *this;
    }
    SFSObject(const SFSObject&) = delete;
    SFSObject& operator=(const SFSObject&) = delete;

    explicit operator bool() const { return h_ != nullptr; }
    SFS3_SFSObject* handle() const { return h_; }

    bool containsKey(const char* k) const { return h_ && SFS3_SFSObject_containsKey(h_, k); }
    int  size()                     const { return h_ ? SFS3_SFSObject_size(h_) : 0; }
    bool isNull(const char* k)      const { return !h_ || SFS3_SFSObject_isNull(h_, k); }

    SFSObject& putBool(const char* k, bool v)        { ensure(); SFS3_SFSObject_putBool(h_, k, v); return *this; }
    SFSObject& putByte(const char* k, int v)          { ensure(); SFS3_SFSObject_putByte(h_, k, v); return *this; }
    SFSObject& putShort(const char* k, int v)         { ensure(); SFS3_SFSObject_putShort(h_, k, v); return *this; }
    SFSObject& putInt(const char* k, int v)           { ensure(); SFS3_SFSObject_putInt(h_, k, v); return *this; }
    SFSObject& putLong(const char* k, long long v)    { ensure(); SFS3_SFSObject_putLong(h_, k, v); return *this; }
    SFSObject& putFloat(const char* k, float v)       { ensure(); SFS3_SFSObject_putFloat(h_, k, v); return *this; }
    SFSObject& putDouble(const char* k, double v)     { ensure(); SFS3_SFSObject_putDouble(h_, k, v); return *this; }
    SFSObject& putString(const char* k, const char* v){ ensure(); SFS3_SFSObject_putString(h_, k, v); return *this; }

    bool        getBool(const char* k)   const { return h_ && SFS3_SFSObject_getBool(h_, k); }
    int         getByte(const char* k)   const { return h_ ? SFS3_SFSObject_getByte(h_, k) : 0; }
    int         getShort(const char* k)  const { return h_ ? SFS3_SFSObject_getShort(h_, k) : 0; }
    int         getInt(const char* k)    const { return h_ ? SFS3_SFSObject_getInt(h_, k) : 0; }
    long long   getLong(const char* k)   const { return h_ ? SFS3_SFSObject_getLong(h_, k) : 0; }
    float       getFloat(const char* k)  const { return h_ ? SFS3_SFSObject_getFloat(h_, k) : 0.f; }
    double      getDouble(const char* k) const { return h_ ? SFS3_SFSObject_getDouble(h_, k) : 0.0; }
    std::string getString(const char* k) const { return h_ ? detail::toStr(SFS3_SFSObject_getString(h_, k)) : ""; }

    std::string toJson() const { return h_ ? detail::toStr(SFS3_SFSObject_toJson(h_)) : "{}"; }
    std::string getDump() const { return h_ ? detail::toStr(SFS3_SFSObject_getDump(h_)) : ""; }
};

} // namespace sfs3

#endif // SFS3_SFSOBJECT_HPP
