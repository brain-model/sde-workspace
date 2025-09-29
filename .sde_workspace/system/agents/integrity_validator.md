# Integrity Validation System - SDE

## [PROFILE]

**Automatic Integrity Validation System**, responsible for ensuring consistency, integrity and reliability of SDE's knowledge base and specifications. Executes automatic checks whenever agents access files in `/knowledge` or `/system`.

## [CONTEXT]

> This system is executed automatically by all agents when accessing files in critical SDE areas. Ensures that the knowledge base is always consistent, with correct frontmatter and updated manifests.

## [FINAL OBJECTIVE]

Ensure **100% integrity and consistency** of knowledge base and specifications, validating:

- **Complete Frontmatter**: All files have correct metadata
- **Updated Manifests**: All files are correctly indexed
- **Consistent Structure**: Files are in correct folders
- **Valid Links**: Internal references are functional

## [AUTOMATIC VALIDATIONS]

### 📋 Knowledge Files Validation

#### For files in `knowledge/internal/`

1. **Required frontmatter (7 fields)**:

   ```yaml
   title: string
   category: "internal" | "raw" | "processed" | "summary"
   type: string
   tags: []
   last_updated: date
   referenced_by: []
   supersedes: []
   ```

2. **Specific validations**:
   - ✅ `id` unique and immutable
   - ✅ `category` valid (enum)
   - ✅ `created` in ISO-8601 format
   - ✅ `updated` >= `created`
   - ✅ `tags` contains at least one status (curated|needs-curation)

3. **Correct location**:
   - `notes/raw/` → `category: note-raw`
   - `notes/summary/` → `category: concept` or other processed
   - `concepts/` → `category: concept`
   - `decisions-context/` → `category: decision`

#### For files in `knowledge/external/`

1. **Files in `sources/raw/`**:

   - ✅ Original files (PDF, TXT, etc.) - IMMUTABLE
   - ✅ Should not have YAML frontmatter
   - ✅ Descriptive name with optional date

2. **Files in `sources/processed/`**:

   - ✅ Derived from `raw/` with frontmatter
   - ✅ Reference to original file in `source`
   - ✅ Tag `processed` required

3. **Processed files must reference sources**

### 📋 Specs Files Validation

#### For files in `system/specs/`

1. **Required frontmatter**:

   ```yaml
   ---
   id: spec-<slug>
   title: <Descriptive Title>
   type: (design-doc|adr|arch-analysis|process-spec|test-spec)
   status: (draft|in-review|active|deprecated|archived)
   version: 1.0.0
   topics: [domain, architecture, ...]
   created: YYYY-MM-DD
   updated: YYYY-MM-DD
   supersedes: <previous-id|null>
   supersededBy: <next-id|null>
   relations: [related ids]
   ---
   ```

2. **State validations**:
   - ✅ `status` corresponds to folder (draft/ → status: draft)
   - ✅ `version` follows semantic (MAJOR.MINOR.PATCH)
   - ✅ `supersedes`/`supersededBy` reference existing specs
   - ✅ `relations` point to valid IDs

### 📋 Manifests Validation

#### `knowledge/manifest.json`

1. **Valid structure**:

   - ✅ All files in `internal/` are listed
   - ✅ Correct SHA256 checksums
   - ✅ Updated `generatedAt` timestamps
   - ✅ Unique `ids` without duplicates

#### `system/specs/manifest.json`

1. **Specs consistency**:

   - ✅ All active specs are listed
   - ✅ Correct paths for files
   - ✅ Status corresponds to physical location
   - ✅ Updated checksums

## [AUTO-CORRECTION ACTIONS]

### 🔧 Detected Problems and Solutions

#### Missing/Incomplete Frontmatter

- **Detect**: File without initial `---` or missing fields
- **Fix**: Add frontmatter based on templates

#### File Not Listed in Manifest

- **Detect**: File exists but not in `manifest.json`
- **Fix**: Add entry to manifest

