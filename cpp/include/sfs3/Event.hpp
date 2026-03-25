#ifndef SFS3_EVENT_HPP
#define SFS3_EVENT_HPP

#include "SFS3_API.h"
#include "sfs3/Detail.hpp"
#include "sfs3/User.hpp"
#include "sfs3/Room.hpp"
#include <string>

namespace sfs3 {

class Event {
    SFS3_Event* h_;
public:
    explicit Event(SFS3_Event* h) : h_(h) {}

    std::string getType() const { return detail::toStr(SFS3_Event_getType(h_)); }

    bool        getBool(const char* key)   const { return SFS3_Event_getBool(h_, key); }
    int         getInt(const char* key)    const { return SFS3_Event_getInt(h_, key); }
    std::string getString(const char* key) const { return detail::toStr(SFS3_Event_getString(h_, key)); }
    User        getUser(const char* key)   const { return User(SFS3_Event_getUser(h_, key)); }
    Room        getRoom(const char* key)   const { return Room(SFS3_Event_getRoom(h_, key)); }
};

} // namespace sfs3

#endif // SFS3_EVENT_HPP
