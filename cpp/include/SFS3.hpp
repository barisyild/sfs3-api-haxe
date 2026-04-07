/*
 * SFS3.hpp — Header-only C++17 OOP wrapper over SFS3_API.h
 *
 * Master include — pulls in every class in namespace sfs3.
 * You can also include individual headers from sfs3/ if preferred.
 *
 * Usage:
 *   #include "SFS3.hpp"
 *
 *   sfs3::init();
 *   sfs3::SmartFox sfs;
 *   sfs3::ConfigData cfg;
 *   cfg.setHost("127.0.0.1").setPort(9977).setZone("MyZone");
 *   sfs.connect(cfg);
 *
 * All classes are move-only RAII wrappers. Destructors release C handles.
 * Link against SFS3_API.lib exactly as before — no rebuild needed.
 */

#ifndef SFS3_HPP
#define SFS3_HPP

#include "sfs3/Detail.hpp"
#include "sfs3/User.hpp"
#include "sfs3/Room.hpp"
#include "sfs3/MMOItem.hpp"
#include "sfs3/SFSObject.hpp"
#include "sfs3/SFSArray.hpp"
#include "sfs3/Event.hpp"
#include "sfs3/ConfigData.hpp"
#include "sfs3/SmartFox.hpp"

namespace sfs3 {

// ── Free functions (lifecycle) ──────────────────────────────────────────

inline void init()                        { SFS3_init(); }
inline void dispose()                     { SFS3_dispose(); }
inline void gc()                          { SFS3_gc(); }
inline void update(double dt)             { SFS3_update(dt); }
inline void registerThread()              { SFS3_registerThread(); }
inline void setLogLevel(SFS3_LogLevel lv) { SFS3_setLogLevel(lv); }

} // namespace sfs3

#endif // SFS3_HPP
