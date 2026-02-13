VERDICT: ADVISE

WARNINGS:

- [ai-modeling]: Negative example lacks SCOPE/CHANGE/WHY field labels, undermining its contrastive teaching value
  SCOPE: Reviewer prompt template in skills/nefario/SKILL.md, section A (bad example block)
  CHANGE: The bad example should use the same SCOPE/CHANGE/WHY field labels as the good example, with bad *content* in those fields. Currently the bad example uses bare text ("step 1", "Add validation as discussed", "See the analysis above") without field labels, making the contrast about format presence vs. absence rather than about content quality. Change to: `SCOPE: step 1` / `CHANGE: Add validation as discussed` / `WHY: See the analysis above` so the model learns the issue is vague content, not missing labels.
  WHY: LLMs learn format from examples more reliably than from prose rules. When the good and bad examples differ in both structure (labeled fields vs. bare text) and content quality (specific vs. vague), the model may conclude that simply including the labels is sufficient, without learning the content-quality constraint. Isomorphic examples -- same structure, different content quality -- produce stronger contrastive learning. This is a well-established few-shot prompting principle.
  TASK: Task 2

- [ai-modeling]: BLOCK verdict format has no examples, relying on prose-only instruction
  SCOPE: Reviewer prompt template in skills/nefario/SKILL.md, BLOCK format section
  CHANGE: Add one concrete good example for the BLOCK verdict format, parallel to the ADVISE good example. For instance: `SCOPE: install.sh symlink targets` / `ISSUE: Script creates symlinks to paths that do not exist on clean checkout` / `RISK: First-time contributors will get broken agent installations with no error message` / `SUGGESTION: Add path existence check before ln -s, emit warning listing missing targets`
  WHY: The plan correctly adds examples for ADVISE but provides none for BLOCK. BLOCK verdicts are rarer but higher-stakes -- they halt execution. Without an example, BLOCK self-containment relies entirely on the prose instruction "SCOPE, ISSUE, RISK, and SUGGESTION must each be self-contained," which is weaker enforcement than an example. Adding one example costs approximately 60 tokens per reviewer invocation (under $0.001 per orchestration) and brings BLOCK to the same compliance standard as ADVISE.
  TASK: Task 2
