## 云端人脸识别接口文档

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
API: /register_user
DATE: 2019-06-07T23:34:21.529118
APP_KEY: de13da9feb449ef11e98f9a6c4b90040
APP_SECRET: dfbec30sdfdfn0916cb419c82703ddd6

签名字符串为: /register_user&2019-06-07T23:34:21.529118&dfbec30sdfdfn0916cb419c82703ddd6
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

`/register_user?group_id=abc&name=张三&user_id=e10adc3949ba59abbe56e057f20f883e&remark=test`

##### Method

`POST`

#### url 参数

```
{
    "group_id": "abc",  // 最长255个字符
    "name": "张三",
    "user_id": "e10adc3949ba59abbe56e057f20f883e",  // 最长255个字符,作为设备端标示用户,一个用户可注册多张图片, 识别成功返回该字段
    "remark": "test"   // 最长255个字符, 识别成功返回该字段
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
    "data": {"feature_id": 1003}
}

```



#### api_002识别一张JPG格式的图片

##### URL

`/recognition_user?group_id=abc`

##### Method

`POST`

#### url 参数

```
{
    "group_id": "abc",  // 不传该字段时,识别时匹配所有注册用户特征,传该字段时,只匹配该分组中的用户
}
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
    "data": [{"feature": [{"feature_id": 2225, "name": "张三", "user_id": "abc", "group_id": "abc", "remark": "test", "score": 0.632254},
                          {"feature_id": -1, "score": -1, "name": "", "user_id": "", "group_id": "", "remark": ""},
                          {"feature_id": -1, "score": -1, "name": "", "user_id": "", "group_id": "", "remark": ""}],
              "location": [230, 305, 725, 970],
              "threshold": 0.61}
            ]
// 返回得分排序前三, threshold为当前分组阈值, score为对应feature_id得分, feature_id为-1时为不存在的特征
// user_id 和 remark 为注册时提交,原样返回
// location 字段为人脸框位置,四个坐标分别为: 左上点横坐标(距左边界的距离), 左上点纵坐标(距上边界的距离),
//                                       右下点横坐标(距左边界的距离), 右下点纵坐标(距上边界的距离)
}
```


#### api_003查询所有注册用户

##### URL

`/get_all_feature?group_id=abc&user_id=abc`

##### Method

`GET`

#### url 参数

```
{
    "group_id": "abc", // group_id为可选参数,传此参数时返回分组中所有特征信息
    "user_id": "abc",  // user_id为可选参数,传此参数时返回该用户所有注册特征信息
}
```

##### Success Response

```json
{
    "code": 0,
    "error": "",
    "detail": "",
    "data": [{"feature_id": 1000, "user_name": "张三", "user_id": "abc", "remark": "test", "picture_id": "88b6b3c2831e40a7853eb207c64d1000"},
             {"feature_id": 1001, "user_name": "张三", "user_id": "abc", "remark": "test", "picture_id": "6a7a95ef807a42d8a9ade47642521001"},]
}
// picture_id 字段为用户注册时的图片,可用来获取用户头像
```


#### api_004获取注册时提交的图片

##### URL

`/get_feature_picture?picture_id=6a7a95ef807a42d8a9ade47642521001`

##### Method

`GET`

##### Success Response

```
返回用户头像, "image/jpeg" 格式
```


#### api_005更新用户信息

##### URL

`/update_feature_info?group_id=abc&feature_id=1000&name=李四&user_id=e10adc3949ba59abbe56e057f20f883e&remark=test`

##### Method

`POST`

#### url 参数

```
{
    "feature_id": 1000,
    "group_id": "abc", // 将feature_id为 1000 的用户移至 abc 分组中,不想更新该字段可传空字符串
    "name": "李四"   // 将feature_id为 1000 的用户重命名为 李四, 不想更新该字段可传空字符串
    "user_id": "a10adc3949ba59abbe56e057f20f883e",  // 不想更新该字段可传空字符串
    "remark": "test"  // 不想更新该字段可传空字符串
}
```

#### Request Body
```json
// files, 更新用户特征时需传新的图片,若只想更新用户姓名则不传
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


#### api_006删除用户特征

##### URL

`/delete_feature?group_id=abc&feature_id=1000`

##### Method

`POST`

#### url 参数

```
{
    "group_id": "abc",   // 可选参数,将该分组所有注册用户删除
    "feature_id": 1000,  // 可选参数,将feature_id为 1000 的用户特征删除
    "user_id": "abc",    // 可选参数,将该用户所有特征删除
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

#### api_007设置阈值, 默认值为0.6, 阈值范围为[0,1], 建议取值范围[0.55, 0.75]

##### URL

`/set_threshold?threshold=0.6`

##### Method

`POST`

##### Success Response

```json
{
    "code": 0,
    "error": "",
    "detail": "",
    "data": {}
}
```
