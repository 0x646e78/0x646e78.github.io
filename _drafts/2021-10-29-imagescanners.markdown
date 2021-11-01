---
layout: post
title:  "Image Vulnerability Scanners Compared, Pt1"
date:   2021-10-29 12:00:00 +1000
categories: programming linux security docker
---

I'm looking at the capabilities and results from three container image vulnerability scanners - Trivy, Snyk & AWS ECR Scanning.

In this first segment I look at set up of the scans and gather vulnerability results for both a patched and unpatched image. 
In part 2 I will have a look at which appears to be more accurate in it's findings, and other available features such as misconfiguration detection.


## Introducing the tools

### Trivy


Trivy is an open source vulnerability & misconfiguration scanner maintained by Aqua Security, 
and is very quick and easy to get started.

 - [Homepage](https://github.com/aquasecurity/trivy)
 - [Installation steps](https://aquasecurity.github.io/trivy/v0.20.2/getting-started/overview/)

```
❯ trivy --version
Version: 0.20.2
```

Run with:

```
trivy <image> # for a table to stdout
trivy -q -f json <image> # for json output
```

A finding (in json) looks like this:
```
  {
    "VulnerabilityID": "CVE-2021-22945",
    "PkgName": "curl",
    "InstalledVersion": "7.78.0-r0",
    "FixedVersion": "7.79.0-r0",
    "Layer": {
      "DiffID": "sha256:a1920ef522ec8f49831ef40db2c3ad4777da04239270e6698d1674ebb90c8c82"
    },
    "SeveritySource": "nvd",
    "PrimaryURL": "https://avd.aquasec.com/nvd/cve-2021-22945",
    "Title": "curl: use-after-free and double-free in MQTT sending",
    "Description": "When sending data to an MQTT server, libcurl <= 7.73.0 and 7.78.0 could in some circumstances erroneously keep a pointer to an already freed memory area and bo
th use that again in a subsequent call to send data and also free it *again*.",
    "Severity": "CRITICAL",
    "CweIDs": [
      "CWE-415"
    ],
    "CVSS": {
      "nvd": {
        "V2Vector": "AV:N/AC:M/Au:N/C:P/I:N/A:P",
        "V3Vector": "CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:N/A:H",
        "V2Score": 5.8,
        "V3Score": 9.1
      },
      "redhat": {
        "V3Vector": "CVSS:3.1/AV:N/AC:H/PR:N/UI:N/S:U/C:H/I:N/A:H",
        "V3Score": 7.4
      }
    },
    "References": [
      "https://curl.se/docs/CVE-2021-22945.html",
      "https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2021-22945",
      "https://hackerone.com/reports/1269242",
      "https://lists.fedoraproject.org/archives/list/package-announce@lists.fedoraproject.org/message/RWLEC6YVEM2HWUBX67SDGPSY4CQB72OE/",
      "https://security.netapp.com/advisory/ntap-20211029-0003/",
      "https://ubuntu.com/security/notices/USN-5079-1",
      "https://www.oracle.com/security-alerts/cpuoct2021.html"
    ],
    "PublishedDate": "2021-09-23T13:15:00Z",
    "LastModifiedDate": "2021-10-29T13:15:00Z"
  },
```

As well as vulnerability findings Trivy (in it's json output) provides a lot of information about the image,
including the build steps and layer history, image env, cmd, entry-pont, distro version etc. There's quite 
a lot so I'm not pasting it here, but I do recommend having a look at this.

I will use the following jq filter to show succinct vulnerability information:
```
jq '.Results[].Vulnerabilities[] | {"ID": .VulnerabilityID, "name": .Title, "severity": .Severity, "pkgname": .PkgName, "installedversion": .InstalledVersion, "fixedversion": .FixedVersion}'
```

**Pricing**: Open Source / Free
 

### Snyk


Snyk is a vulnerability scanner and SaaS. They provide a range of capabilities such as open source dependency scans,
IaC and container scanning.

 - [Homepage](https://snyk.io/)
 - [Installation steps](https://docs.snyk.io/features/snyk-cli/install-the-snyk-cli)

```
❯ snyk --version
1.745.0 (standalone)
```

Run with:

```
docker scan <image>
```

There is a json output, but I like the grepable output and bundling of vulnerabilities presented by default on the CLI
for what I'm doing here.  More information is available in json by passing in `--json` if desired.

A finding  looks like:

```
✗ Critical severity vulnerability found in curl/libcurl
  Description: Double Free
  Info: https://snyk.io/vuln/SNYK-ALPINE313-CURL-1585246
  Introduced through: curl/libcurl@7.78.0-r0, curl/curl@7.78.0-r0
  From: curl/libcurl@7.78.0-r0
  From: curl/curl@7.78.0-r0 > curl/libcurl@7.78.0-r0
  From: curl/curl@7.78.0-r0
  Fixed in: 7.79.0-r0
```

**Pricing**: Free for individuals and small teams, this has some limitations in features available which don't affect this CLI type of testing.


### AWS ECR


AWS has an image scanning capability, which can be used to scan images within an AWS ECR repository. According to their docs "Each container image may be scanned once per 24 hours. Amazon ECR uses the Common Vulnerabilities and Exposures (CVEs) database from the open-source Clair project"

- [Homepage](https://docs.aws.amazon.com/AmazonECR/latest/userguide/image-scanning.html)

Log into an ECR registry with the docker client. See the [AWS Docs](https://docs.aws.amazon.com/AmazonECR/latest/userguide/docker-push-ecr-image.html)

Create a repository if you haven't already. See the [AWS Docs](https://docs.aws.amazon.com/AmazonECR/latest/userguide/repository-create.html)

ECR scans from the registry, so you need to push to the repository, set off a scan and then retrieve the results:

``` 
docker tag nginxlab:latest account.dkr.ecr.region.amazonaws.com/nginxlab:latest
docker push account.dkr.ecr.region.amazonaws.com/nginxlab:latest
aws ecr start-image-scan --repository-name nginxlab --image-id imageTag=latest
aws ecr describe-image-scan-findings --repository-name nginxlab --image-id imageTag=latest
```

A finding looks like this:

```
{
  "name": "CVE-2021-22947",
  "uri": "https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2021-22947",
  "severity": "MEDIUM",
  "attributes": [
    {
      "key": "package_version",
      "value": "7.78.0-r0"
    },
    {
      "key": "package_name",
      "value": "curl"
    },
    {
      "key": "CVSS2_VECTOR",
      "value": "AV:N/AC:M/Au:N/C:N/I:P/A:N"
    },
    {
      "key": "CVSS2_SCORE",
      "value": "4.3"
    }
  ]
},
```

...feels a bit sparse to me.

Summary information is also presented:

```
    "imageScanCompletedAt": "2021-11-01T11:58:01+11:00",
    "vulnerabilitySourceUpdatedAt": "2021-11-01T03:11:25+11:00",
    "findingSeverityCounts": {
      "MEDIUM": 3,
      "LOW": 2
    }
  },
  "registryId": "1234567890",
  "repositoryName": "nginxlab",
  "imageId": {
    "imageDigest": "sha256:b6e9f2d1354314363eb6c5afce9a186214afe2c5f1767dbc3397b1c87bcb3745",
    "imageTag": "latest"
  },
  "imageScanStatus": {
    "status": "COMPLETE",
    "description": "The scan was completed successfully."
  }
}
```

**Pricing**: From what I can tell ECR vulnerability scanning doesn't incur a charge, but I can't find any docs on this.
The [ECR Pricing doc](https://aws.amazon.com/ecr/pricing/) suggests fees are only for the amount of data stored or transferred. Probably for a small self-hosted
project this might be a few dollars per month. If you're an organisation running builds thousands of times per day and have
to upload each image to ECR before a vuln scan step then it could start to add up.

I will be using the following jq filter to present a succinct view of the findings from ECR:

```
jq '.imageScanFindings.findings[] | {"id": .name,"severity": .severity,"pkgname": .attributes[1].value,"installedversion":.attributes[0].value}'
```

# First Image - Nginx Alpine

Running a basic health check endpoint and no configurations altered.

## Unpatched

No OS upgrades applied via APK.

```
FROM nginx:1.20-alpine
RUN echo 'server {location /health {default_type text/plain; return 200 "OK";}}' \
    > /etc/nginx/conf.d/default.conf
```

Built with `docker build . -t nginxlab:latest`

### Trivy

2 Critical, 2 High, 3 Medium

```
{
  "id": "CVE-2021-22945",
  "name": "curl: use-after-free and double-free in MQTT sending",
  "severity": "CRITICAL",
  "pkgname": "curl",
  "installedversion": "7.78.0-r0",
  "fixedversion": "7.79.0-r0"
}
{
  "id": "CVE-2021-22946",
  "name": "curl: Requirement to use TLS not properly enforced for IMAP, POP3, and FTP protocols",
  "severity": "HIGH",
  "pkgname": "curl",
  "installedversion": "7.78.0-r0",
  "fixedversion": "7.79.0-r0"
}
{
  "id": "CVE-2021-22947",
  "name": "curl: Server responses received before STARTTLS processed after TLS handshake",
  "severity": "MEDIUM",
  "pkgname": "curl",
  "installedversion": "7.78.0-r0",
  "fixedversion": "7.79.0-r0"
}
{
  "id": "CVE-2021-22945",
  "name": "curl: use-after-free and double-free in MQTT sending",
  "severity": "CRITICAL",
  "pkgname": "libcurl",
  "installedversion": "7.78.0-r0",
  "fixedversion": "7.79.0-r0"
}
{
  "id": "CVE-2021-22946",
  "name": "curl: Requirement to use TLS not properly enforced for IMAP, POP3, and FTP protocols",
  "severity": "HIGH",
  "pkgname": "libcurl",
  "installedversion": "7.78.0-r0",
  "fixedversion": "7.79.0-r0"
}
{
  "id": "CVE-2021-22947",
  "name": "curl: Server responses received before STARTTLS processed after TLS handshake",
  "severity": "MEDIUM",
  "pkgname": "libcurl",
  "installedversion": "7.78.0-r0",
  "fixedversion": "7.79.0-r0"
}
{
  "id": "CVE-2021-40528",
  "name": "libgcrypt: ElGamal implementation allows plaintext recovery",
  "severity": "MEDIUM",
  "pkgname": "libgcrypt",
  "installedversion": "1.8.8-r0",
  "fixedversion": "1.8.8-r1"
}
```

### Snyk

1 Critical, 1 High, 2 Medium

```
✗ Medium severity vulnerability found in libgcrypt/libgcrypt
  Description: Use of a Broken or Risky Cryptographic Algorithm
  Info: https://snyk.io/vuln/SNYK-ALPINE313-LIBGCRYPT-1585259
  Introduced through: libgcrypt/libgcrypt@1.8.8-r0, libxslt/libxslt@1.1.34-r0
  From: libgcrypt/libgcrypt@1.8.8-r0
  From: libxslt/libxslt@1.1.34-r0 > libgcrypt/libgcrypt@1.8.8-r0
  Fixed in: 1.8.8-r1

✗ Medium severity vulnerability found in curl/libcurl
  Description: Insufficient Verification of Data Authenticity
  Info: https://snyk.io/vuln/SNYK-ALPINE313-CURL-1585257
  Introduced through: curl/libcurl@7.78.0-r0, curl/curl@7.78.0-r0
  From: curl/libcurl@7.78.0-r0
  From: curl/curl@7.78.0-r0 > curl/libcurl@7.78.0-r0
  From: curl/curl@7.78.0-r0
  Fixed in: 7.79.0-r0

✗ High severity vulnerability found in curl/libcurl
  Description: Cleartext Transmission of Sensitive Information
  Info: https://snyk.io/vuln/SNYK-ALPINE313-CURL-1585248
  Introduced through: curl/libcurl@7.78.0-r0, curl/curl@7.78.0-r0
  From: curl/libcurl@7.78.0-r0
  From: curl/curl@7.78.0-r0 > curl/libcurl@7.78.0-r0
  From: curl/curl@7.78.0-r0
  Fixed in: 7.79.0-r0

✗ Critical severity vulnerability found in curl/libcurl
  Description: Double Free
  Info: https://snyk.io/vuln/SNYK-ALPINE313-CURL-1585246
  Introduced through: curl/libcurl@7.78.0-r0, curl/curl@7.78.0-r0
  From: curl/libcurl@7.78.0-r0
  From: curl/curl@7.78.0-r0 > curl/libcurl@7.78.0-r0
  From: curl/curl@7.78.0-r0
  Fixed in: 7.79.0-r0
```

### AWS ECR

3 Medium, 2 low

```
{
  "id": "CVE-2021-22947",
  "severity": "MEDIUM",
  "pkgname": "curl",
  "installedversion": "7.78.0-r0"
}
{
  "id": "CVE-2021-22945",
  "severity": "MEDIUM",
  "pkgname": "curl",
  "installedversion": "7.78.0-r0"
}
{
  "id": "CVE-2021-22946",
  "severity": "MEDIUM",
  "pkgname": "curl",
  "installedversion": "7.78.0-r0"
}
{
  "id": "CVE-2021-40528",
  "severity": "LOW",
  "pkgname": "libgcrypt",
  "installedversion": "1.8.8-r0"
}
{
  "id": "CVE-2020-28928",
  "severity": "LOW",
  "pkgname": "musl",
  "installedversion": "1.2.2-r1"
}
```


## Patched

This time upgrading via the distributions package manager.

```
FROM nginx:1.20-alpine
RUN apk update && apk upgrade
RUN echo 'server {location /health {default_type text/plain; return 200 "OK";}}' \
    > /etc/nginx/conf.d/default.conf
```

### Trivy

No vulnerabilities detected.

### Snyk

No vulnerabilities detected.

### AWS ECR

AWS detected one Low severity vulnerability.

```
{
  "id": "CVE-2020-28928",
  "severity": "LOW",
  "pkgname": "musl",
  "installedversion": "1.2.2-r1"
}
```
... but was it accurate?

The package version matches that which is reported:

```
❯ docker run -it --rm nginxlab:latest apk list musl
musl-1.2.2-r1 x86_64 {musl} (MIT) [installed]
```

But looking at the [NVD record for CVE-2020-28928](https://nvd.nist.gov/vuln/detail/CVE-2020-28928) this version appears to not be affected:

> In musl libc through 1.2.1, wcsnrtombs mishandles particular combinations of destination buffer size and source character limit

So we have a false positive here due to an inaccurate match between the affected versions and that installed.


## Part 2

Part 2 coming soon, with a deeper look at the results of from the unpatched image and a test of further scan features such as detection of misconfigurations.

