**AGENT HANDOFF TEMPLATE**

Use this template when handing off work between specialized agents:

---

## 🔄 **HANDOFF FROM [CURRENT-AGENT] TO [NEXT-AGENT]**

### ✅ **COMPLETED WORK:**
- [Specific tasks completed by current agent]
- [Files created or modified]
- [Tests written or infrastructure set up]
- [Any configuration or setup completed]

### 🎯 **NEXT AGENT REQUIREMENTS:**
- [Specific tasks the next agent needs to complete]
- [Expected deliverables]
- [Any dependencies or prerequisites]

### 📋 **CONTEXT & IMPLEMENTATION DETAILS:**
- [Important architectural decisions made]
- [Specific patterns or approaches used]
- [Any constraints or requirements to follow]
- [Integration points with existing code]

### 📁 **FILES AFFECTED:**
```
Modified:
- [list of modified files]

Created:
- [list of new files]

Next Agent Should Work On:
- [specific files or areas the next agent should focus on]
```

### 🧪 **TESTING STATUS:**
- [Tests already written and passing]
- [Tests that need to be written by next agent]
- [Any test fixtures or mocks created]

### ⚠️ **IMPORTANT NOTES:**
- [Any critical information for the next agent]
- [Potential issues or considerations]
- [Specific requirements that must be followed]

### 🔍 **VALIDATION REQUIREMENTS:**
- [How the next agent should validate their work]
- [Integration points to test]
- [Performance or quality requirements]

### 🚨 **MANDATORY COMPLETION REQUIREMENTS:**
- [ ] ✅ **100% Task Completion**: All assigned tasks MUST be 100% complete
- [ ] ✅ **Platform Verification**: Code MUST build successfully on Web, Android, iOS
- [ ] ✅ **Test Coverage**: All code MUST have appropriate tests (unit/widget/integration)
- [ ] ✅ **Documentation Updates**: All relevant documentation MUST be updated
- [ ] ✅ **Custom Commands**: New procedures MUST be documented in commands
- [ ] ✅ **Integration Validation**: Work MUST integrate seamlessly with other agents

### 📋 **COMPLETION VERIFICATION:**
```bash
# MANDATORY: Each agent must run these before handoff
flutter build web --release        # ✅ Web build success required
flutter build apk --release        # ✅ Android build success required  
flutter build ios --release --no-codesign # ✅ iOS build success required
flutter test --coverage           # ✅ All tests must pass
flutter analyze                   # ✅ No critical errors allowed
dart format --set-exit-if-changed . # ✅ Code formatting compliance
```

### 🚫 **NO HANDOFF UNTIL:**
- ALL completion requirements are verified ✅
- ALL platform builds are successful ✅
- ALL tests are passing with adequate coverage ✅
- ALL documentation updates are completed ✅

---

**Next Agent**: You MUST acknowledge this handoff AND confirm that ALL completion requirements have been met before proceeding. Verify that the previous agent completed 100% of their assigned tasks.