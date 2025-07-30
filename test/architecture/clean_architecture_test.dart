/// Clean Architecture compliance tests
/// Following CLAUDE.md architecture patterns and dependency rules
library clean_architecture_test;

import 'package:flutter_test/flutter_test.dart';
import 'dart:io';

import '../helpers/architecture_test_builders.dart';

void main() {
  group('Clean Architecture Compliance Tests', () {
    group('Dependency Direction Rules', () {
      test('Domain layer should not import Data layer', () async {
        final domainFiles = await _getDomainFiles();
        final dataImportViolations = <String>[];

        for (final file in domainFiles) {
          final content = await File(file).readAsString();
          final lines = content.split('\n');

          for (int i = 0; i < lines.length; i++) {
            final line = lines[i].trim();
            if (line.startsWith('import') && line.contains('/data/')) {
              dataImportViolations.add('${file}:${i + 1} - $line');
            }
          }
        }

        expect(
          dataImportViolations,
          isEmpty,
          reason:
              'Domain layer must not import Data layer. Violations found:\n'
              '${dataImportViolations.join('\n')}',
        );
      });

      test('Domain layer should not import Presentation layer', () async {
        final domainFiles = await _getDomainFiles();
        final presentationImportViolations = <String>[];

        for (final file in domainFiles) {
          final content = await File(file).readAsString();
          final lines = content.split('\n');

          for (int i = 0; i < lines.length; i++) {
            final line = lines[i].trim();
            if (line.startsWith('import') && line.contains('/presentation/')) {
              presentationImportViolations.add('${file}:${i + 1} - $line');
            }
          }
        }

        expect(
          presentationImportViolations,
          isEmpty,
          reason:
              'Domain layer must not import Presentation layer. Violations found:\n'
              '${presentationImportViolations.join('\n')}',
        );
      });

      test('Data layer should only import Domain interfaces', () async {
        final dataFiles = await _getDataFiles();
        final invalidImportViolations = <String>[];

        for (final file in dataFiles) {
          final content = await File(file).readAsString();
          final lines = content.split('\n');

          for (int i = 0; i < lines.length; i++) {
            final line = lines[i].trim();
            if (line.startsWith('import') && line.contains('/presentation/')) {
              invalidImportViolations.add(
                '${file}:${i + 1} - $line (Data importing Presentation)',
              );
            }
          }
        }

        expect(
          invalidImportViolations,
          isEmpty,
          reason:
              'Data layer must not import Presentation layer. Violations found:\n'
              '${invalidImportViolations.join('\n')}',
        );
      });

      test(
        'Presentation layer can import Domain but not Data implementations',
        () async {
          final presentationFiles = await _getPresentationFiles();
          final dataImplementationViolations = <String>[];

          for (final file in presentationFiles) {
            final content = await File(file).readAsString();
            final lines = content.split('\n');

            for (int i = 0; i < lines.length; i++) {
              final line = lines[i].trim();
              // Allow domain imports but not data implementations
              if (line.startsWith('import') &&
                  line.contains('/data/') &&
                  !line.contains('/domain/')) {
                dataImplementationViolations.add('${file}:${i + 1} - $line');
              }
            }
          }

          expect(
            dataImplementationViolations,
            isEmpty,
            reason:
                'Presentation layer must not import Data implementations directly. '
                'Use dependency injection instead. Violations found:\n'
                '${dataImplementationViolations.join('\n')}',
          );
        },
      );
    });

    group('Interface Segregation', () {
      test('Repository interfaces should be focused and cohesive', () async {
        final repositoryInterfaces = await _getRepositoryInterfaces();

        for (final file in repositoryInterfaces) {
          final content = await File(file).readAsString();
          final methodCount = _countPublicMethods(content);

          // Repository interfaces should have reasonable number of methods
          expect(
            methodCount,
            lessThanOrEqualTo(10),
            reason:
                'Repository interface $file has too many methods ($methodCount). '
                'Consider splitting into smaller, more focused interfaces.',
          );
        }
      });

      test('Use case interfaces should follow single responsibility', () async {
        final useCaseFiles = await _getUseCaseFiles();

        for (final file in useCaseFiles) {
          final content = await File(file).readAsString();

          // Each use case should have only one public call method
          final callMethodCount = RegExp(
            r'Future<.*>\s+call\s*\(',
          ).allMatches(content).length;

          expect(
            callMethodCount,
            equals(1),
            reason:
                'Use case $file should have exactly one call method. '
                'Found $callMethodCount methods.',
          );
        }
      });
    });

    group('Error Handling Patterns', () {
      test('All use cases should return Result type', () async {
        final useCaseFiles = await _getUseCaseFiles();
        final resultViolations = <String>[];

        for (final file in useCaseFiles) {
          final content = await File(file).readAsString();

          // Check if use case extends BaseUseCase or returns Result
          if (!content.contains('extends BaseUseCase') &&
              !content.contains('Future<Result<')) {
            resultViolations.add(file);
          }
        }

        expect(
          resultViolations,
          isEmpty,
          reason:
              'All use cases must return Result type or extend BaseUseCase. '
              'Violations found in:\n${resultViolations.join('\n')}',
        );
      });

      test('All repositories should handle failures consistently', () async {
        final repositoryFiles = await _getRepositoryImplementations();
        final failureHandlingViolations = <String>[];

        for (final file in repositoryFiles) {
          final content = await File(file).readAsString();

          // Check if repository extends BaseRepository or uses Result pattern
          if (!content.contains('extends BaseRepository') &&
              !content.contains('Result.failure') &&
              !content.contains('Result.success')) {
            failureHandlingViolations.add(file);
          }
        }

        expect(
          failureHandlingViolations,
          isEmpty,
          reason:
              'All repositories must handle failures consistently using Result pattern. '
              'Violations found in:\n${failureHandlingViolations.join('\n')}',
        );
      });
    });

    group('Naming Conventions', () {
      test('Entity files should end with "_entity.dart"', () async {
        final entityFiles = await _getEntityFiles();
        final namingViolations = <String>[];

        for (final file in entityFiles) {
          if (!file.endsWith('_entity.dart')) {
            namingViolations.add(file);
          }
        }

        expect(
          namingViolations,
          isEmpty,
          reason:
              'Entity files must end with "_entity.dart". '
              'Violations found:\n${namingViolations.join('\n')}',
        );
      });

      test('Use case files should end with "_usecase.dart"', () async {
        final useCaseFiles = await _getUseCaseFiles();
        final namingViolations = <String>[];

        for (final file in useCaseFiles) {
          if (!file.endsWith('_usecase.dart')) {
            namingViolations.add(file);
          }
        }

        expect(
          namingViolations,
          isEmpty,
          reason:
              'Use case files must end with "_usecase.dart". '
              'Violations found:\n${namingViolations.join('\n')}',
        );
      });

      test(
        'Repository implementations should end with "_repository_impl.dart"',
        () async {
          final repositoryImpls = await _getRepositoryImplementations();
          final namingViolations = <String>[];

          for (final file in repositoryImpls) {
            if (!file.endsWith('_repository_impl.dart')) {
              namingViolations.add(file);
            }
          }

          expect(
            namingViolations,
            isEmpty,
            reason:
                'Repository implementations must end with "_repository_impl.dart". '
                'Violations found:\n${namingViolations.join('\n')}',
          );
        },
      );

      test('Data source files should end with "_datasource.dart"', () async {
        final dataSourceFiles = await _getDataSourceFiles();
        final namingViolations = <String>[];

        for (final file in dataSourceFiles) {
          if (!file.endsWith('_datasource.dart')) {
            namingViolations.add(file);
          }
        }

        expect(
          namingViolations,
          isEmpty,
          reason:
              'Data source files must end with "_datasource.dart". '
              'Violations found:\n${namingViolations.join('\n')}',
        );
      });
    });

    group('File Organization', () {
      test(
        'Features should follow Clean Architecture folder structure',
        () async {
          final featureDirectories = await _getFeatureDirectories();

          for (final featureDir in featureDirectories) {
            final expectedSubdirs = ['data', 'domain', 'presentation'];

            for (final subdir in expectedSubdirs) {
              final subdirPath = '$featureDir/$subdir';
              expect(
                await Directory(subdirPath).exists(),
                isTrue,
                reason:
                    'Feature $featureDir missing required subdirectory: $subdir',
              );
            }

            // Check domain layer structure
            final domainPath = '$featureDir/domain';
            final expectedDomainSubdirs = [
              'entities',
              'repositories',
              'usecases',
            ];

            for (final subdir in expectedDomainSubdirs) {
              final subdirPath = '$domainPath/$subdir';
              if (await Directory(subdirPath).exists()) {
                // If directory exists, it should contain appropriate files
                final files = await Directory(subdirPath)
                    .list()
                    .where(
                      (entity) =>
                          entity is File && entity.path.endsWith('.dart'),
                    )
                    .toList();

                expect(
                  files.isNotEmpty,
                  isTrue,
                  reason: 'Domain subdirectory $subdirPath exists but is empty',
                );
              }
            }
          }
        },
      );

      test('Test structure should mirror lib structure', () async {
        final libFeatures = await _getFeatureDirectories();

        for (final featureDir in libFeatures) {
          final featureName = featureDir.split('/').last;
          final testFeatureDir = 'test/unit/features/$featureName';

          if (await Directory(testFeatureDir).exists()) {
            // Check if test structure mirrors lib structure
            final libSubdirs = await Directory(featureDir)
                .list()
                .where((entity) => entity is Directory)
                .map((dir) => dir.path.split('/').last)
                .toList();

            for (final subdir in libSubdirs) {
              final testSubdirPath = '$testFeatureDir/$subdir';
              if (subdir != 'presentation') {
                // Presentation tests go in widget/
                expect(
                  await Directory(testSubdirPath).exists(),
                  isTrue,
                  reason:
                      'Test directory structure should mirror lib structure. '
                      'Missing: $testSubdirPath',
                );
              }
            }
          }
        }
      });
    });

    group('Code Generation Compliance', () {
      test('Entities should use Freezed for immutability', () async {
        final entityFiles = await _getEntityFiles();
        final freezedViolations = <String>[];

        for (final file in entityFiles) {
          final content = await File(file).readAsString();

          if (!content.contains('@freezed') && !content.contains('with _\$')) {
            freezedViolations.add(file);
          }
        }

        expect(
          freezedViolations,
          isEmpty,
          reason:
              'All entities should use Freezed for immutability. '
              'Violations found in:\n${freezedViolations.join('\n')}',
        );
      });

      test('Models should use JSON serialization', () async {
        final modelFiles = await _getModelFiles();
        final jsonViolations = <String>[];

        for (final file in modelFiles) {
          final content = await File(file).readAsString();

          if (!content.contains('@JsonSerializable') &&
              !content.contains('fromJson') &&
              !content.contains('toJson')) {
            jsonViolations.add(file);
          }
        }

        expect(
          jsonViolations,
          isEmpty,
          reason:
              'All models should use JSON serialization. '
              'Violations found in:\n${jsonViolations.join('\n')}',
        );
      });
    });

    group('Dependency Injection Patterns', () {
      test('Repositories should be injected via constructor', () async {
        final useCaseFiles = await _getUseCaseFiles();
        final injectionViolations = <String>[];

        for (final file in useCaseFiles) {
          final content = await File(file).readAsString();

          // Check if use case has repository dependency injection
          if (content.contains('Repository') &&
              !content.contains('required this.') &&
              !content.contains('required ')) {
            injectionViolations.add(file);
          }
        }

        expect(
          injectionViolations,
          isEmpty,
          reason:
              'Use cases should inject repository dependencies via constructor. '
              'Violations found in:\n${injectionViolations.join('\n')}',
        );
      });

      test('Data sources should be injected into repositories', () async {
        final repositoryFiles = await _getRepositoryImplementations();
        final injectionViolations = <String>[];

        for (final file in repositoryFiles) {
          final content = await File(file).readAsString();

          // Check if repository has data source dependency injection
          if (content.contains('DataSource') &&
              !content.contains('required this.') &&
              !content.contains('required ')) {
            injectionViolations.add(file);
          }
        }

        expect(
          injectionViolations,
          isEmpty,
          reason:
              'Repositories should inject data source dependencies via constructor. '
              'Violations found in:\n${injectionViolations.join('\n')}',
        );
      });
    });
  });
}

