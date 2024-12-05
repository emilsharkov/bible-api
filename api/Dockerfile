FROM denoland/deno:alpine
WORKDIR /app
COPY . .
RUN deno install
RUN cd /src
EXPOSE 80
CMD ["deno", "task", "dev"]