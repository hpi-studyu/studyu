# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

StudyU is a Flutter/Dart monorepo platform for conducting digital N-of-1 trials. It uses Melos for workspace management and FVM for Flutter version management.

## Common Commands

### Setup
```bash
dart pub global activate melos   # Install Melos
melos bootstrap                  # Install all dependencies (replaces flutter pub get)
dart pub get                     # Initialize root project for lint style
```

### Development
```bash
melos run app                    # Run StudyU App on Chrome (port 8080)
melos run designer_v2            # Run Designer on Chrome (port 8081)
melos run local:app              # Run App with local Supabase
melos run local:designer_v2      # Run Designer with local Supabase
melos run dev:app                # Run App with dev environment
```

### Code Generation & Quality
```bash
melos run generate               # Generate *.g.dart files after model changes (build_runner)
melos format                     # Format code
flutter analyze                  # Check for lint issues
melos run qualitycheck           # Format, generate, and analyze
```

### Testing & Building
```bash
melos run test                   # Run tests for all packages with test directories
melos run build:web              # Build both apps for web
melos run build:android          # Build APK
```

### Reset
```bash
melos run reset                  # Clean and bootstrap from scratch
```

## Package Architecture

```
studyu/
├── app/                  # StudyU App - participant-facing mobile/web app
├── designer_v2/          # StudyU Designer - researcher web app for study design
├── core/                 # Shared models and business logic (Dart only)
├── flutter_common/       # Shared Flutter widgets and utilities
├── supabase/             # Database schema, migrations, and Supabase CLI config
└── database/             # Legacy database documentation
```

### Dependency Flow
- `app` and `designer_v2` depend on both `core` and `flutter_common`
- `flutter_common` depends on `core`
- `core` has no internal dependencies (pure Dart)

## Core Package Notes

Models in `core` use `json_serializable` for JSON encoding. After modifying models:
1. Run `melos run generate` to regenerate `*.g.dart` files
2. Commit the generated files (required since `core` is a dependency)

## Environment Configuration

Environment files are in `flutter_common/lib/envs/`:
- `.env` - Production (default)
- `.env.dev` - Development database
- `.env.local` - Local Supabase CLI instance

Specify environment via: `--dart-define=STUDYU_ENV=.env.local`

## Local Supabase Development

```bash
supabase start                   # Start local Supabase stack (requires Docker)
supabase stop                    # Stop stack
supabase db reset                # Reset database to default state
```

Local credentials: `user1@studyu.health` / `user1pass`
Supabase Studio: http://localhost:54323

## State Management

- **App**: Uses Provider with `AppState` class (`app/lib/models/app_state.dart`)
- **Designer**: Uses Riverpod with code generation (`riverpod_generator`)

## Key Data Models (in `core`)

- `Study` - Trial definition with schedule, interventions, observations
- `StudySubject` - Participant enrolled in a study
- `Intervention` / `Observation` - Treatment arms and measurement tasks
- `DailyRecall` / `MealLog` / `FoodEntry` - Nutrition tracking models

## Code Style

- Follow Effective Dart guidelines
- Use Conventional Commits for commit messages
- Run `melos format` and `flutter analyze` before committing

## FVM (Flutter Version Management)

The project uses FVM. If using FVM:
```bash
fvm install                      # Install Flutter version from .fvmrc
export MELOS_SDK_PATH=.fvm/flutter_sdk  # Required for melos to use correct SDK
```
