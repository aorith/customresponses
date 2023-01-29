import re

ID_REGEX = re.compile(r"^cr_[a-z0-9]{32}$")

ALIAS_REGEX = re.compile(r"""^[a-zA-Z0-9][a-zA-Z0-9'_ -]+$""")
ALIAS_MAXLEN = 80

CTYPE_DEFAULT = "text/html"
CTYPE_REGEX = re.compile(r"^[a-zA-Z0-9]+/.+")
CTYPE_MAXLEN = 55

STATUS_CODE_DEFAULT = 200
STATUS_CODE_MIN = 200
STATUS_CODE_MAX = 599

CONTENT_MAXLEN = 15000

LIST_VIEW_ITEMS = 6
