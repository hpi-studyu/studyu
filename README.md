# StudyU: N-of-1 Trials Made Easy

StudyU is the award-winning, ideal platform to discover the effects of individual health interventions in a safe and convenient way. StudyU accomplishes this by ushering N-of-1 trials into the digital age, effectively combining the fields of technology and personalized research methods.

## What are N-of-1 Trials?

Many medical treatments only work in 50% of patients [1], and either have low or unknown effectiveness [2]. N-of-1 trials are the gold standard for finding out which treatments work at the individual level. Here's an example on how they work:

TODO: https://youtu.be/_KaGearXQkI?t=733

## The StudyU Platform

The StudyU platform incorporates the StudyU App and the StudyU Designer. As a clinician, researcher, or digital health enthusiast you can conduct your own studies with the StudyU Designer. By utilizing the StudyU App, individuals have the opportunity to actively engage in N-of-1 trials and obtain personalized treatment advice. The StudyU App leverages the capabilities of statistical computing and advanced machine learning models to identify the optimal intervention tailored specifically to your unique needs and circumstances.

Find out more about StudyU and start your study now at [studyu.health](https://studyu.health)

### Try out StudyU for yourself

- [StudyU App](https://app.studyu.health)
- [StudyU Designer v2](https://designer.studyu.health)

### App Stores

- [Google Play Store](https://play.google.com/store/apps/details?id=health.studyu.app)
- [Apple App Store](https://apps.apple.com/us/app/studyu-health/id1571991198)

## Publications

More information on the scientific background and a detailed description of the
StudyU platform is available at:

Konigorski S, Wernicke S, Slosarek T, Zenner AM, Strelow N, Ruether FD, Henschel
F, Manaswini M, Pottbäcker F, Edelman JA, Owoyele B, Danieletto M, Golden E,
Zweig M, Nadkarni G, Böttinger E (2020). StudyU: a platform for designing and
conducting innovative digital N-of-1 trials. arXiv:2012.1420.
[https://arxiv.org/abs/2012.14201](https://arxiv.org/abs/2012.14201).

## References

[1] Spear BB, Heath-Chiozzi M, Huff J. Clinical application of pharmacogenetics. Trends Mol Med. 2001 May;7(5):201-4. doi: 10.1016/s1471-4914(01)01986-4. PMID: 11325631.

[2] Smith QW, Street RL, Volk RJ, Fordis M. Differing Levels of Clinical Evidence: Exploring Communication Challenges in Shared Decision Making. Medical Care Research and Review. 2013;70(1_suppl):3S-13S. doi:10.1177/1077558712468491.

---

## Repository Overview

We have different Flutter/Dart packages all contained in this monorepo. The StudyU platform consists out of the following packages:

- StudyU App: Participate in N-of-1 trials
- StudyU Designer: Design and conduct your own N-of-1 trial

Dependency packages:

- Core: shared code for all applications
- Flutter Common: shared code for all Flutter apps (App, Designer)

Outdated packages:

- StudyU Designer (flutter)
- Repository Generator (dart web server)
- Analysis Generator (dart CLI script)

### Deprecated Packages

- [StudyU App v1](https://app-v1.studyu.health)
- [StudyU Designer v1](https://designer-v1.studyu.health)
