local ksutil = require "luci.ksutil"

module("luci.controller.apps.appdemo2.index", package.seeall)

function index()
	entry({"appdemo2"}, call("action_appdemo2"))
end

function action_appdemo2()
    ksutil.shell_action("appdemo2")
end

