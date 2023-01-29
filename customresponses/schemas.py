from uuid import uuid4

from pydantic import BaseModel, Field, validator

from customresponses import settings


def generate_uuid() -> str:
    return "cr_" + str(uuid4()).replace("-", "")


class CustomResponse(BaseModel):
    id: str = Field(default_factory=generate_uuid)
    alias: str
    status_code: int
    ctype: str
    content: str

    @validator("id")
    def validator_id(cls, v):
        if not settings.ID_REGEX.match(v):
            raise ValueError("Malformed ID.")
        return v

    @validator("alias")
    def validate_alias(cls, v):
        if not settings.ALIAS_REGEX.match(v):
            raise ValueError("Alias contains invalid characters.")
        if len(v) > settings.ALIAS_MAXLEN:
            raise ValueError(
                f"Alias cannot be longer than {settings.ALIAS_MAXLEN} characters."
            )
        return v

    @validator("status_code")
    def validate_status_code(cls, v):
        if settings.STATUS_CODE_MIN <= v <= settings.STATUS_CODE_MAX:
            return v
        raise ValueError(
            f"Status code must be between {settings.STATUS_CODE_MIN} and {settings.STATUS_CODE_MAX}."
        )

    @validator("ctype")
    def validate_ctype(cls, v):
        if not settings.CTYPE_REGEX.match(v):
            raise ValueError("Invalid content-type.")
        if len(v) > settings.CTYPE_MAXLEN:
            raise ValueError(
                f"Content-Type cannot be longer than {settings.CTYPE_MAXLEN} characters."
            )
        return v

    @validator("content")
    def validate_content(cls, v):
        if len(v) > settings.CONTENT_MAXLEN:
            raise ValueError(
                f"Content cannot be longer than {settings.CONTENT_MAXLEN} characters."
            )
        return v
