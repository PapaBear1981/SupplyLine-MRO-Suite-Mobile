# Contributing to SupplyLine MRO Suite Mobile

Thank you for your interest in contributing to the SupplyLine MRO Suite Mobile app! This document provides guidelines and instructions for contributing to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Pull Request Process](#pull-request-process)
- [Issue Reporting](#issue-reporting)

## Code of Conduct

This project adheres to a code of conduct that promotes a welcoming and inclusive environment. Please read and follow our code of conduct in all interactions.

## Getting Started

### Prerequisites

- Flutter SDK 3.16.0 or later
- Dart SDK 3.0.0 or later
- Android Studio or VS Code with Flutter extensions
- Git

### Development Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/PapaBear1981/SupplyLine-MRO-Suite-Mobile.git
   cd SupplyLine-MRO-Suite-Mobile
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run code generation:**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Set up your IDE:**
   - Install Flutter and Dart plugins
   - Configure code formatting on save
   - Enable linting

## Development Workflow

### Branch Naming Convention

- `feature/issue-number-short-description` - New features
- `bugfix/issue-number-short-description` - Bug fixes
- `hotfix/issue-number-short-description` - Critical fixes
- `refactor/short-description` - Code refactoring
- `docs/short-description` - Documentation updates

### Commit Message Format

Follow the conventional commit format:

```
type(scope): description

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

Example:
```
feat(auth): add biometric authentication support

Implement fingerprint and face ID authentication for enhanced security.
Includes fallback to PIN/password authentication.

Closes #123
```

## Coding Standards

### Dart/Flutter Guidelines

1. **Follow Dart style guide:** Use `dart format` and `flutter analyze`
2. **Use meaningful names:** Variables, functions, and classes should have descriptive names
3. **Write documentation:** Document public APIs with dartdoc comments
4. **Keep functions small:** Aim for functions under 20 lines
5. **Use const constructors:** When possible, use const constructors for widgets
6. **Prefer composition over inheritance:** Use mixins and composition patterns

### Code Organization

```
lib/
├── core/                 # Core functionality
│   ├── config/          # Configuration files
│   ├── models/          # Data models
│   ├── services/        # Business logic services
│   ├── theme/           # App theming
│   └── router/          # Navigation routing
├── features/            # Feature modules
│   ├── auth/           # Authentication feature
│   ├── tools/          # Tool management feature
│   └── reports/        # Reports feature
└── shared/             # Shared widgets and utilities
```

### Architecture Principles

- **Clean Architecture:** Separate concerns into layers
- **SOLID Principles:** Follow SOLID design principles
- **Dependency Injection:** Use Riverpod for dependency management
- **State Management:** Use Riverpod for state management
- **Error Handling:** Implement comprehensive error handling

## Testing Guidelines

### Test Types

1. **Unit Tests:** Test individual functions and classes
2. **Widget Tests:** Test widget behavior and UI
3. **Integration Tests:** Test complete user flows

### Test Structure

```dart
void main() {
  group('FeatureName Tests', () {
    setUp(() {
      // Setup code
    });

    tearDown(() {
      // Cleanup code
    });

    test('should do something when condition is met', () {
      // Arrange
      // Act
      // Assert
    });
  });
}
```

### Test Coverage

- Maintain minimum 80% test coverage
- All new features must include tests
- Critical business logic requires 100% coverage

### Running Tests

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/features/auth/auth_service_test.dart
```

## Pull Request Process

### Before Submitting

1. **Create an issue:** Discuss the change before implementing
2. **Create a branch:** Use the naming convention
3. **Write tests:** Ensure adequate test coverage
4. **Update documentation:** Update relevant documentation
5. **Run quality checks:**
   ```bash
   flutter analyze
   dart format --set-exit-if-changed .
   flutter test
   ```

### PR Requirements

- [ ] Descriptive title and description
- [ ] Link to related issue(s)
- [ ] All tests pass
- [ ] Code follows style guidelines
- [ ] Documentation updated
- [ ] No merge conflicts
- [ ] Reviewed by at least one maintainer

### PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests added/updated
- [ ] Widget tests added/updated
- [ ] Integration tests added/updated
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] Tests pass locally
```

## Issue Reporting

### Bug Reports

Include:
- Device information (OS, version, device model)
- App version
- Steps to reproduce
- Expected vs actual behavior
- Screenshots/videos if applicable
- Logs/error messages

### Feature Requests

Include:
- Clear description of the feature
- Use case and business value
- Acceptance criteria
- Mockups/wireframes if applicable

## Development Environment

### Environment Variables

Create a `.env` file for local development:

```
FLUTTER_ENV=development
API_BASE_URL=http://localhost:5000
ENABLE_LOGGING=true
```

### IDE Configuration

#### VS Code Settings

```json
{
  "dart.flutterSdkPath": "/path/to/flutter",
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": true
  }
}
```

#### Android Studio

- Enable Flutter plugin
- Configure code style to match project settings
- Set up live templates for common patterns

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- [Material Design Guidelines](https://material.io/design)
- [Project Roadmap](ROADMAP.md)
- [Setup Guide](SETUP_GUIDE.md)

## Questions?

If you have questions about contributing, please:
1. Check existing documentation
2. Search existing issues
3. Create a new issue with the "question" label
4. Contact the maintainers

Thank you for contributing to SupplyLine MRO Suite Mobile!
