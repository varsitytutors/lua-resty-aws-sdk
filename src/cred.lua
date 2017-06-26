local http = require 'resty.http'
local json = require 'cjson'
local _M = {}

function _M.from_env()
    local key_id = os.getenv('AWS_ACCESS_KEY_ID')
    local secret = os.getenv('AWS_SECRET_ACCESS_KEY')
    local session_token = os.getenv('AWS_SESSION_TOKEN')

    if not key_id or not secret then
        return nil, 'not found'
    end

    return {
        key = key_id,
        secret = secret,
        session_token = session_token
    }
end



function _M.from_iam_role(role_name, host)
    host = host or '169.254.169.254'
    local httpc = http.new()
    local ok, code, headers, status, b = httpc:request('http://' .. host .. '/latest/meta-data/iam/security-credentials/' .. role_name)

    if status == 404 then
        return nil, 'iam role not found'
    end

    if status ~= 200 then
        return nil, res.b
    end

    local body = json.decode(b)

    return {
        key = body['AccessKeyId'],
        secret = body['SecretAccessKey'],
        session_token = body['Token']
    }
end



return _M

