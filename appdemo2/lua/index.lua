local nixio = require "nixio"
local dbus = require "luci.dbus"
local json = require "luci.json"
local http = require "luci.http"
local util  = require "luci.util"
local ksutil = require "luci.ksutil"
local httpclient = require "luci.httpclient"

module("luci.controller.apps.appdemo2.index", package.seeall)

function index()
	entry({"appdemo2"}, call("action_appdemo2"))
	entry({"appdemo2", "status"}, call("action_appdemo2_status"))
	entry({"appdemo2", "https-test"}, call("action_https"))
	entry({"appdemo2", "mount-test"}, call("action_mount"))
	-- error("string expected")
end

function action_appdemo2()
    ksutil.shell_action("appdemo2")
end

function action_appdemo2_status()
    http.prepare_content("text/plain; charset=utf-8")
    reader = ksutil.popen("/koolshare/scripts/appdemo2-config.sh status", nil)
    luci.ltn12.pump.all(reader, luci.http.write)
end

function action_https()
    forms = http.formvalue()
    for k,v in pairs(forms) do
        util.perror("k: " .. k .. " v: " .. tostring(v))
    end
	local b = httpclient.request_to_buffer("https://koolshare.ngrok.wang/softcenter/config.json.js")
	http.prepare_content("application/json")
	http.write(b)
end

function action_mount()
	local data = {}
	local k = {"fs", "blocks", "used", "available", "percent", "mountpoint"}
	local ps = util.execi("df")

	if not ps then
		return
	else
		ps()
	end

	for line in ps do
		local row = {}

		local j = 1
		for value in line:gmatch("[^%s]+") do
			row[k[j]] = value j = j + 1
		end

		if row[k[1]] then

			-- this is a rather ugly workaround to cope with wrapped lines in
			-- the df output:
			--
			--	/dev/scsi/host0/bus0/target0/lun0/part3
			--                   114382024  93566472  15005244  86% /mnt/usb
			--

			if not row[k[2]] then
				j = 2
				line = ps()
				for value in line:gmatch("[^%s]+") do
					row[k[j]] = value
					j = j + 1
				end
			end

			table.insert(data, row)
		end
	end

    http.prepare_content("application/json")
    local js = json.encode(data)
    http.write(js)
end

