# API

### Информация о публичном ассете

`GET /api/assets/:id`

##### Params
Name | Type | Description
---- | ---- | -----------
id | Integer | Уникальный идентификатор ассета

##### Authentication
User

##### Response
```
Status: 200

{
  "asset": {
    "id": 185,
    "file": "http://s3.amazonaws.com/pulscen_development/public_assets/000/000/185/2fc7__sports-q-c-1920-1895-3.jpg",
    "origin_file_name": "sports-q-c-1920-1895-3.jpg",
    "file_size": 395316,
    "file_content_type": "image/jpeg"
  }
}
```
