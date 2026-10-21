FROM python:3.11-slim-bookworm

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_DEFAULT_TIMEOUT=300
WORKDIR /app

COPY requirements-local-lock.txt ./
RUN python -m pip install --no-cache-dir -r requirements-local-lock.txt \
    && python -m pip check

COPY . .
EXPOSE 9099
CMD ["python", "docker_entrypoint.py"]
