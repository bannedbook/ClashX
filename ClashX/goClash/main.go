package main

import (
	"C"
	"encoding/json"
	"net"
	"path/filepath"
	"strconv"
	"strings"

	"github.com/Dreamacro/clash/config"
	"github.com/Dreamacro/clash/constant"
	"github.com/Dreamacro/clash/hub/executor"
	"github.com/Dreamacro/clash/hub/route"
	"github.com/Dreamacro/clash/log"
	"github.com/oschwald/geoip2-golang"
	"github.com/phayes/freeport"
)

func isAddrValid(addr string) bool {
	if addr != "" {
		comps := strings.Split(addr, ":")
		v := comps[len(comps)-1]
		if port, err := strconv.Atoi(v); err == nil {
			if port > 0 && port < 65535 {
				return true
			}
		}
	}
	return false
}

//export initClashCore
func initClashCore() {
	configFile := filepath.Join(constant.Path.HomeDir(), constant.Path.Config())
	constant.SetConfig(configFile)
}

func parseDefaultConfigThenStart(checkPort, allowLan bool) (*config.Config, error) {
	cfg, err := executor.Parse()
	if err != nil {
		return nil, err
	}
	if checkPort {
		if !isAddrValid(cfg.General.ExternalController) {
			port, err := freeport.GetFreePort()
			if err != nil {
				return nil, err
			}
			cfg.General.ExternalController = "127.0.0.1:" + strconv.Itoa(port)
			cfg.General.Secret = ""
		}
		cfg.General.AllowLan = allowLan
	}
	go route.Start(cfg.General.ExternalController, cfg.General.Secret)

	executor.ApplyConfig(cfg, true)
	return cfg, nil
}

//export verifyClashConfig
func verifyClashConfig(content *C.char) *C.char {

	b := []byte(C.GoString(content))
	cfg, err := executor.ParseWithBytes(b)
	if err != nil {
		return C.CString(err.Error())
	}

	if len(cfg.Proxies) < 1 {
		return C.CString("No proxy found in config")
	}
	return C.CString("success")
}

//export run
func run(checkConfig, allowLan bool) *C.char {
	cfg, err := parseDefaultConfigThenStart(checkConfig,allowLan)
	if err != nil {
		return C.CString(err.Error())
	}

	portInfo := map[string]string{
		"externalController": cfg.General.ExternalController,
		"secret":             cfg.General.Secret,
	}

	jsonString, err := json.Marshal(portInfo)
	if err != nil {
		return C.CString(err.Error())
	}

	return C.CString(string(jsonString))
}

//export setUIPath
func setUIPath(path *C.char) {
	route.SetUIPath(C.GoString(path))
}

//export clashUpdateConfig
func clashUpdateConfig(path *C.char) *C.char {
	cfg, err := executor.ParseWithPath(C.GoString(path))
	if err != nil {
		return C.CString(err.Error())
	}
	executor.ApplyConfig(cfg, false)
	return C.CString("success")
}

//export clashGetConfigs
func clashGetConfigs() *C.char {
	general := executor.GetGeneral()
	jsonString, err := json.Marshal(general)
	if err != nil {
		return C.CString(err.Error())
	}
	return C.CString(string(jsonString))
}

//export verifyGEOIPDataBase
func verifyGEOIPDataBase() bool {
	mmdb, err := geoip2.Open(constant.Path.MMDB())
	if err != nil {
		log.Warnln("mmdb fail:%s", err.Error())
		return false
	}

	_, err = mmdb.Country(net.ParseIP("114.114.114.114"))
	if err != nil {
		log.Warnln("mmdb lookup fail:%s", err.Error())
		return false
	}
	return true
}

func main() {
}
