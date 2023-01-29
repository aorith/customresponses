FROM python:3.11-slim

LABEL org.opencontainers.image.authors="aomanu@gmail.com"

ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

ARG USER=app
ARG USER_HOME=/app
ARG UID=1000
ARG GID=1000

RUN addgroup --gid ${GID} ${USER}
RUN adduser \
        --disabled-password \
        --gecos "App user" \
        --ingroup ${USER} \
        --uid ${UID} \
        --home ${USER_HOME} \
        ${USER}

WORKDIR ${USER_HOME}/code
USER ${UID}

ENV DBPATH=${USER_HOME}/db
RUN mkdir -p ${DBPATH}
VOLUME ${DBPATH}

ENV VIRTUAL_ENV="${USER_HOME}/venv"
RUN python3 -m venv "${VIRTUAL_ENV}"
ENV PATH="${VIRTUAL_ENV}/bin:${PATH}"

RUN pip install --no-cache-dir --upgrade pip && \
        pip install --no-cache-dir poetry

COPY --chown=${UID}:${GID} pyproject.toml poetry.lock ./
RUN poetry --no-cache install --no-root
COPY --chown=${UID}:${GID} customresponses ./customresponses
COPY --chown=${UID}:${GID} files ./files

ENTRYPOINT ["/usr/bin/env"]
