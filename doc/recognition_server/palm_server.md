## 云端掌纹识别接口文档

### Api 测试地址: http://120.79.161.218:5055

说明: 所有 api 返回为 json 格式, 比如:
```json
{
    "code": 0, // 0: 成功; 其他数字: 失败
    "error": "",
    "detail": "",
    "data": {}  // 返回的数据
}
```

<!--

### 签名认证

* 所有接口需中请求头中加入 "Device_id" 字段, 该字段用来验证用户身份

* 所有 api 请求都需要签名认证。

* 使用 "请求api url" "当前时间" "app_key" "app_secret" 来计算出签名。将签名放到 http 请求的 headers 里
  发送到服务器,服务器端使用同样的方法对签名进行验证

#### 签名计算方法

调用 api 时,在 http 请求 header 里添加 `Authorization APP_KEY:SIGNATURE`。
其中 SIGNATURE 的计算方法为 `md5(API&DATE&APP_SECRET)`。

相应参数说明：

| 参数 | 说明 | 示例 |
| ---- | ---- | ---- |
| API | 不包含 host和参数 部分的 api 地址 | /register_user |
| DATE | 当前时间ISO格式 | 2019-06-07T23:29:44.647641 |
| APP_KEY | 签名 key | de13da9feb449ef11e98f9a6c4b90040 |
| APP_SECRET | 签名 secret | dfbec30sdfdfn0916cb419c82703ddd6 |
| md5 | 字符串加密算法 |  |
| Device_id | 用户唯一标识 | 00163e0cd5fb |

#### 请求示例, 下面为注册接口示例:

```
API: /register_palm
DATE: 2019-06-07T23:34:21.529118
APP_KEY: de13da9feb449ef11e98f9a6c4b90040
APP_SECRET: dfbec30sdfdfn0916cb419c82703ddd6

签名字符串为: /register_palm&2019-06-07T23:34:21.529118&dfbec30sdfdfn0916cb419c82703ddd6
md5该字符串后得到: 9e58f46a6edabb9e43816e4c6d52036c
则请求 headers 为: {"Date": "2019-06-07T23:34:21.529118",
                    "Device_id": "00163e0cd5fb",
                    "Authorization": "de13da9feb449ef11e98f9a6c4b90040:9e58f46a6edabb9e43816e4c6d52036c"}
```
-->

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

`/register_palm?name=abc&remark=test`

##### Method

`POST`

#### url 参数

```
{
    "name": "abc",
    "remark": "test"   // 识别成功返回该字段
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
    "data": {"palm_id": 1003}
}

```



#### api_002识别一张JPG格式的图片

##### URL

`/recognition_palm`

##### Method

`POST`

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
    "data": [{"score": 0.453032, "palm_id": 1003, "picture_url": "6462194e6ce645a48b549afa56451003", "remark": "test", "name": "aa"},
             {"remark": "", "score": -1.0, "picture_url": "", "name": "", "palm_id": 0},
             {"remark": "", "score": -1.0, "picture_url": "", "name": "", "palm_id": 0}
            ]
// 返回得分排序前三, score为对应palm_id得分, palm_id为-1时为不存在的特征
// remark 为注册时提交,原样返回
}
```


#### api_003获取注册时提交的图片

##### URL

`/get_palm_picture?picture_id=1dacab50e4bc45d58d6bfee318211002

##### Method

`GET`

##### Success Response

```
返回注册图片, "image/jpeg" 格式
```


#### api_004更新掌纹注册信息

##### URL

`/update_palm_feature?palm_id=1000&name=abc&remark=test`

##### Method

`POST`

#### url 参数

```
{
    "palm_id": 1000,
    "name": "李四"   // 将feature_id为 1000 的掌纹重命名为 abc, 不想更新该字段可传空字符串
    "remark": "test"  // 不想更新该字段可传空字符串
}
```

#### Request Body
```json
// files, 更新掌纹特征时需传新的图片,若只想更新用户姓名则不传
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


#### api_005删除指定掌纹

##### URL

`/delete_palm?palm_id=1000`

##### Method

`POST`

#### url 参数

```
{
    "palm_id": 1000,
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

#### api_006获取所有注册掌纹

##### URL

`/get_all_palm`

##### Method

`GET`

##### Success Response

```json
{
    "code": 0,
    "error": "",
    "detail": "",
    "data": [{"picture_id": "6462194e6ce645a48b549afa56451003", "remark": "test", "name": "aa", "palm_id": 1003},
             {"picture_id": "80be764768014c27b7203168037e1004", "remark": "test", "name": "aa", "palm_id": 1004}]
}
```