#### Incorrect Location

- **Detect**: `category` doesn't correspond to directory
- **Fix**: Update `category` or move file

#### Outdated Checksum

- **Detect**: SHA256 hash doesn't match current content
- **Fix**: Recalculate and update checksum

#### Broken Links

- **Detect**: Invalid `supersedes`/`relations` references
- **Fix**: Remove references or correct IDs

### 🛠️ Auto-Correction Templates

#### For Knowledge/Internal

   ```yaml
   ---
   title: "[FILE] - Needs Title"
   category: "raw"  # based on directory
   type: "note"     # inferred from content
   tags: ["needs-curation"]
   last_updated: "2024-01-XX"
   referenced_by: []
   supersedes: []
   ---
   ```

#### For System/Specs

   ```yaml
   ---
   id: "spec-auto-generated-XXXX"
   title: "[SPEC] - Needs Title"
   type: "design-doc"
   status: "draft"
   version: "0.1.0"
   topics: ["misc"]
   created: "2024-01-XX"
   updated: "2024-01-XX"
   supersedes: null
   supersededBy: null
   relations: []
   ---
   ```

#### For Manifest.json

   ```json
   {
     "id": "auto-generated-XXXX",
     "path": "knowledge/internal/path/file.md",
     "title": "[INFERRED FROM FRONTMATTER]",
     "category": "[INFERRED FROM FOLDER]",
     "checksum": "[CALCULATED SHA256]",
     "created": "[FILE DATE]",
     "updated": "[LAST MODIFICATION]"
   }
   ```

## [VALIDATION TRIGGERS]

### 📋 Validation Commands

#### Complete Validation

```bash
# Validate everything
./scripts/validate-knowledge.sh --full
./scripts/validate-specs.sh --full
```

#### Specific Validations

```bash
# Frontmatter only
./scripts/validate-knowledge.sh --frontmatter-only

# Manifests only
./scripts/validate-knowledge.sh --manifest-only

# Specific file
./scripts/validate-knowledge.sh --file="path/to/file.md"

# Auto-correction
./scripts/validate-knowledge.sh --auto-fix
```

### ⚙️ Agent Integration

**ALL agents execute these checks automatically:**

1. **Before reading any file** in `/knowledge` or `/system`:
   - Verify if file has valid frontmatter
   - Verify if it's listed in manifest
   - Report found problems

2. **After creating/editing files**:
   - Update frontmatter with `last_updated`
   - Recalculate checksums
   - Update manifests

3. **Before finishing any task**:
   - Execute complete validation
   - Apply auto-corrections when possible
   - Report final integrity status

### ⚠️ When Problems Detected

```text
🔍 INTEGRITY PROBLEMS DETECTED:

❌ /knowledge/internal/notes/raw/example.md
   - Incomplete frontmatter (missing: title, tags)
   - Not listed in manifest.json
   
❌ /system/specs/draft/example-spec.md
   - Inconsistent 'status' field (file in draft/ but status: active)
   - Outdated checksum in manifest

🔧 APPLYING AUTO-CORRECTIONS...
✅ Frontmatter added with required fields
✅ File added to manifest
✅ Status corrected to 'draft'
✅ Checksum recalculated

✅ INTEGRITY RESTORED
```

### ✅ When Everything OK

```text
✅ COMPLETE INTEGRITY VALIDATION

📊 STATISTICS:
- Knowledge Files: 45 ✅
- Specs Files: 12 ✅  
- Manifests: 2 ✅
- Internal Links: 23 ✅

🔐 SYSTEM 100% INTEGRAL
```

## [AUTOMATIC EXECUTION]

**This system is transparent to the end user - executes automatically when agents access critical files, ensuring that the knowledge base is always integral and reliable.**

---

> 💡 **Meta-Development**: This system was created to ensure reliability of SDE's own knowledge base, applying rigorous validations and intelligent auto-corrections.
