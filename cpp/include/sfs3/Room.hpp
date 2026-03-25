#ifndef SFS3_ROOM_HPP
#define SFS3_ROOM_HPP

#include "SFS3_API.h"
#include "sfs3/Detail.hpp"
#include "sfs3/User.hpp"
#include <string>
#include <vector>

namespace sfs3 {

class Room {
    SFS3_Room* h_;
public:
    explicit Room(SFS3_Room* h = nullptr) : h_(h) {}
    Room(Room&& o) noexcept : h_(o.h_) { o.h_ = nullptr; }
    Room& operator=(Room&& o) noexcept { if (this != &o) { h_ = o.h_; o.h_ = nullptr; } return *this; }
    Room(const Room&) = delete;
    Room& operator=(const Room&) = delete;

    explicit operator bool() const { return h_ != nullptr; }
    SFS3_Room* handle() const { return h_; }

    int         getId()              const { return SFS3_Room_getId(h_); }
    std::string getName()            const { return detail::toStr(SFS3_Room_getName(h_)); }
    std::string getGroupId()         const { return detail::toStr(SFS3_Room_getGroupId(h_)); }
    bool        isJoined()           const { return SFS3_Room_isJoined(h_); }
    bool        isGame()             const { return SFS3_Room_isGame(h_); }
    bool        isHidden()           const { return SFS3_Room_isHidden(h_); }
    bool        isPasswordProtected() const { return SFS3_Room_isPasswordProtected(h_); }
    int         getUserCount()       const { return SFS3_Room_getUserCount(h_); }
    int         getMaxUsers()        const { return SFS3_Room_getMaxUsers(h_); }
    int         getSpectatorCount()  const { return SFS3_Room_getSpectatorCount(h_); }
    int         getMaxSpectators()   const { return SFS3_Room_getMaxSpectators(h_); }
    int         getCapacity()        const { return SFS3_Room_getCapacity(h_); }

    std::string getVariable(const char* name) const {
        return h_ ? detail::toStr(SFS3_Room_getVariable_string(h_, name)) : "";
    }

    std::vector<User> getUsers() const {
        std::vector<User> v;
        int n = SFS3_Room_getUserListCount(h_);
        v.reserve(n);
        for (int i = 0; i < n; i++)
            v.emplace_back(SFS3_Room_getUserAt(h_, i));
        return v;
    }
};

} // namespace sfs3

#endif // SFS3_ROOM_HPP
