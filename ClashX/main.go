package main // import "github.com/yichengchen/clashX/ClashX"
import (
	"C"

	"github.com/Dreamacro/clash/config"
	Cc "github.com/Dreamacro/clash/constant"
	"github.com/Dreamacro/clash/hub"
)

var (
	homedir string
)

//export run
func run() *C.char {

	if err := config.Init(Cc.Path.HomeDir()); err != nil {
		return C.CString(err.Error())
	}

	if err := hub.Parse(); err != nil {
		return C.CString(err.Error())
	}

	return C.CString("success")
}

func main() {

}
