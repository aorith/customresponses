from fastapi import APIRouter, HTTPException, Response

from customresponses import crud, schemas

router = APIRouter()


@router.post(
    "/v1/customresponse",
    tags=["customresponse"],
    status_code=201,
    response_model=schemas.CustomResponse,
)
async def create_response(customResponse: schemas.CustomResponse) -> dict:
    cr = crud.get_cr_from_redis(key=customResponse.id)
    if cr is not None:
        raise HTTPException(
            status_code=409,
            detail=f"Item already exists: /v1/customreponse/{customResponse.id}",
        )
    return crud.create_response(customResponse=customResponse)


@router.put(
    "/v1/customresponse/{id}",
    tags=["customresponse"],
)
async def modify_response(id: str, customResponse: schemas.CustomResponse):
    cr = crud.get_cr_from_redis(key=id)
    if cr is None:
        raise HTTPException(
            status_code=404, detail=f"Custom response with the id='{id}' not found."
        )

    try:
        crud.save_to_redis(key=id, data=dict(customResponse))
        return customResponse
    except Exception as err:
        return HTTPException(
            status_code=500,
            detail=f"unknown error: {repr(err)}",
        )


@router.get(
    "/v1/customresponse/{id}",
    tags=["customresponses"],
)
async def get(id: str):
    cr = crud.get_cr_from_redis(key=id)
    if cr is None:
        raise HTTPException(
            status_code=404, detail=f"Custom response with the id='{id}' not found."
        )
    return cr


@router.get(
    "/v1/customresponse/{id}/r",
    tags=["customresponses"],
)
async def get_raw(id: str):
    cr = crud.get_cr_from_redis(key=id)
    if cr is None:
        raise HTTPException(
            status_code=404, detail=f"Custom response with the id='{id}' not found."
        )
    status_code = int(cr["status_code"])
    return Response(
        content=cr["content"], media_type=cr["ctype"], status_code=status_code
    )


@router.delete(
    "/v1/customresponse/{id}",
    tags=["customresponses"],
)
async def delete_response(id: str):
    cr = crud.get_cr_from_redis(key=id)
    if cr is None:
        raise HTTPException(
            status_code=404, detail=f"Custom response with the id='{id}' not found."
        )
    if crud.delete_from_redis(key=id):
        return Response(
            status_code=200,
            content='{"detail": "deleted"}',
            media_type="application/json",
        )

    return HTTPException(
        status_code=500,
        detail="unknown error",
    )
