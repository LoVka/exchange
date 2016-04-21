Exchange JSON API
=================

## Start application

    $ ruby rails s

## Initialize bank

```shell
$ curl -X POST "localhost:3000/api/banks" \
$   --data "content[50]=4&content[25]=10&content[10]=18"

{"content":{"50":2,"25":10,"10":18}}
```

## Exchange amount

```shell
$ curl -X GET "localhost:3000/api/exchange?amount=200" \

{"exchange":{"50":2,"25":4}}
```
