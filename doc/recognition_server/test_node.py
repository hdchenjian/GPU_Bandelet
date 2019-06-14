#!/usr/bin/python
# -*- coding: utf-8 -*-

import requests
from hashlib import md5
import datetime

host = 'http://120.79.161.218:5055'

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
    params = {
        'name': u'张三',
        'user_id': 'e10adc3949ba59abbe56e057f20f883e',
        'remark': 'test'
    }
    files = {'image': ('1.jpg', open('1.jpg', 'rb'), 'image/jpeg')}
    ret = requests.post(host + url, params=params, files=files)
    print(ret.content)

    
def test_recognition():
    url = '/recognition_user'
    files = {'image': ('2.jpg', open('2.jpg', 'rb'), 'image/jpeg')}
    ret = requests.post(host + url, params={}, files=files)
    print(ret.content)


def test_update_feature_info():
    url = '/update_feature_info'
    params = {'feature_id': 1000, 'name': u'李四', 'user_id': 'e10adc3949ba59abbe56e057f20f883e', 'remark': 'test'}
    files = {'image': ('2.jpg', open('2.jpg', 'rb'), 'image/jpeg')}
    ret = requests.post(host + url, params=params, files=files)
    print(ret.content)


def test_delete_feature():
    url = '/delete_feature'
    ret = requests.post(host + url, params={'feature_id': 1000})
    print(ret.content)


def test_delete_user_all_feature():
    url = '/delete_user_all_feature'
    ret = requests.post(host + url, params={'user_id': 'e10adc3949ba59abbe56e057f20f883e'})
    print(ret.content)


def test_get_all_feature():
    url = '/get_all_feature'
    ret = requests.get(host + url)
    print(ret.content)


def test_get_feature_picture():
    url = '/get_feature_picture?picture_id=a7d6b7cf40a34d039cc9312fca1e1004'
    ret = requests.get(host + url)
    #print(ret.content)


if __name__ == '__main__':
    #test_recognition()
    #test_register()
    #test_update_feature_info()
    #test_delete_feature()
    #test_delete_user_all_feature()
    test_get_all_feature()
    #test_get_feature_picture()
