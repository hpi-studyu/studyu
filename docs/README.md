# StudyU documentation

To get an overview of the project and learn how to get started, please refer to
our [contribution guide](../CONTRIBUTING.md).

The contents of this directory serve as more detailed and specific
documentation.

## Automatically generated documentation

The StudyU repository has GitHub workflows that automatically generate and
update

- Documentation of the database in [database/](database), generated by the
  [`db-docs.yml`](../.github/workflows/db-docs.yml) workflow
- UML diagrams for all dart code in [uml/](uml), organized in directories
  analogous to the file structure of the code, generated by the
  [`uml-docs.yml`](../.github/workflows/uml-docs.yml) workflow

These documentation updates are committed to your branch while you are working
on it, meaning you should pull and rebase where appropriate to keep a clean
commit history.

**Important note** The documentation workflows are designed to do as little work
as necessary by detecting which parts of the documentation need to be updated.
Manually committing anything to the [database/](database) or [uml/](uml)
directories may break this detection. If you have to make any changes there,
please make sure you understand how the respective workflow functions first.