# Product Catalog App

A production-ready Flutter application built following Clean Architecture principles, demonstrating state management, debounced search, and infinite scroll pagination.

---

## Features
- **Clean Architecture**: Clear separation of concerns into `data` (models & repositories) and `presentation` (providers & screens) layers.
- **State Management**: Reactive state management using `Provider` handling Loading, Error, Success, and Empty states gracefully.
- **Debounced Search**: Optimized network requests using a custom `Debouncer` helper to delay API calls while typing.
- **Infinite Scroll Pagination**: Incremental data fetching (`limit` & `skip` query parameters) using a `ScrollController`.
- **Navigation & Detail View**: Interactive navigation passing parameters to fetch detailed product information.

---

## Tech Stack
- **Framework**: Flutter
- **State Management**: `provider`
- **Networking**: `http`
- **API Target**: [DummyJSON Products API](https://dummyjson.com/docs/products)

---

## Architecture Overview

```text
lib/
├── data/
│   ├── models/
│   │   └── product.dart
│   └── repositories/
│       └── product_repository.dart
├── presentation/
│   ├── providers/
│   │   └── product_provider.dart
│   └── screens/
│       ├── product_list_screen.dart
│       └── product_detail_screen.dart
└── main.dart