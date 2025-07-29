Brainstorm new feature or change: $ARGUMENTS

**Command Documentation**: This command provides comprehensive 8-step feature analysis and implementation planning.

**Related Documentation**:
- **CLAUDE.md** - Architecture patterns, UI design system, Firebase configuration, and agent coordination
- **DEVELOPMENT_GUIDE.md** - Development workflow, timeline planning, and quality standards
- **docs/github_instaruction.md** - Issue creation standards and commit message formats
- **.claude/agents/** - Specialized sub-agents for different aspects of implementation
- **.claude/commands/implement-issue.md** - Follow-up command for actual implementation

**COMPREHENSIVE FEATURE BRAINSTORMING SESSION**

## 🧠 **STEP 1: FEATURE ANALYSIS**

**Feature/Change Request:** $ARGUMENTS

Let me analyze this systematically:

### **1.1 Feature Understanding:**
- **What is the core functionality?**
- **Who is the target user?** (Host, Player, Both)
- **What problem does this solve?**
- **How does it fit into the quiz app ecosystem?**

### **1.2 User Experience Impact:**
- **User Journey**: How will users discover and use this feature?
- **UI/UX Requirements**: What screens/components are needed?
- **Accessibility**: How will this work for users with disabilities?
- **Cross-Platform**: Any platform-specific considerations?

## 🏗️ **STEP 2: TECHNICAL ARCHITECTURE PLANNING**

### **2.1 Clean Architecture Impact** (reference CLAUDE.md architecture section):
- **Domain Layer**: What new entities, use cases, repositories needed?
- **Data Layer**: Firestore collections, security rules, data models?
- **Presentation Layer**: New screens, widgets, state management?

**Architecture Reference**: Follow the exact folder structure and patterns defined in CLAUDE.md

### **2.2 Database Design:**
- **Firestore Collections**: What new/modified collections needed?
```
Example:
feature_name/
  {documentId}/
    - field1: type
    - field2: type
    - relationships: references
```

### **2.3 Real-time Requirements:**
- **Live Updates**: Does this need real-time synchronization?
- **Performance**: Expected load and optimization needs?
- **Scalability**: How will this perform with many concurrent users?

## 🎨 **STEP 3: UI/UX DESIGN PLANNING**

### **3.1 Component Requirements** (reference CLAUDE.md UI/UX Design Guidelines):
- **New Components**: What centralized components need to be created?
- **Color Usage**: Which approved colors from the CLAUDE.md design system?
- **Animations**: What micro-interactions and transitions (see animation standards)?
- **Responsive Design**: Mobile, tablet, web considerations?

**Design System Compliance**: MUST use only approved colors, components, and spacing from CLAUDE.md

### **3.2 Design System Compliance:**
- **Typography**: Which text styles from the system?
- **Spacing**: Which spacing constants to use?
- **Icons and Assets**: Any new visual assets needed?

## 🧪 **STEP 4: TESTING STRATEGY**

### **4.1 Test Planning:**
- **Unit Tests**: Domain logic and use cases to test?
- **Widget Tests**: UI components and user interactions?
- **Integration Tests**: End-to-end workflows to validate?
- **Performance Tests**: Load testing requirements?

### **4.2 Quality Gates:**
- **Acceptance Criteria**: How do we know it's done?
- **Definition of Done**: Quality standards to meet?

## 🔥 **STEP 5: FIREBASE CONSIDERATIONS**

### **5.1 Services Needed** (reference CLAUDE.md Firebase Configuration):
- **Firestore**: New collections, queries, security rules?
- **Authentication**: Any auth flow changes?
- **Cloud Functions**: Server-side logic needed?
- **Storage**: File uploads or media handling?

**Firebase Reference**: Follow database design and security patterns from CLAUDE.md Firestore section

### **5.2 Security & Performance:**
- **Security Rules**: How to protect the new data?
- **Query Optimization**: Efficient data access patterns?
- **Cost Implications**: Firestore read/write impact?

## 📋 **STEP 6: IMPLEMENTATION BREAKDOWN**

### **6.1 GitHub Issues Creation:**
Based on analysis, I recommend creating these issues:

```
1. [SETUP] Configure [feature] infrastructure
   - Database schema and security rules
   - Core architecture foundation

2. [DOMAIN] Implement [feature] business logic  
   - Entities, use cases, repository interfaces
   - Comprehensive unit tests

3. [DATA] Build [feature] data layer
   - Firestore integration and data models
   - Repository implementations

4. [UI] Create [feature] user interface
   - Screens, components, animations
   - Widget tests and responsive design

5. [INTEGRATION] Connect [feature] end-to-end
   - Full workflow integration
   - Performance optimization
```

### **6.2 Agent Assignment Strategy** (see .claude/agents/ for detailed roles):
- **Primary Agents**: Which specialized agents for each phase?
- **Coordination**: How will agents hand off work (reference CLAUDE.md handoff protocols)?
- **Validation**: Quality checkpoints throughout?

**Agent Documentation**: Each agent's specific capabilities are documented in `.claude/agents/[agent-name].md`

## 🚀 **STEP 7: RECOMMENDATIONS & NEXT STEPS**

### **7.1 Implementation Approach:**
- **Complexity Assessment**: Simple/Medium/Complex feature?
- **Timeline Estimate**: Expected development time?
- **Risk Factors**: Technical challenges or dependencies?

### **7.2 Alternative Approaches:**
- **MVP Version**: What's the minimum viable implementation?
- **Progressive Enhancement**: How to build incrementally?
- **Integration Points**: How does this connect with existing features?

## 💡 **STEP 8: FINAL BRAINSTORM OUTPUT**

**RECOMMENDED ACTION PLAN:**

1. **Create GitHub Issues**: [List specific issues to create]
2. **Start with Issue**: [Which issue to tackle first and why]
3. **Agent Assignment**: [Which agents to use for implementation]
4. **Key Considerations**: [Critical points to remember]
5. **Success Metrics**: [How to measure successful implementation]

**Would you like me to:**
- Create the recommended GitHub issues?
- Start implementation of the first issue?
- Dive deeper into any specific aspect?
- Explore alternative approaches?
- Update relevant documentation with brainstorming insights?

**Documentation Note**: Consider updating CLAUDE.md with any new architectural patterns, UI components, or Firebase configurations identified during this brainstorming session.

---

**Next Command Suggestions:**
- `gh issue create --title "[TYPE] Feature: Description" --body "Issue content"` (follow docs/github_instaruction.md format)
- `/project:implement-issue {number}` to start development (see .claude/commands/implement-issue.md)
- `scripts/develop-feature.sh <issue-number>` for automated branch setup
- `scripts/quality-check.sh` for validation before PR

**Integration**: This brainstorm output directly feeds into the implementation workflow defined in DEVELOPMENT_GUIDE.md

**Documentation Update Requirement**: When brainstorming identifies new patterns, components, or architectural decisions, ensure these insights are captured in relevant documentation for future reference and agent context.