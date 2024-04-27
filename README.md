# docker-infinite-image-browsing

[![CodeFactor](https://www.codefactor.io/repository/github/jim60105/docker-infinite-image-browsing/badge?style=for-the-badge)](https://www.codefactor.io/repository/github/jim60105/docker-infinite-image-browsing) [![GitHub Workflow Status (with event)](https://img.shields.io/github/actions/workflow/status/jim60105/docker-infinite-image-browsing/scan.yml?label=IMAGE%20SCAN&style=for-the-badge)](https://github.com/jim60105/docker-infinite-image-browsing/actions/workflows/scan.yml)

This is the docker image for [Stable Diffusion webui Infinite Image Browsing: About A fast and powerful image/video browser for Stable Diffusion webui / ComfyUI / Fooocus, featuring infinite scrolling and advanced search capabilities using image parameters. It also supports standalone operation.](https://github.com/zanllp/sd-webui-infinite-image-browsing) from the community.

Get the Dockerfile at [GitHub](https://github.com/jim60105/docker-infinite-image-browsing), or pull the image from [ghcr.io](https://ghcr.io/jim60105/infinite-image-browsing) or [quay.io](https://quay.io/repository/jim60105/infinite-image-browsing?tab=tags).

https://github.com/jim60105/docker-infinite-image-browsing/assets/16995691/c636d348-cd39-458d-9e9d-483d114bc8c5

## Usage Command

- Copy `.env_example` to `.env`

  ```bash
  cp .env_example .env
  ```

- Set the outputs directory from the `AUTOMATIC1111/stable-diffusion-webui` in `.env` file.

  https://github.com/jim60105/docker-infinite-image-browsing/blob/83e9b218680258eadbb8813c17118f8c34631e13/.env#L1

- And then run the following command:

  ```bash
  docker compose up -d
  ```

### Build Command

> [!IMPORTANT]  
> Clone the Git repository recursively to include submodules:  
> `git clone --recursive https://github.com/jim60105/docker-infinite-image-browsing.git`

```bash
docker compose up -d --build
```

> [!NOTE]  
> If you are using an earlier version of the docker client, it is necessary to [enable the BuildKit mode](https://docs.docker.com/build/buildkit/#getting-started) when building the image. This is because I used the `COPY --link` feature which enhances the build performance and was introduced in Buildx v0.8.  
> With the Docker Engine 23.0 and Docker Desktop 4.19, Buildx has become the default build client. So you won't have to worry about this when using the latest version.

## LICENSE

> [!NOTE]  
> The main program, [zanllp/sd-webui-infinite-image-browsing](https://github.com/zanllp/sd-webui-infinite-image-browsing), is distributed under [MIT](https://github.com/zanllp/sd-webui-infinite-image-browsing/blob/main/LICENSE).  
> Please consult their repository for access to the source code and licenses.  
> The following is the license for the Dockerfiles and CI workflows in this repository.

<img src="https://github.com/jim60105/docker-infinite-image-browsing/assets/16995691/5f5ec9d1-3bb1-4b4b-bef7-77c5a33a0bb0" alt="agplv3" width="300" />

[GNU AFFERO GENERAL PUBLIC LICENSE Version 3](/LICENSE)

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.

> [!CAUTION]  
> An AGPLv3 licensed Dockerfile means that you ***MUST*** **distribute the source code with the same license**, if you
>
> - Re-distribute the image. (You can simply point to this GitHub repository if you doesn't made any code changes.)
> - Distribute a image that uses code from this repository.
> - Or **distribute a image based on this image**. (`FROM ghcr.io/jim60105/infinite-image-browsing` in your Dockerfile)
>
> "Distribute" means to make the image available for other people to download, usually by pushing it to a public registry. If you are solely using it for your personal purposes, this has no impact on you.
>
> Please consult the [LICENSE](LICENSE) for more details.
