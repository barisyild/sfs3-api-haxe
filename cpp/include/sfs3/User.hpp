#ifndef SFS3_USER_HPP
#define SFS3_USER_HPP

#include "SFS3_API.h"
#include "sfs3/Detail.hpp"
#include <string>

namespace sfs3 {

class User {
    SFS3_User* h_;
public:
    explicit User(SFS3_User* h = nullptr) : h_(h) {}
    User(User&& o) noexcept : h_(o.h_) { o.h_ = nullptr; }
    User& operator=(User&& o) noexcept { if (this != &o) { h_ = o.h_; o.h_ = nullptr; } return *this; }
    User(const User&) = delete;
    User& operator=(const User&) = delete;

    explicit operator bool() const { return h_ != nullptr; }
    SFS3_User* handle() const { return h_; }

    int         getId()          const { return SFS3_User_getId(h_); }
    std::string getName()        const { return detail::toStr(SFS3_User_getName(h_)); }
    int         getPlayerId()    const { return SFS3_User_getPlayerId(h_); }
    bool        isPlayer()       const { return SFS3_User_isPlayer(h_); }
    bool        isSpectator()    const { return SFS3_User_isSpectator(h_); }
    int         getPrivilegeId() const { return SFS3_User_getPrivilegeId(h_); }
    bool        isGuest()        const { return SFS3_User_isGuest(h_); }
    bool        isStandardUser() const { return SFS3_User_isStandardUser(h_); }
    bool        isModerator()    const { return SFS3_User_isModerator(h_); }
    bool        isAdmin()        const { return SFS3_User_isAdmin(h_); }
    bool        isItMe()         const { return SFS3_User_isItMe(h_); }
};

} // namespace sfs3

#endif // SFS3_USER_HPP
