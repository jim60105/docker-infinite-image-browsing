# syntax=docker/dockerfile:1
ARG UID=1001
ARG VERSION=EDGE
ARG RELEASE=0

FROM python:3.10-slim as base

# RUN mount cache for multi-arch: https://github.com/docker/buildx/issues/549#issuecomment-1788297892
ARG TARGETARCH
ARG TARGETVARIANT

# Install dependencies
RUN --mount=type=cache,id=apt-$TARGETARCH$TARGETVARIANT,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,id=aptlists-$TARGETARCH$TARGETVARIANT,sharing=locked,target=/var/lib/apt/lists \
    apt-get update && apt-get install -y --no-install-recommends \
    # https://pillow.readthedocs.io/en/stable/installation/building-from-source.html
    libjpeg62-turbo-dev libwebp-dev zlib1g-dev

FROM base as build

ARG TARGETARCH
ARG TARGETVARIANT

# Install build dependencies
RUN --mount=type=cache,id=apt-$TARGETARCH$TARGETVARIANT,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,id=aptlists-$TARGETARCH$TARGETVARIANT,sharing=locked,target=/var/lib/apt/lists \
    apt-get install -y --no-install-recommends build-essential

WORKDIR /app

# Install under /root/.local
ENV PIP_USER="true"
ARG PIP_NO_WARN_SCRIPT_LOCATION=0
ARG PIP_ROOT_USER_ACTION="ignore"
ARG PIP_NO_COMPILE="true"
ARG PIP_DISABLE_PIP_VERSION_CHECK="true"

# Install requirements
RUN --mount=type=cache,id=pip-$TARGETARCH$TARGETVARIANT,sharing=locked,target=/root/.cache/pip \
    --mount=source=sd-webui-infinite-image-browsing/requirements.txt,target=requirements.txt,rw \
    pip install -U --force-reinstall pip setuptools wheel && \
    pip install -r requirements.txt dumb-init

# Replace pillow with pillow-simd (Only for x86)
ARG TARGETPLATFORM
RUN --mount=type=cache,id=pip-$TARGETARCH$TARGETVARIANT,sharing=locked,target=/root/.cache/pip \
    if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
    pip uninstall -y pillow && \
    CC="cc -mavx2" pip install -U --force-reinstall pillow-simd; \
    fi

# Cleanup
RUN find "/root/.local" -name '*.pyc' -print0 | xargs -0 rm -f || true ; \
    find "/root/.local" -type d -name '__pycache__' -print0 | xargs -0 rm -rf || true ;

FROM base as final

# We don't need them anymore
RUN pip uninstall -y setuptools pip wheel && \
    rm -rf /root/.cache/pip

# ffmpeg
COPY --link --from=mwader/static-ffmpeg:6.1.1 /ffmpeg /usr/local/bin/
COPY --link --from=mwader/static-ffmpeg:6.1.1 /ffprobe /usr/local/bin/

# Create user
ARG UID
RUN groupadd -g $UID $UID && \
    useradd -l -u $UID -g $UID -m -s /bin/sh -N $UID

# Create directories with correct permissions
RUN install -d -m 775 -o $UID -g 0 /outputs && \
    install -d -m 775 -o $UID -g 0 /licenses && \
    install -d -m 775 -o $UID -g 0 /app

# Copy licenses (OpenShift Policy)
COPY --link --chmod=775 LICENSE /licenses/Dockerfile.LICENSE
COPY --link --chmod=775 sd-webui-infinite-image-browsing/LICENSE /licenses/sd-webui-infinite-image-browsing.LICENSE

# Copy dependencies and code (and support arbitrary uid for OpenShift best practice)
COPY --link --chown=$UID:0 --chmod=775 --from=build /root/.local /home/$UID/.local
COPY --link --chown=$UID:0 --chmod=775 sd-webui-infinite-image-browsing /app

# Create config file
COPY <<EOF /config.json
{
    "outdir_txt2img_samples": "/outputs/txt2img",
    "outdir_img2img_samples": "/outputs/img2img",
    "outdir_extras_samples": "/outputs/extras",
    "outdir_txt2img_grids": "/outputs/txt2img-grids",
    "outdir_img2img_grids": "/outputs/img2img-grids",
    "outdir_save": "/outputs/saved"
}
EOF

COPY <<EOF /app/.env
IIB_ACCESS_CONTROL=enable
IIB_ACCESS_CONTROL_ALLOWED_PATHS=txt2img,img2img,extra,save
IIB_ACCESS_CONTROL_PERMISSION=read-only
EOF

ENV PATH="/home/$UID/.local/bin:$PATH"
ENV PYTHONPATH="${PYTHONPATH}:/home/$UID/.local/lib/python3.10/site-packages:/app"

# Remove these to prevent the container from executing arbitrary commands
RUN rm /bin/echo /bin/ln /bin/rm /bin/sh

WORKDIR /app

VOLUME [ "/output", "/tmp" ]

EXPOSE 80

USER $UID

STOPSIGNAL SIGINT

# Use dumb-init as PID 1 to handle signals properly
ENTRYPOINT ["dumb-init", "--", "python3", "app.py", "--host", "0.0.0.0", "--port", "80", "--sd_webui_config", "/config.json"]

ARG VERSION
ARG RELEASE
LABEL name="jim60105/docker-infinite-image-browsing" \
    # Authors for infinite-image-browsing
    vendor="zanllp" \
    # Maintainer for this docker image
    maintainer="jim60105" \
    # Dockerfile source repository
    url="https://github.com/jim60105/docker-infinite-image-browsing" \
    version=${VERSION} \
    # This should be a number, incremented with each change
    release=${RELEASE} \
    io.k8s.display-name="infinite-image-browsing" \
    summary="Stable Diffusion webui Infinite Image Browsing: About A fast and powerful image/video browser for Stable Diffusion webui / ComfyUI / Fooocus, featuring infinite scrolling and advanced search capabilities using image parameters. It also supports standalone operation." \
    description="It's not just an image browser, but also a powerful image manager. Precise image search combined with multi-selection operations allows for filtering/archiving/packaging, greatly increasing efficiency. It also supports running in standalone mode, without the need for SD-Webui. For more information about this tool, please visit the following website: https://github.com/zanllp/sd-webui-infinite-image-browsing."