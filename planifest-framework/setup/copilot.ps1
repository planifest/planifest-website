# GitHub Copilot - tool configuration
# https://docs.github.com/en/copilot
#
# Skills:    .github/skills/{name}/SKILL.md       (auto-discovered)
# Workflows: .github/copilot-workflows/{name}.md   (natural language workflows - avoids GitHub Actions conflict)
# Boot file: .github/copilot-instructions.md

@{
    SkillsDir    = '.github\skills'
    WorkflowsDir = '.github\copilot-workflows'
    BootFile     = '.github\copilot-instructions.md'
    BootTemplate = "planifest-framework/templates/standard-boot.md"
}
