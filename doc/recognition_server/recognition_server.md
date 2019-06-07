## 云端人脸识别接口文档

### Api 测试地址: http://120.79.161.218:5055

说明: 所有 api 返回为 json 格式, 比如:
```json
{
    "code": 0, // 0: 成功; 其他数字: 失败
    "error": "", //供多语言使用
    "detail": "",
    "data": {}  // json 格式返回数据
}
```

### 签名认证

* 所有接口需中请求头中加入 "Device_id" 字段, 该字段用来验证用户身份

* 所有 api 请求都需要签名认证。

* 使用 "请求api url" "当前时间" "app_key" "app_secret" 来计算出签名。将签名放到 http 请求的 headers 里
  发送到服务器，服务器端使用同样的方法对签名进行验证

#### 签名计算方法

调用 api 时，在 http 请求 header 里添加 `Authorization APP_KEY:SIGNATURE`。
其中 SIGNATURE 的计算方法为 `md5(API&DATE&APP_SECRET)`。

相应参数说明：

| 参数 | 说明 | 示例 |
| ---- | ---- | ---- |
| API | 不包含 host和参数 部分的 api 地址 | /register_user |
| DATE | 当前世界ISO格式 | 2019-06-07T23:29:44.647641 |
| APP_KEY | 当前版本的 key | de13da9feb449ef11e98f9a6c4b90040 |
| APP_SECRET | 当前版本的 secret | dfbec30sdfdfn0916cb419c82703ddd6 |
| md5 | 字符串加密算法 |  |
| Device_id | 用户唯一标识 | 00163e0cd5fb |

#### 请求示例, 下面为注册接口示例:

```
API: /register_user
DATE: 2019-06-07T23:34:21.529118
APP_KEY: de13da9feb449ef11e98f9a6c4b90040
APP_SECRET: dfbec30sdfdfn0916cb419c82703ddd6

签名字符串为: /register_user&2019-06-07T23:34:21.529118&dfbec30sdfdfn0916cb419c82703ddd6
md5该字符串后得到: 9e58f46a6edabb9e43816e4c6d52036c
则请求 headers 为: {"Date": "2019-06-07T23:34:21.529118", "Authorization": "de13da9feb449ef11e98f9a6c4b90040:9e58f46a6edabb9e43816e4c6d52036c", "Device_id": "00163e0cd5fb"}
```

## 错误码

| 错误码 | 错误信息 | 含义 | status code |
| --- | --- | --- | --- |
| 999 | `unknow_error` | 未知错误 | 200 |
| 1000 | `uri_not_found` | 资源不存在 | 200 |
| 1001 | `missing_args` | 参数不全 | 200 |
| 1002 | `bad_signature` | 签名错误 | 200 |
| 1003 | `bad_device_id` | 设备Id错误 | 200 |
| 1004 | `registration_failed` | 注册失败 | 200 |
| 1005 | `recognition_failed` | 识别失败 | 200 |

### 提交一张JPG格式的图片注册

#### URL

`/register_user`

#### Method

`POST`

### Request Body
```json
{
    'name': '张三'
}
{
    'image': open('1.jpg', 'rb'),     // Multipart-Encoded JPG图片
}
```

#### Success Response

```json
{
    "code": 0,
    "error": "",
    "detail": "",
    "data": {"user_id": 1003}
}

```



### 识别一张JPG格式的图片

#### URL

`/recognition_user`

#### Method

`POST`

### Request Body
```json
{
    'image': open('1.jpg', 'rb'),     // Multipart-Encoded JPG图片
}
```

#### Success Response

```json
{
    "code": 0,
    "error": "",
    "detail": "",
    "data": [{"user_id": 1000, "name": "张三", "location": [1390, 611, 2452, 1892]},
             {"user_id": 1001, "name": "李四", "location": [465, 138, 790, 567]}]
}
// location 字段为人脸框位置，四个坐标分别为: 左上点横坐标(距左边界的距离), 左上点纵坐标(距上边界的距离),
//                                            右下点横坐标(距左边界的距离), 右下点纵坐标(距上边界的距离)
```



### 跟新用户信息

#### URL

`/update_user_info`

#### Method

`POST`

### Request Body
```json
{
    'user_id': 1000,
    'name': u'李四'   // 将id为 1000 的用户重命名未 李四
}
```

#### Success Response

```json
{
    "code": 0,
    "error": "",
    "detail": "",
    "data": {}
}
```



### 删除用户

#### URL

`/delete_user`

#### Method

`POST`

### Request Body
```json
{
    'user_id': 1000,  // 将id为 1000 的用户删除
}
```

#### Success Response

```json
{
    "code": 0,
    "error": "",
    "detail": "",
    "data": {}
}
```


### 查询所有注册用户

#### URL

`/get_all_user`

#### Method

`GET`

#### Success Response

```json
{
    "code": 0,
    "error": "",
    "detail": "",
    "data": [{"user_id": 1000, "user_name": "张三", "head_image": "/get_person_head_picture?picture_id=88b6b3c2831e40a7853eb207c64d1000"},
             {"user_id": 1001, "user_name": "李四", "head_image": "/get_person_head_picture?picture_id=6a7a95ef807a42d8a9ade47642521001"},]
}
// head_image 字段为用户头像，可用该URL获取用户头像
```


### 获取用户头像

#### URL

`/get_person_head_picture?picture_id=6a7a95ef807a42d8a9ade47642521001`

#### Method

`GET`

#### Success Response

```
返回用户头像 'image/jpeg' 格式
```

