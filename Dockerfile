# --- build the React bundle ---------------------------------------------------
FROM node:22-bookworm AS build
WORKDIR /app

# Dependencies first so this layer is cached between builds
COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn/releases .yarn/releases
RUN node .yarn/releases/yarn-4.5.1.cjs install --immutable

COPY public public
COPY src src
# CI=false: create-react-app otherwise fails the build on lint warnings
RUN CI=false node .yarn/releases/yarn-4.5.1.cjs build

# --- serve it, proxying the backend prefixes to the API ------------------------
FROM nginx:1.27-alpine
COPY deploy/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build /usr/share/nginx/html
EXPOSE 80