// Helper functions for file discovery
Future<List<String>> _getDomainFiles() async {
  return await _getFilesInPattern('lib/features/*/domain/**/*.dart');
}

Future<List<String>> _getDataFiles() async {
  return await _getFilesInPattern('lib/features/*/data/**/*.dart');
}

Future<List<String>> _getPresentationFiles() async {
  return await _getFilesInPattern('lib/features/*/presentation/**/*.dart');
}

Future<List<String>> _getRepositoryInterfaces() async {
  return await _getFilesInPattern('lib/features/*/domain/repositories/*.dart');
}

Future<List<String>> _getRepositoryImplementations() async {
  return await _getFilesInPattern(
    'lib/features/*/data/repositories/*_repository_impl.dart',
  );
}

Future<List<String>> _getUseCaseFiles() async {
  return await _getFilesInPattern('lib/features/*/domain/usecases/*.dart');
}

Future<List<String>> _getEntityFiles() async {
  return await _getFilesInPattern(
    'lib/features/*/domain/entities/*_entity.dart',
  );
}

Future<List<String>> _getModelFiles() async {
  return await _getFilesInPattern('lib/features/*/data/models/*_model.dart');
}

Future<List<String>> _getDataSourceFiles() async {
  return await _getFilesInPattern('lib/features/*/data/datasources/*.dart');
}

