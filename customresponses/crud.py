from typing import List

from customresponses import schemas
from customresponses.database import redis_client


def save_to_redis(key: str, data: dict) -> int:
    return redis_client.hset(name=key, mapping=data)


def delete_from_redis(key: str) -> int:
    return redis_client.delete(key)


def get_from_redis(key: str, field: str) -> str | None:
    val = redis_client.hget(name=key, key=field)
    if isinstance(val, bytes):
        val = val.decode(encoding="utf-8")
    return val


def scan_redis(
    cursor: int = 0, count: int = 10, match: str = "cr_*", type: str = "hset"
) -> tuple[int, List]:
    new_cursor, data = redis_client.scan(
        cursor=cursor, match=match, count=count, type=type
    )
    data = [x.decode(encoding="utf-8") for x in data if x is not None]
    return new_cursor, data


def get_cr_from_redis(key: str) -> dict | None:
    alias = get_from_redis(key=key, field="alias")
    if alias is None:
        return None

    return dict(
        id=key,
        alias=alias,
        status_code=get_from_redis(key=key, field="status_code"),
        ctype=get_from_redis(key=key, field="ctype"),
        content=get_from_redis(key=key, field="content"),
    )


def create_response(customResponse: schemas.CustomResponse) -> dict:
    custom_response = dict(
        id=customResponse.id,
        alias=customResponse.alias,
        status_code=customResponse.status_code,
        ctype=customResponse.ctype,
        content=customResponse.content,
    )
    save_to_redis(key=customResponse.id, data=custom_response)
    return custom_response
