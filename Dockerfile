FROM crystallang/crystal:latest as builder
WORKDIR /workdir
COPY ./src/ .
RUN crystal build --release --static app.cr

FROM busybox
WORKDIR /api
EXPOSE 8080
ENV PORT 8080
COPY --from=builder /workdir/app .
CMD ["./app"]
