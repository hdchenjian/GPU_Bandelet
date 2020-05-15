#!/usr/bin/python
# -*- coding: utf-8 -*-

import requests
import base64

host = 'http://47.91.129.200:5055'

def test_registration_face():
    data = {'remark': 'test'}
    files = {'image': open('test/1.jpg', 'rb')}
    ret = requests.post(host+'/registration_face', params=data, files=files)
    print(ret.content)


def test_recognition_face():
    files = {'image': open('test/2.jpg', 'rb')}
    ret = requests.post(host+'/recognition_face', files=files)
    print(ret.content)


def test_get_registration_face():
    ret = requests.get(host+'/get_registration_face')
    all_face = ret.json()['data']['all_face']
    print(len(all_face))
    index = 10000
    for _face in all_face:
        print(_face['remark'])
        aa = _face['picture'].encode('ascii')
        face_data = base64.decodebytes(_face['picture'].encode('ascii'))
        with open('face_' + _face['remark'] + '_' + str(index) + '.jpg', 'wb') as f:
            f.write(face_data)
        index += 1
    #print(ret.content)


def test_delete_registration_face():
    ret = requests.post(host+'/delete_registration_face', params={'face_id': 1003})
    print(ret.content)


if __name__ == '__main__':
    #test_registration_face()
    #test_delete_registration_face()
    #test_recognition_face()
    test_get_registration_face()
