#ifndef SFS3_CONFIGDATA_HPP
#define SFS3_CONFIGDATA_HPP

#include "SFS3_API.h"
#include <string>

namespace sfs3 {

class ConfigData {
    SFS3_ConfigData* h_;

    void ensure() {
        if (!h_) {
            h_ = SFS3_ConfigData_create();
            SFS3_ConfigData_setBlueBoxActive(h_, false);
        }
    }

public:
    ConfigData() : h_(nullptr) {}
    ~ConfigData() { if (h_) SFS3_ConfigData_release(h_); }

    ConfigData(ConfigData&& o) noexcept : h_(o.h_) { o.h_ = nullptr; }
    ConfigData& operator=(ConfigData&& o) noexcept { if (this != &o) { if (h_) SFS3_ConfigData_release(h_); h_ = o.h_; o.h_ = nullptr; } return *this; }
    ConfigData(const ConfigData&) = delete;
    ConfigData& operator=(const ConfigData&) = delete;

    SFS3_ConfigData* handle() const { return h_; }

    ConfigData& setHost(const char* v)          { ensure(); SFS3_ConfigData_setHost(h_, v); return *this; }
    ConfigData& setPort(int v)                  { ensure(); SFS3_ConfigData_setPort(h_, v); return *this; }
    ConfigData& setUdpPort(int v)               { ensure(); SFS3_ConfigData_setUdpPort(h_, v); return *this; }
    ConfigData& setHttpPort(int v)              { ensure(); SFS3_ConfigData_setHttpPort(h_, v); return *this; }
    ConfigData& setHttpsPort(int v)             { ensure(); SFS3_ConfigData_setHttpsPort(h_, v); return *this; }
    ConfigData& setZone(const char* v)          { ensure(); SFS3_ConfigData_setZone(h_, v); return *this; }
    ConfigData& setUseSSL(bool v)               { ensure(); SFS3_ConfigData_setUseSSL(h_, v); return *this; }
    ConfigData& setUseWebSocket(bool v)         { ensure(); SFS3_ConfigData_setUseWebSocket(h_, v); return *this; }
    ConfigData& setUseTcpFallback(bool v)       { ensure(); SFS3_ConfigData_setUseTcpFallback(h_, v); return *this; }
    ConfigData& setUseTcpNoDelay(bool v)        { ensure(); SFS3_ConfigData_setUseTcpNoDelay(h_, v); return *this; }
    ConfigData& setTcpConnectionTimeout(int v)  { ensure(); SFS3_ConfigData_setTcpConnectionTimeout(h_, v); return *this; }
    ConfigData& setBlueBoxActive(bool v)        { ensure(); SFS3_ConfigData_setBlueBoxActive(h_, v); return *this; }

    std::string getHost() const { if (!h_) return ""; auto c = SFS3_ConfigData_getHost(h_); return c ? c : ""; }
    int         getPort() const { return h_ ? SFS3_ConfigData_getPort(h_) : 0; }
    std::string getZone() const { if (!h_) return ""; auto c = SFS3_ConfigData_getZone(h_); return c ? c : ""; }
};

} // namespace sfs3

#endif // SFS3_CONFIGDATA_HPP
