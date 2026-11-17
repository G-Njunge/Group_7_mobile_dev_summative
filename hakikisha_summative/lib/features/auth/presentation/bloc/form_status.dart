/// Shared types for the auth form cubits.
library;

/// Where a form submission is.
enum FormStatus { idle, submitting, success, failure }

/// The fields used across the auth forms. Each form cubit keeps a
/// `Map<AuthField, String>` of the current error per field.
enum AuthField { fullName, email, phone, password }

/// Keeps only the fields that actually have an error.
Map<AuthField, String> collectErrors(Map<AuthField, String?> results) => {
  for (final entry in results.entries)
    if (entry.value != null) entry.key: entry.value!,
};
