---
layout: post
title:  "A Container Security Maturity Model"
date:   2022-02-09 12:00:00 +1000
categories: security docker cloudnative containers
---

Putting the CNCF Cloud Native Security Whitepaper into practice.

This post is about building & using a maturity model to help assess & prioritise a subject area within cybersecurity. Specifically it is focused on drawing from the [CNCF Cloud Native Security Whitepaper][whitepaper] to measure the security posture of container workloads, from development through runtime. The process of making such a model should generally be useful outside of just container security.

Perhaps you're a security engineer or an engineering lead in an organisation. You're cloud-first, shipping most things in containers. Like many in this position you may have more than a suspician that your container ecosystem lacks security features, that there are various risks and that there is a potential need to uplift. But it's also a large subject area to address narrowly, there is a lot of complexity.
 
How can you effectively build a business case and determine your priorities within such a large, complex set of systems and practices? For support I like to draw from a public model or framework, others in the industry have given input based on their experience and situations they have faced, and often showing a precedent of 'industry practice' will be of great help.

Enter Capability Maturity Models
---

A [Capability Maturity Model (CMM)][CMM], or variation of such, is often employed when assessing software development processes. The general apprach is to have key process areas, each of which contain a set of related activities, and each activity has a set of criterea which are marked with a rating of 1-5, with 3 often being 'good' or 'defined'. An example used within cybersecurity is [Building Security in Maturity Model (BSIMM)][BSIMM], which "provides an objective, data-driven evaluation that leaders seeking to improve their security postures can use to base decisions about resources, time, budget, and priorities". It has a large community, but also complexity and a focus different to what we're working on here. I want something 'light touch' and focused on the container ecosystem.

![CMM Levels]({{ BASE_PATH }}/assets/article_images/2022-02-09-container-maturity/cmm_levels.png){ .img-resize .img-center}
*Capability Maturity Levels (from Wikipedea)*

The Cloud Native Security Whitepaper
---

In late 2020 the [Cloud Native Foundation SIG-Security][TAG-SEC] (now TAG-Security) published the [Cloud Native Security Whitepaper][whitepaper]. This defines & describes lifecycle Stages within a Cloud Native ecosystem. These four phases were **Develop**, **Distribute**, **Deploy**, and **Runtime** and are depicted below.

![CNCF Lifecycle Stages]({{ BASE_PATH }}/assets/article_images/2022-02-09-container-maturity/cncf_lifecycle.png){ .img-resize .img-center}
*Coud Native Lifecycle*

These lifecycle phases can be used as process areas in a model, grouping the processes & activities relating to container security.

There are other frameworks for looking at cloud & container ecosystems, such as the [4Cs][4Cs], Redhat’s DevSecOps maturity model][rh-devops], and vendor models such as those seen on Aqua security homepage. As the [CNCF][CNCF] is well placed as a vendor-neutral Cloud Native industry body, and their Security-TAG is extremely active and knowledgeable I felt that basing a model on the Cloud Native Security Whitepaper was most suitable.

Building the Model
---

Containers are not everything within cloud native, they're somewhat intrinsic but there are various aspects of the lifecycle which may not be entirely relevant. Assessing an organisations entire cloud native approach is a much broader scope than I wanted or needed, as such various items have been omitted, or have been included but will get little direct attention from a container security program as they are already covered by other areas, such as your organisations development practices, an AppSec program (SCA, Secrets in Code, SAST), Cloud Security (eg AWS security policy adherance), SecOps (DFIR). So the application sourcecode that will be hosted and the AWS account configuration are not covered in my scope. There will always be overlap or gaps though, and so I have tried to address these where appropriate.

 The CNCF are also developing a [Cloud Native Security Map][cncf-map] which aims to map available tools, benchmarks and practices to the lifecycles.


The sections and rows in my model are:

- Develop
    -  Standards
    -  Image Manifests
    -  Infrastructure as Code Manifests
- Distribute
    -  Image Builds
    -  Image Registry Trust
    -  Image Registry Store
- Deploy
    -  Image Trust
    -  Pre-flight Configuration Controls
    -  Pre-flight Policy Controls
- Runtime
    -  Policy Enforcement
    -  Identity & Access Management
    -  Secure Storage
    -  Secrets Management
    -  Secure Network
    -  Observability & Incident Response

For ease of getting started, Excel was chosen, with a star chart displaying where we want to be (green) and where we are (red) based on a self-rating of various aspects of the lifecycle.

I spent a chunk of time thinking about each area and got it into something that I felt was workable. The definitions for each row generally based upon the CNCF Security Whitepaper, and also largely informed by my individual experience of the capabilities, standards, 'good practices' in existence as well as what I've experienced over the years working in infosec. It's imperfect and hopefully can grow and adjust over time.

![Capability Star]({{ BASE_PATH }}/assets/article_images/2022-02-09-container-maturity/star.png){ .img-resize .img-center}
*Visualising Maturity*

Utilising the Model
---

I rated each of the sections based on info I could find and what I knew, and got a nice star graph. Great! So, what to do with it.... put it on a billboard with "The end is near!" scrawled under it? No, let's get a practical outcome. The measurement is there to help us drive a program of work, so let's do that.

Based on the Whitepaper, the rows of the model and the technical and policy capabilities in the organistation I populated a Miro board to use in a group session. Each lifecycle phase is broken into sections, and in each we have our existing practices, and an area to note our gaps. There is also a box in each section for 'research tasks', items that may be noted but we're not sure how useful it could be, which tech to go with etc. 

<insert image of miro>

Miro session

Build a plan from this

Prioritise & implement


Reflections On the Experience
---

Distribute & Runtime felt the heaviest. A lot of items in Distribute/Image Registry.

Miro is hard, people really need to use it regularly to feel comfortable contributing.
Miro is great, the ability to visualise and all work together is especially important in remote work.
It's hard to box items into the phases - areas cross over, such as build capabilities (Distribute) being largely the same as IDE/local tooling in many situations (Develop). This is always the case with complex systems.
A container ecosystem is not always easily definable - host system hardening & forensics; pentests & redteaming.
The whitepaper & lifecycle are evolving. Actually, I already knew this, but 
Having a published whitepaper from an industry body is incredibly valuable.
Getting ideas down in various forms helps to formulate them
Jira is hard - grouping things, prioritisation if your workspace isn't set up well.




[CMM]: https://en.wikipedia.org/wiki/Capability_Maturity_Model
[BSIMM]: https://www.bsimm.com/
[TAG-SEC]: https://github.com/cncf/tag-security
[whitepaper]: https://github.com/cncf/tag-security/blob/main/security-whitepaper/CNCF_cloud-native-security-whitepaper-Nov2020.pdf
[cncf-map]: https://cnsmap.github.io/
[4Cs]: https://kubernetes.io/docs/concepts/security/overview/
[rh-devops]: https://www.redhat.com/architect/enterprise-architects-devsecops
[CNCF]: https://www.cncf.io/
