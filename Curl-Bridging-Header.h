//
//  Curl-Bridging-Header.h
//  homik
//
//  Created by kyb on 13/10/2016.
//  Copyright © 2016 Suborbital Softowrks Ltd. All rights reserved.
//
//mostly stolen from https://github.com/PureSwift/SeeURL/blob/d3e63b0d3c04948aacb9109129ea613eeefad374/cURLSwift.h

#include <curl/curl.h>
static __inline__ CURLcode curl_easy_setopt_string(CURL *curl, CURLoption option, const char *param) {
    return curl_easy_setopt(curl, option, param);
}

static __inline__ CURLcode curl_easy_setopt_long(CURL *curl, CURLoption option, long param) {
    return curl_easy_setopt(curl, option, param);
}

typedef size_t (*curl_func)(char * ptr, size_t size, size_t num, void * ud);

static __inline__  size_t curl_dummy_func(char * ptr, size_t size, size_t num, void * ud) {
    return size * num;
}

static __inline__ CURLcode curl_easy_setopt_func(CURL *handle) {
    return curl_easy_setopt(handle, CURLOPT_WRITEFUNCTION, curl_dummy_func);
}