Future<List<String>> _getFeatureDirectories() async {
  final featuresDir = Directory('lib/features');
  if (!await featuresDir.exists()) return [];

  return await featuresDir
      .list()
      .where((entity) => entity is Directory)
      .map((dir) => dir.path)
      .toList();
}

Future<List<String>> _getFilesInPattern(String pattern) async {
  final files = <String>[];

  // Simple pattern matching for lib/features/*/domain/**/*.dart
  final parts = pattern.split('/');
  final baseDir = parts.take(2).join('/'); // lib/features

  if (!await Directory(baseDir).exists()) return files;

  final featuresDir = Directory(baseDir);
  await for (final featureEntity in featuresDir.list()) {
    if (featureEntity is Directory) {
      await _searchDirectory(featureEntity.path, pattern, files);
    }
  }

  return files;
}

Future<void> _searchDirectory(
  String dirPath,
  String pattern,
  List<String> files,
) async {
  final dir = Directory(dirPath);
  if (!await dir.exists()) return;

  await for (final entity in dir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      // Check if file matches pattern
      if (_matchesPattern(entity.path, pattern)) {
        files.add(entity.path);
      }
    }
  }
}

bool _matchesPattern(String filePath, String pattern) {
  // Simple pattern matching - can be enhanced for more complex patterns
  final patternParts = pattern.split('/');
  final fileParts = filePath.split('/');

  if (patternParts.length > fileParts.length) return false;

  for (int i = 0; i < patternParts.length; i++) {
    final patternPart = patternParts[i];
    final filePart = fileParts[i];

    if (patternPart == '*' || patternPart == '**') {
      continue; // Wildcard matches anything
    }

    if (patternPart != filePart) {
      return false;
    }
  }

  return true;
}

int _countPublicMethods(String content) {
  // Count public method declarations
  final methodRegex = RegExp(
    r'^\s*(?:Future<.*>|Stream<.*>|[A-Z]\w*)\s+\w+\s*\(',
    multiLine: true,
  );
  return methodRegex.allMatches(content).length;
}
