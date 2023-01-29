from fastapi import APIRouter, HTTPException, Request
from fastapi.responses import HTMLResponse

from customresponses import crud, settings
from customresponses.dependencies import templates

router = APIRouter()


@router.get("/", response_class=HTMLResponse)
async def index(request: Request):
    return templates.TemplateResponse("index.html", {"request": request})


@router.get("/create", tags=["create"], response_class=HTMLResponse)
async def create(request: Request):
    return templates.TemplateResponse(
        "create.html", {"request": request, "settings": settings}
    )


@router.get("/modify/{id}", tags=["modify"], response_class=HTMLResponse)
async def modify(id: str, request: Request):
    cr = crud.get_cr_from_redis(key=id)
    if not cr:
        raise HTTPException(
            status_code=404, detail="Custom response with the id '{id}' not found."
        )
    return templates.TemplateResponse(
        "modify.html",
        {
            "request": request,
            "settings": settings,
            "respId": id,
            "alias": cr["alias"],
            "status_code": cr["status_code"],
            "ctype": cr["ctype"],
            "content": cr["content"],
        },
    )


@router.get("/list", tags=["list"], response_class=HTMLResponse)
async def list(request: Request, cursor: int = 0, prev: str = ""):

    prevs = prev.split(",")
    click_prev = ",".join(prevs)[:-1].strip(",")
    no_click_prev = f"{prev},{cursor}".strip(",")
    prev_cursor = prevs[-1] if prevs[-1].isdigit() else -1
    new_cursor, data = crud.scan_redis(cursor=cursor, count=settings.LIST_VIEW_ITEMS)

    custom_responses = []
    for x in data:
        cr = crud.get_cr_from_redis(key=x)
        custom_responses.append(cr)

    return templates.TemplateResponse(
        "list.html",
        {
            "request": request,
            "custom_responses": custom_responses,
            "new_cursor": new_cursor,
            "prev_cursor": prev_cursor,
            "click_prev": click_prev,
            "no_click_prev": no_click_prev,
        },
    )
