#!/usr/bin/python
# -*- coding: utf-8 -*-

import requests
from hashlib import md5
import datetime

host = 'http://localhost:5055'

app_key = 'de13da9feb449ef11e98f9a6c4b90040'
app_secret = 'dfbec30sdfdfn0916cb419c82703ddd6'

def get_headers(uri):
    date_str = datetime.datetime.now().isoformat()
    sign_list = [uri, date_str, app_secret]
    print('&'.join(sign_list), md5('&'.join(sign_list)).hexdigest())
    headers = {
        'Authorization': ':'.join(
            [app_key, md5('&'.join(sign_list)).hexdigest()]),
        'Date': date_str,
        'device_id': '00163e0cd5fb'
    }
    #print headers, '&'.join(sign_list)
    return headers


def test_register():
    url = '/register_user'
    data = {
        'name': u'张三'
    }
    files = {'image': open('1.jpg', 'rb')}
    print(get_headers(url))
    ret = requests.post(host + url, data=data, files=files, headers = get_headers(url))
    print(ret.content)

    
def test_recognition():
    url = '/recognition_user'
    files = {'image': open('2.jpg', 'rb')}
    ret = requests.post(host + url, data={}, files=files, headers = get_headers(url))
    print(ret.content)


def test_update_user_info():
    url = '/update_user_info'
    ret = requests.post(host + url, data={'user_id': 1000, 'name': u'李四'}, headers = get_headers(url))
    print(ret.content)


def test_delete_user():
    url = '/delete_user'
    ret = requests.post(host + url, data={'user_id': 1003}, headers = get_headers(url))
    print(ret.content)


def test_get_all_user():
    url = '/get_all_user'
    ret = requests.get(host + url, headers = get_headers(url))
    print(ret.content)


def test_get_person_head_picture():
    url = '/get_person_head_picture?picture_id=88b6b3c2831e40a7853eb207c64d1000'
    ret = requests.get(host + url, headers = get_headers('/get_person_head_picture'))
    #print(ret.content)


if __name__ == '__main__':
    #test_recognition()
    #test_register()
    #test_update_user_info()
    #test_delete_user()
    test_get_all_user()
    #test_get_person_head_picture()
