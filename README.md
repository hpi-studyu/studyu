# StudyU: N-of-1 Trials Made Easy

StudyU is an award-winning platform to discover the effects of individual health
interventions in a safe and convenient way. StudyU accomplishes this by bringing
[N-of-1 trials](https://www.studyu.health/docs/basics/n-of-1-trials) into the
digital age, effectively combining the fields of technology and personalized
research methods.

Find out more about StudyU and start your study now
at: [studyu.health](https://www.studyu.health)

## The StudyU Platform

The StudyU platform incorporates the **StudyU App** and the **StudyU Designer**.

### StudyU Designer

The StudyU Designer is a web-based application supporting the design and
implementation of digital N-of-1 trials for clinicians, researchers, or digital
health enthusiasts. With its user-centric design framework, the Study Designer
improves usability with many supportive features during the study creation
process. Notably, it includes a preview function that provides areal-time
visualization of the study design. Besides running private N-of-1trials,
seamless collaboration with other researchers is also supported by sharing
studies with other clinicians and researchers,fostering collaboration and
transparency in the spirit of public health and open science.

### StudyU App

The StudyU App is a user-friendly web and smartphone application that
enables individuals to actively participate in digital N-of-1 trials and obtain
personalized treatment advice. It’s accessible design approach accommodates users
with limited technical skills,allowing them to directly measure the impact of
interventions on their health outcomes. By engaging patients in the trial process,
the StudyU App promotes patient empowerment and facilitates shared
decision-making between researchers, clinicians, and individuals. The StudyU App
leverages the capabilities of statistical computing and advanced machine learning
models to identify the optimal intervention tailored specifically to your unique
needs and circumstances.

## Try out StudyU

- [StudyU App](https://app.studyu.health)
- [StudyU Designer v2](https://designer.studyu.health)

### App Stores

- [Google Play Store](https://play.google.com/store/apps/details?id=health.studyu.app)
- [Apple App Store](https://apps.apple.com/us/app/studyu-health/id1571991198)

## Publications

More information on the scientific background and a detailed description of
the StudyU platform is available at:

- Konigorski S, Wernicke S, Slosarek T, Zenner AM, Strelow N, Ruether FD, 
Henschel F, Manaswini M, Pottbäcker F, Edelman JA, Owoyele B, Danieletto M, 
Golden E, Zweig M, Nadkarni G, Böttinger E (2020).
StudyU: a platform for designing and conducting innovative digital N-of-1
trials. arXiv: 2012.1420.  
[https://arxiv.org/abs/2012.14201](https://arxiv.org/abs/2012.14201).

## Repository Overview

We have different Flutter/Dart packages all contained in this monorepo. The
StudyU platform consists out of the following packages:

- StudyU App: Participate in N-of-1 trials
- StudyU Designer: Design and conduct your own N-of-1 trial

Dependency packages:

- Core: shared code for all applications
- Flutter Common: shared code for all Flutter apps (App, Designer)

Outdated packages:

- StudyU Designer (flutter)
- Repository Generator (dart web server)
- Analysis Generator (dart CLI script)

## Deprecated Packages

- [StudyU App v1](https://app-v1.studyu.health)
- [StudyU Designer v1](https://designer-v1.studyu.health)
