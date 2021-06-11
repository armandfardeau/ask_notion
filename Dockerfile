FROM crystallang/crystal:latest
WORKDIR /workdir
COPY . .
RUN shards install
RUN crystal build --release --static src/app.cr
EXPOSE 8080
ENV PORT 8080
CMD ["./app"]
