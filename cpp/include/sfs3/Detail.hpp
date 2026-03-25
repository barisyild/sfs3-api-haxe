#ifndef SFS3_DETAIL_HPP
#define SFS3_DETAIL_HPP

#include "SFS3_API.h"
#include <string>

namespace sfs3 {
namespace detail {

inline std::string toStr(SFS3_String s) {
    const char* c = SFS3_String_cstr(s);
    std::string r = c ? c : "";
    SFS3_String_release(&s);
    return r;
}

} // namespace detail
} // namespace sfs3

#endif // SFS3_DETAIL_HPP
