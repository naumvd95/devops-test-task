FROM golang:1.13.6-alpine3.11 as base
RUN apk add --no-cache git gcc musl-dev dep make wget

# Use temporary image layer to archive binaries.
FROM base as bincache
ENV HELM_VERSION ${HELM_VERSION:-"v3.2.4"}
ENV GOLANGCI_LINT_VERSION ${GOLANGCI_LINT_VERSION:-"1.24.0"}
ENV KUBECTL_VERSION ${KUBECTL_VERSION:-"v1.15.1"}

RUN apk add --no-cache xz \
    && wget https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz -O - | tar -xzO linux-amd64/helm > /usr/local/bin/helm \
    && chmod +x /usr/local/bin/helm \
    && wget https://github.com/golangci/golangci-lint/releases/download/v${GOLANGCI_LINT_VERSION}/golangci-lint-${GOLANGCI_LINT_VERSION}-linux-amd64.tar.gz -O - | \
      tar -xzO golangci-lint-${GOLANGCI_LINT_VERSION}-linux-amd64/golangci-lint > /usr/local/bin/golangci-lint \
    && chmod +x /usr/local/bin/golangci-lint \
    && wget https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl -O /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl

FROM base
COPY --from=bincache /usr/local/bin/golangci-lint /usr/local/bin/golangci-lint
COPY --from=bincache /usr/local/bin/helm /usr/local/bin/helm
COPY --from=bincache /usr/local/bin/kubectl /usr/local/bin/kubectl

RUN apk add --no-cache bash coreutils file docker openssh-client openssl
