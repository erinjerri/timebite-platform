FROM python:3.13.5-slim AS runtime

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

RUN addgroup --system timebite && adduser --system --ingroup timebite timebite
WORKDIR /app
COPY backend/requirements.lock ./requirements.lock
RUN pip install --require-hashes=false -r requirements.lock
COPY backend/app ./backend/app
COPY backend/__init__.py ./backend/__init__.py
RUN chown -R timebite:timebite /app
USER timebite
EXPOSE 8000
CMD ["uvicorn", "backend.app.main:app", "--host", "0.0.0.0", "--port", "8000", "--proxy-headers"]
