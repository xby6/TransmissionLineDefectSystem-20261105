# CPU inference for the selected x86_64 server; no CUDA/MMCV compilation.
FROM python:3.10-slim-bookworm

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_DEFAULT_TIMEOUT=300 \
    MPLBACKEND=Agg \
    YOLO_AUTOINSTALL=false
WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends libglib2.0-0 libgomp1 \
    && rm -rf /var/lib/apt/lists/*

RUN python -m pip install --no-cache-dir --upgrade pip==25.3 setuptools==79.0.1 wheel==0.45.1 \
    && python -m pip install --no-cache-dir --no-deps \
       torch==2.5.1+cpu torchvision==0.20.1+cpu \
       --index-url https://download.pytorch.org/whl/cpu

COPY requirements-docker-lock.txt ./
RUN python -m pip install --no-cache-dir -r requirements-docker-lock.txt \
    && python -m pip check

# Keep the bundled custom ultralytics 8.3.9 and its CPU deformable operators.
COPY . .
RUN mkdir -p logs \
    && ln -s /app/logs/app.log /app/app.log \
    && python -c "import ultralytics; assert ultralytics.__version__ == '8.3.9'; from nets.deeplabv3_plus import DeepLab"

EXPOSE 8000
CMD ["python", "app/main.py"]
