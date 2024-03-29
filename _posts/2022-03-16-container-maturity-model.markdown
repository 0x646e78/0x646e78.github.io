---
layout: post
title:  "A Container Security Maturity Model"
date:   2022-04-11 12:00:00 +1000
categories: security docker cloudnative containers
---

Putting the CNCF Cloud Native Security Whitepaper into practice. An updated version of this post I published last month, now with the model in public Google Sheets instead of the repo as well as various edits.

This post is about building & using a maturity model to help assess & prioritise a subject area within cybersecurity. Specifically it is focused on drawing from the [CNCF Cloud Native Security Whitepaper][whitepaper] to measure the security posture of container workloads, from development through runtime. The process of making such a model should generally be useful outside of just container security.

Perhaps you're a security engineer or an engineering lead. Cloud-first, shipping most things in containers. You may have more than a suspician that your container ecosystem lacks security features, that there are various risks and that there is a potential need to uplift. But it's also a large subject area to address narrowly, there is a lot of complexity.
 
How can you effectively build a business case and determine your priorities within a large, complex set of systems and practices? I like to draw from a public model or framework, others in the industry have given input based on their experience and situations they have faced, and often showing a precedent of 'industry practice' will be of great help.

The resulting model is available in Google Sheets [here][CSMM]. If anyone wants commenter access let me know.

Enter Capability Maturity Models
---

A [Capability Maturity Model (CMM)][CMM], or variation of such, is often employed when assessing software development processes. The general apprach is to have key process areas, each of which contain a set of related activities, and each activity has a set of criterea which are marked with a rating of 1-5, with 3 often being 'good' or 'defined'. An example used within cybersecurity is [Building Security in Maturity Model (BSIMM)][BSIMM] - "an objective, data-driven evaluation that leaders seeking to improve their security postures can use to base decisions about resources, time, budget, and priorities". It has a large community, but also complexity and a focus different to what we're working on here. I want something 'light touch' and focused on the container ecosystem.

![CMM Levels]({{ BASE_PATH }}/assets/article_images/2022-02-09-container-maturity/cmm_levels.png){: .img-resize .img-center}
*Capability Maturity Levels (from Wikipedea)*

The Cloud Native Security Whitepaper
---

In late 2020 the [Cloud Native Foundation TAG-Security][TAG-SEC] published the [Cloud Native Security Whitepaper][whitepaper]. This defines & describes lifecycle Stages within a Cloud Native ecosystem - **Develop**, **Distribute**, **Deploy**, and **Runtime** as depicted below.

![CNCF Lifecycle Stages]({{ BASE_PATH }}/assets/article_images/2022-02-09-container-maturity/cncf_lifecycle.png){: .img-resize .img-center}
*Coud Native Lifecycle*

These lifecycle phases can be used as process areas in a model, grouping the processes & activities relating to container security.

There are other frameworks for looking at cloud & container ecosystems, such as the [4Cs][4Cs], [Redhat’s DevSecOps maturity model][rh-devops], and vendor models such as those seen on Aqua security homepage. As the [CNCF][CNCF] is well placed as a vendor-neutral Cloud Native industry body, and their Security-TAG is extremely active and knowledgeable I felt that basing a model on the Cloud Native Security Whitepaper was most suitable.

Building the Model
---

Containers are not everything within cloud native, they're somewhat intrinsic but there are various aspects of the lifecycle which may not be entirely relevant. Assessing an organisations entire cloud native approach is a much broader scope than I wanted or needed, as such various items have been omitted, or have been included but will get little direct attention from a container security program as they are already covered by other areas - an AppSec program (SCA, Secrets in Code, SAST), Cloud Security (eg AWS security policy adherance), SecOps (DFIR). The application sourcecode that will be hosted and the AWS account configuration are not covered in my scope. There will always be overlap or gaps, so I have tried to address these where appropriate.

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

For ease of getting started, Excel was chosen, with a star chart displaying where we want to be (green) and where we are (red) based on a self-rating.

I spent a chunk of time thinking about each area and got it into something that I felt was workable. The definitions for each row are generally based upon the CNCF Security Whitepaper, and also largely informed by my individual experience of the capabilities, standards, 'good practices' in existence as well as what I've experienced over the years working in infosec. It's imperfect and hopefully can grow and adjust over time.

![Capability Star]({{ BASE_PATH }}/assets/article_images/2022-02-09-container-maturity/star.png){: .img-resize .img-center}
*Visualising Maturity*

Utilising the Model
---

I rated each of the sections based on info I could find and what I knew, and got a nice star graph. Great! So, what to do with it.... put it on a billboard with "The end is near!" scrawled under it? No, let's get a practical outcome. The measurement is there to help us drive a program of work, so let's do that.

Based on the Whitepaper, the rows of the model and the technical and policy capabilities in the organistation I populated a Miro board to use in a group session. Each lifecycle phase is broken into sections, and in each we have our existing practices, and an area to note our gaps. There is also a box in each section for 'research tasks', items that may be noted but we're not sure how useful it could be, which tech to go with etc. 

![Miro High Level]({{ BASE_PATH }}/assets/article_images/2022-02-09-container-maturity/miro-zoomed-out.png){: .img-resize .img-center}
*Utilising Miro For Group Gap Analysis*

