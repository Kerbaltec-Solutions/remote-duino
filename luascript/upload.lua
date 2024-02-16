local cjson = require "cjson"
local http = require "resty.http"

ngx.log(ngx.INFO, "Lua script started")

-- Log the incoming request
local function log_request(request)
    ngx.log(ngx.INFO, "Incoming request: ", request)
end

-- Save the uploaded file to the shared volume
local function save_file(file)
    local path = "/rshared/upload/" .. file.filename
    local fh = io.open(path, "w+")
    if not fh then
        return nil, "failed to open file for writing"
    end
    fh:write(file.content)
    fh:close()
    return true
end

-- Send an HTTP request to the Python script
local function notify_python_script(file)
    local httpc = http.new()
    local res, err = httpc:request_uri("python_container:5000", {
        method = "POST",
        body = cjson.encode({ filename = file.filename }),
        headers = { ["Content-Type"] = "application/json" },
    })
    if not res then
        ngx.log(ngx.ERR, "Failed to notify Python script: ", err)
        return false
    end
    return true
end

-- Main handler
local chunk_size =  4096
local form, err = ngx.req.get_body_data()

log_request(form)

if not form then
    ngx.say("No body data")
    return
end

local boundary = ngx.var.content_type:match("boundary=(.+)")
if not boundary then
    ngx.say("Invalid multipart/form-data request")
    return
end

local parts = {}
for part in string.gmatch(form, "--" .. boundary .. "\r\n([^\r\n]+\r\n[^\r\n]+)\r\n--" .. boundary) do
    local headers, body = part:match("([^\r\n]+\r\n)([^\r\n]+)")
    local filename = headers:match("filename=\"([^\"]+)\"")
    if filename then
        local file = {
            filename = filename,
            content = body
        }
        local ok, err = save_file(file)
        if not ok then
            ngx.say("Failed to save file: ", err)
            return
        end
        local ok = notify_python_script(file)
        if not ok then
            ngx.say("Failed to notify Python script")
            return
        end
    end
end

ngx.say("File uploaded successfully")
