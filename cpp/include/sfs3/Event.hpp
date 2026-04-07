#ifndef SFS3_EVENT_HPP
#define SFS3_EVENT_HPP

#include "SFS3_API.h"
#include "sfs3/Detail.hpp"
#include "sfs3/User.hpp"
#include "sfs3/Room.hpp"
#include "sfs3/MMOItem.hpp"
#include "sfs3/SFSObject.hpp"
#include <string>
#include <vector>

namespace sfs3 {

class Event {
    SFS3_Event* h_;
public:
    explicit Event(SFS3_Event* h) : h_(h) {}

    std::string getType() const { return detail::toStr(SFS3_Event_getType(h_)); }

    bool        getBool(const char* key)   const { return SFS3_Event_getBool(h_, key); }
    int         getInt(const char* key)    const { return SFS3_Event_getInt(h_, key); }
    std::string getString(const char* key) const { return detail::toStr(SFS3_Event_getString(h_, key)); }
    double      getDouble(const char* key)  const { return SFS3_Event_getDouble(h_, key); }
    int         getLagValue()              const { return SFS3_Event_getLagValue(h_); }
    User        getUser(const char* key)   const { return User(SFS3_Event_getUser(h_, key)); }
    Room        getRoom(const char* key)   const { return Room(SFS3_Event_getRoom(h_, key)); }
    SFSObject   getSFSObject(const char* key) const { return SFSObject(SFS3_Event_getSFSObject(h_, key)); }

    int getUserListCount(const char* key) const { return SFS3_Event_getUserListCount(h_, key); }
    User getUserAt(const char* key, int i) const { return User(SFS3_Event_getUserAt(h_, key, i)); }
    std::vector<User> getUserList(const char* key) const {
        std::vector<User> v;
        int n = getUserListCount(key);
        v.reserve(n);
        for (int i = 0; i < n; i++) v.emplace_back(SFS3_Event_getUserAt(h_, key, i));
        return v;
    }

    int getMMOItemCount(const char* key) const { return SFS3_Event_getMMOItemCount(h_, key); }
    MMOItem getMMOItemAt(const char* key, int i) const { return MMOItem(SFS3_Event_getMMOItemAt(h_, key, i)); }
    std::vector<MMOItem> getMMOItemList(const char* key) const {
        std::vector<MMOItem> v;
        int n = getMMOItemCount(key);
        v.reserve(n);
        for (int i = 0; i < n; i++) v.emplace_back(SFS3_Event_getMMOItemAt(h_, key, i));
        return v;
    }

    int getStringListCount(const char* key) const { return SFS3_Event_getStringListCount(h_, key); }
    std::string getStringListAt(const char* key, int i) const { return detail::toStr(SFS3_Event_getStringListAt(h_, key, i)); }
    std::vector<std::string> getStringList(const char* key) const {
        std::vector<std::string> v;
        int n = getStringListCount(key);
        v.reserve(n);
        for (int i = 0; i < n; i++) v.push_back(getStringListAt(key, i));
        return v;
    }
};

} // namespace sfs3

#endif // SFS3_EVENT_HPP
