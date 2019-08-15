token_secret = "pXFb4i%*834gfdh963df718iodGq4dsafsdadg7yI6ImF1999aaG7"

redis_config = {
    host = '172.16.29.95',
    port = 6379,
    auth_pwd = 'cWCVKJ7ZHUK12mVbivUf',
    db = 10,
}

check_auth_url = "http://172.16.29.98:8000/v1/authcheck/"

white_uri = {
    ["/api/mg/v1/login/"] = "172.16.29.98:8000/v1/login/",
    ["/api/mg/v1/logout/"] = "172.16.29.98:8000/v1/logout/",
    ["/api/mg/v1/authorization/"] = "172.16.29.98:8000/v1/authorization/"
}
