# StudyU: N-of-1 Trials Made Easy

<p align="center">
  <img src="https://www.studyu.health/img/icon_wide.png" height="200" 
  alt="StudyU Icon">
</p>

StudyU is an <a href="https://www.studyu.health/blog/best-idea-award">
award-winning</a> platform to discover the effects of individual health 
interventions in a safe and convenient way. StudyU accomplishes this by bringing
[N-of-1 trials](https://www.studyu.health/docs/basics/n-of-1-trials) into the
digital age, effectively combining the fields of digitization and personalized
research methods.

Find out more about StudyU and start your first digital N-of-1 trial now at:
[StudyU.health](https://www.studyu.health)

## The StudyU Platform

The StudyU platform incorporates the **[StudyU App](https://app.studyu.health)**
and the **[StudyU Designer](https://designer.studyu.health)**.

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

The StudyU Designer is specifically designed to function as a web application,
which means it is best accessed on a device with a wide screen. On the other
hand, the StudyU App is primarily intended for use on smartphones, so it is
recommended to download it on a mobile device by using the app store links
provided below, in order for notifications to work properly. Alternatively, it
is also possible to access the StudyU App as a web application if desired.

### Web Apps

- [StudyU App](https://app.studyu.health)
- [StudyU Designer](https://designer.studyu.health)

### App Stores (StudyU App)

[<img src="resources/img/app-store-badge.png" height="50"
alt="Download on the App Store">](https://apps.apple.com/us/app/studyu-health/id1571991198)
[<img src="resources/img/google-play-badge.png" height="50"
alt="Get it on Google Play" style="margin-left: 20px">](https://play.google.com/store/apps/details?id=health.studyu.app)

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
