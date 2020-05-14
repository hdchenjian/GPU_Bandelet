#!/usr/bin/python
# -*- coding: utf-8 -*-

import requests
import base64

host = 'http://localhost:5055'

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
    all_face = ret.json()['all_face']
    print(len(all_face))
    for _face in all_face:
        print(_face['remark'])
        face_data = base64.decodebytes(_face['picture'].encode('ascii'))
        with open('face_' + _face['remark'] + '.jpg', 'wb') as f:
            f.write(face_data)
    #print(ret.content)


if __name__ == '__main__':
    #test_user()
    #test_registration_face()
    #test_recognition_face()
    test_get_registration_face()