![Miro Develop Lifecycle]({{ BASE_PATH }}/assets/article_images/2022-02-09-container-maturity/miro-develop.png){: .img-resize .img-center}
*Close Up of the Develop Lifecycle Stage within Miro*

A session was held with our relevant security folks and most importantly with those who engineer container-based environments at an organisational practice level. This session was around 90 minutes where the model & lifecycle was introduced and then we went through the various stages giving people time to add notes. Before moving to the next section we'd quickly summarise and clarify, at the end of the session I got some overall feelings from people and gathered various themes, clarifying some of the items.

From this I went away and worked on a plan. We utilise Jira and so I took the lifecycle stages and themes identified within these as Epics, within each listing out the various gaps as Tasks or Stories - worded in such a way to highlight the remedial work and linked all together using a label plus another label for the lifecycle stage, eg 'cncf-develop'. The various Epics were grouped under Initiatives. An example would be an Initative of "Implement & Enforce Security Capabilities In Image Builds", under which one of the Epics of "Aggregate Image & Container Metadata into SIEM", and within this one of the tasks of "Correlate Running Container IDs With Image Vulnerability Data". Jira can be a bit clunky in organising complex pieces of work - these systems all are a bit - but it was helpful to get a view of the actual work. For more on structuring work within Jira there is a decent article from Atlassian [here][jira-blog]

Once it's all in Jira it's still just a big bunch of tasks. This is where the model helps to priopritise. We'd marked where we want to be, we'd marked where we are, and we have Jira labels allowing us to narrow into the areas. For me with starting such work I look at where we have the biggest gap, then which is the simplest to do. From here we know what is first up, and can reasonably plan for the next few months. Anything after that can be planned later. I won't go into detail of what we picked - for you it might be implementing a break-build capability pre-push based on an agreed vulnerability threshold. It could be implementing an admission controller to allow policy adherence within your kubernetes stack. It all depends on your own outcome from the model.

Reflections
---

I like simple visual reprentations, based on some reasonable process to get there, and I'm happy with the result. It's a bit rough, some of the language could be adjusted and more measurable metric definitions worked toward.

Having a published whitepaper from an industry body (the wonderful [CNCF][CNCF] in this case) is incredibly valuable.

Having a published whitepaper from an industry body is incredibly valuable. Having the resultant visualisation of current and hoped maturity has been very effective in describing our problems and deciding where to increase resources.

Creating a model helped get my head around this complex space. Cloud Native and within that container security is entwined with all aspects of application & platform development and operations. Scoping helped to give a clearer picture of the container domain, and what was relevant within my organisation.I found that the Cloud Native Lifecycle Phases ends up with the largest proportion of items in Distribute & Runtime. This makes sense when you consider CI/CD often being the central place of earliest value stage gating (Distribute), and all of the moving pieces that could be involved in your production environments (Runtime). Once again, scoping can help here - especially with runtime - e.g EDR might be a pre-existing process handled by your SecOps team and wider than just cloud or containers, in a similar way you may already have standard Base OS hardening processes - so the container base host is out of scope.

It is hard to box all items into the phases - areas cross over, such as build capabilities (Distribute) being largely the same as IDE/local tooling in many situations (Develop). This is always the case with complex systems, trying to link these together in the task capture tool such as Jira or make a decision for the sake of progressing the work helps somewhat. The aim isn't to neatly categorise things at the end of the day but to strengthen your security posture.

I used Miro for collaboration. People generally need to use it regularly to feel comfortable contributing. It is a great tool, the ability to visualise and all work together is especially important in remote work, but if your organisation suffers from a lack of standardisation in collaboration tool there will often be a barrier to effective contributions based on the comfort levels with the tool.

Jira is also hard - grouping things, prioritisation, visualising are all difficult at the best of times let alone if your workspace isn't set up all that well. Once I had the uplift items in here though it was very easy to link to, show how long we've had these issues logged, drag items into a roadmap and collect relevant information.

The whitepaper & lifecycle are evolving, the [CNCF Tag-Security][TAG-SEC] is maintaining this great work. A new version of the whitepaper is in RFC now & the previously mentioned [CNCF Security Map][cncf-map] continues to collect open source tooling options. A space I'll watch closely and hopefully get more involved in.


[CSMM]: https://docs.google.com/spreadsheets/d/1WXcBGgYKEi7xTR0CqJ1RBluWNNPJqNj3O90Gu8swALQ/edit?usp=sharing
[CMM]: https://en.wikipedia.org/wiki/Capability_Maturity_Model
[BSIMM]: https://www.bsimm.com/
[TAG-SEC]: https://github.com/cncf/tag-security
[whitepaper]: https://github.com/cncf/tag-security/blob/main/security-whitepaper/CNCF_cloud-native-security-whitepaper-Nov2020.pdf
[cncf-map]: https://cnsmap.github.io/
[4Cs]: https://kubernetes.io/docs/concepts/security/overview/
[rh-devops]: https://www.redhat.com/architect/enterprise-architects-devsecops
[CNCF]: https://www.cncf.io/
[jira-blog]: https://www.atlassian.com/agile/project-management/epics-stories-themes
