# Stage receipts

At every required lifecycle boundary, provide this complete portable Markdown receipt before yielding:

```markdown
**总体进度：第 <current>/7 阶段——<stage name>**
已完成：<verified completed work>
当前结果：<decision, evidence, or blocker>
剩余任务：<remaining governed work>
**下一步计划：<next owner and action>**
**需要你处理：<decision/action, or 无>**
```

Use `**特别提醒：<material risk or evidence limit>**` and `**阻塞原因：<blocker>**` when applicable. Use standard Markdown bold only for attention fields; do not bold the whole receipt. If no action is required, `需要你处理：无` is acceptable.

## Required emission points

Emit a receipt at all nine points:

1. mode selection;
2. context-scope approval;
3. project baseline completion;
4. upgrade-direction approval;
5. contract freeze;
6. execution start;
7. execution completion, failure, pause, or block;
8. independent-review completion;
9. transition to the next phase.

Ordinary clarification and unchanged progress updates stay short and do not repeat the dashboard. When an authorized governance-pack write cannot be observed, show the same receipt in the conversation, label it `not_persisted`, and provide a copy-ready record. Never claim persistence that did not occur.
