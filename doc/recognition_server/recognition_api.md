## 云端人脸识别接口文档

### Api 测试地址: http://47.91.129.200:5055

说明: 所有 api 返回为 json 格式, 比如:
```json
{
    "code": 0, // 0: 成功; 其他数字: 失败
    "error": "",
    "detail": "",
    "data": {}  // 返回的数据
}
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


## API:

#### api_001注册, 图片可为 jpg、 png等格式, 由于 jpg 格式压缩比较高,图片较小,建议使用jpg格式

##### URL

`/registration_face?remark=test`

##### Method

`POST`

#### url 参数

```
{
    "remark": "test"   // 识别成功原样返回
}

#### Request Body

// files:
{
    "image": ("1.jpg", open("1.jpg", "rb"), "image/jpeg"),     // Multipart-Encoded JPG图片
}
```

##### Success Response

```json
{
    "code": 0,
    "error": "",
    "detail": "",
    "data": {}
}

```



#### api_002识别一张JPG格式的图片

##### URL

`/recognition_face`

##### Method

`POST`

#### url 参数

```
{}  // 无参数
```

#### Request Body
```json
// files:
{
    "image": ("1.jpg", open("1.jpg", "rb"), "image/jpeg"),     // Multipart-Encoded JPG图片
}
```

##### Success Response

```json
{
    "code": 0,
    "error": "",
    "detail": "",
    "data": {"recognition_face": [{"remark": "test", "picture": "9j4AAQSk"}
    // 返回得分排序前五,当只注册一张图片时recognition_face array 长度为 1
    // remark: remark 为注册时提交,原样返回, picture：base64编码的图片
}
```


#### api_003查询所有注册图片

##### URL

`/get_registration_face`

##### Method

`GET`

#### url 参数

```
{}  // 无参数
```

##### Success Response

```json
{
    "code": 0,
    "error": "",
    "detail": "",
    "data": {"all_face": [{"face_id": 1001, "picture": "9j4AAQSk", "remark": "test"},
                          {"face_id": 1002, "picture": "9j4AAQSk", "remark": "test"}]}
    // remark: remark 为注册时提交,原样返回, picture：base64编码的图片
}
```

#### api_004删除注册图片

##### URL

`/get_registration_face`

##### Method

`GET`

#### url 参数

```
{
    "face_id"  // get_registration_face 接口返回的face_id
}
```

##### Success Response

```json
{
    "code": 0,
    "error": "",
    "detail": "",
    "data": {}
}
```
