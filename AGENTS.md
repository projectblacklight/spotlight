# Agent Guide: Blacklight Spotlight (`blacklight-spotlight`)

Welcome, AI Agent! This guide outlines the architecture, local test setup, and unique patterns of this codebase to help you work efficiently and safely.

---

## 1. Core Architecture & Tech Stack

This project is a **Ruby on Rails engine** that extends Blacklight to support digital exhibits.

### Key Concepts & Models
- **Exhibits (`Spotlight::Exhibit`):** The primary organizational container for exhibits.
- **Pages (`Spotlight::Page` / `Spotlight::HomePage`):** Curated pages inside an exhibit. It uses Sir Trevor for rich text block editing.
- **Custom Fields (`Spotlight::CustomField`):** Admin-defined fields added to exhibit items (e.g., multivalued text fields, read-only metadata fields).
- **Sidecars (`Spotlight::SolrDocumentSidecar`):** Database-backed extensions to Solr documents, allowing exhibit-specific metadata to persist locally.
- **Resources (`Spotlight::Resource`):** External or uploaded content that gets converted into Solr documents.

### Frontend Asset Structure
- **Source JavaScript:** Resides in `app/javascript/spotlight/` (e.g., admin widgets, custom field behaviors).
- **Core Orchestration:** `app/javascript/spotlight/index.js` listens to page loads and instantiates class components (e.g., `new AddAnother().connect()`).
- **Standard:** Use standard, modern **Vanilla JavaScript** (ES6+) for any new features or refactors. Avoid introducing new jQuery dependencies and actively migrate existing ones to modern web standards.

---

## 2. Test Environment Setup & Workflows

This engine uses `engine_cart` to generate and run a fully functional Rails test application dynamically.

### Critical Database & Setup Rules
1. **The Test App Location:** The dummy Rails application lives inside `.internal_test_app/` (which is git-ignored).
2. **Do Not Run Migrations at the Root:** Standard Rails CLI commands at the root will fail or target the wrong context. All database-specific commands must be run within `.internal_test_app/`.
3. **Schema Load is Required:** If you encounter `ActiveRecord::PendingMigrationError` when running tests, run:
   ```bash
   cd .internal_test_app && RAILS_ENV=test bundle exec rails db:schema:load
   ```
4. **App Regeneration:** If the internal test application becomes stale or corrupt, run the following at the root directory to clean and rebuild it:
   ```bash
   bundle exec rake engine_cart:regenerate
   ```

---

## 3. Running the Test Suite

This codebase uses **RSpec** with Capybara for system and feature specs.

### Running Feature/System Specs
Always run tests from the project root using `bundle exec rspec`:
```bash
# Run a specific feature test
bundle exec rspec spec/features/add_custom_field_metadata_spec.rb

# Run all model specs
bundle exec rspec spec/models
```

---

## 4. Operational Best Practices

- **Targeted Edits:** Always perform surgical file edits (e.g., using precise replacement strings) to avoid accidental overwrites or bloating the context window.
- **Code Style:** Follow standard Rails, Ruby, and modern JS linting standards. Ensure strict adherence to existing coding conventions (naming, modules, helper patterns).
- **Validation:** Always verify both implementation correctness and test suite status before finalizing any changes.
