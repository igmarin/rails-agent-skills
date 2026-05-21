import { describe, expect, it } from "vitest";
import {
  buildRawUrl,
  categoryFromPath,
  extractSkillDescription,
  listSkills,
  listAgents,
  listWorkflows,
  loadSkill,
  loadAgent,
  loadWorkflow,
  normalizeSkillName,
  resolveSkillPath,
  type TileManifest,
  type AgentManifest,
} from "../src/skill-content";

const manifest: TileManifest = {
  skills: {
    "code-review": { path: "skills/code-quality/code-review/SKILL.md" },
  },
};

describe("normalizeSkillName", () => {
  it("keeps a plain skill name", () => {
    expect(normalizeSkillName("code-review")).toBe("code-review");
  });

  it("extracts the skill directory from a path", () => {
    expect(normalizeSkillName("skills/code-quality/code-review")).toBe("code-review");
  });

  it("extracts the skill directory from a SKILL.md path", () => {
    expect(normalizeSkillName("skills/code-quality/code-review/SKILL.md")).toBe("code-review");
  });
});

describe("resolveSkillPath", () => {
  it("returns a manifest path for a known skill", () => {
    expect(resolveSkillPath(manifest, "code-review")).toBe("skills/code-quality/code-review/SKILL.md");
  });

  it("returns null for unknown skills", () => {
    expect(resolveSkillPath(manifest, "missing")).toBeNull();
  });
});

describe("buildRawUrl", () => {
  it("builds a GitHub raw URL for a manifest path", () => {
    expect(buildRawUrl("https://raw.githubusercontent.com/owner/repo/main", "skills/a/SKILL.md")).toBe(
      "https://raw.githubusercontent.com/owner/repo/main/skills/a/SKILL.md",
    );
  });
});

describe("categoryFromPath", () => {
  it("returns the nested skill category", () => {
    expect(categoryFromPath("skills/code-quality/code-review/SKILL.md")).toBe("code-quality");
  });

  it("returns agent for agent paths", () => {
    expect(categoryFromPath("agents/tdd/SKILL.md")).toBe("agent");
  });
});

describe("extractSkillDescription", () => {
  it("extracts folded frontmatter descriptions", () => {
    expect(
      extractSkillDescription(`---\nname: code-review\ndescription: >\n  Reviews Rails code for bugs,\n  regressions, and missing tests.\nmetadata:\n  version: 1.0.0\n---\n# Code Review\n`),
    ).toBe("Reviews Rails code for bugs, regressions, and missing tests.");
  });
});

describe("skill loading", () => {
  const skillBody = `---\nname: code-review\ndescription: >\n  Reviews Rails code for bugs and missing tests.\n---\n# Code Review\n`;

  function fetcher(url: string) {
    if (url.endsWith("/tile.json")) {
      return Promise.resolve(new Response(JSON.stringify(manifest)));
    }

    if (url.endsWith("/skills/code-quality/code-review/SKILL.md")) {
      return Promise.resolve(new Response(skillBody));
    }

    return Promise.resolve(new Response("not found", { status: 404 }));
  }

  it("lists structured skill metadata", async () => {
    await expect(listSkills(fetcher as typeof fetch, "https://example.test")).resolves.toEqual([
      {
        name: "code-review",
        path: "skills/code-quality/code-review/SKILL.md",
        category: "code-quality",
        description: "Reviews Rails code for bugs and missing tests.",
      },
    ]);
  });

  it("skips unavailable skills while preserving successful skill order", async () => {
    function partialFetcher(url: string) {
      if (url.endsWith("/tile.json")) {
        return Promise.resolve(new Response(JSON.stringify(manifest)));
      }

      return Promise.resolve(new Response("not found", { status: 404 }));
    }

    await expect(listSkills(partialFetcher as typeof fetch, "https://example.test")).resolves.toEqual([]);
  });

  it("loads structured skill content", async () => {
    await expect(loadSkill("code-review", fetcher as typeof fetch, "https://example.test")).resolves.toMatchObject({
      name: "code-review",
      path: "skills/code-quality/code-review/SKILL.md",
      category: "code-quality",
      description: "Reviews Rails code for bugs and missing tests.",
      content: skillBody,
    });
  });
});

const agentManifest: AgentManifest = {
  agents: {
    "tdd": { path: "agents/tdd/SKILL.md" },
    "bug-fix": { path: "agents/bug-fix/SKILL.md" },
  },
};

describe("agent loading", () => {
  const agentBody = `---\nname: tdd\ndescription: >\n  Full TDD feature cycle: test, implement, review, PR.\nmetadata:\n  keywords: tdd, test-driven, red-green-refactor\n---\n# TDD Agent\n`;

  function fetcher(url: string) {
    if (url.endsWith("/agents.json")) {
      return Promise.resolve(new Response(JSON.stringify(agentManifest)));
    }

    if (url.endsWith("/agents/tdd/SKILL.md")) {
      return Promise.resolve(new Response(agentBody));
    }

    return Promise.resolve(new Response("not found", { status: 404 }));
  }

  it("lists structured agent metadata", async () => {
    const agents = await listAgents(fetcher as typeof fetch, "https://example.test");
    expect(agents).toHaveLength(1);
    expect(agents[0]).toEqual({
      name: "tdd",
      path: "agents/tdd/SKILL.md",
      description: "Full TDD feature cycle: test, implement, review, PR.",
      keywords: "tdd, test-driven, red-green-refactor",
    });
  });

  it("skips unavailable agents", async () => {
    function partialFetcher(url: string) {
      if (url.endsWith("/agents.json")) {
        return Promise.resolve(new Response(JSON.stringify(agentManifest)));
      }

      return Promise.resolve(new Response("not found", { status: 404 }));
    }

    await expect(listAgents(partialFetcher as typeof fetch, "https://example.test")).resolves.toEqual([]);
  });

  it("loads structured agent content", async () => {
    await expect(loadAgent("tdd", fetcher as typeof fetch, "https://example.test")).resolves.toMatchObject({
      name: "tdd",
      path: "agents/tdd/SKILL.md",
      description: "Full TDD feature cycle: test, implement, review, PR.",
      keywords: "tdd, test-driven, red-green-refactor",
      content: agentBody,
    });
  });

  it("returns null for unknown agents", async () => {
    await expect(loadAgent("missing", fetcher as typeof fetch, "https://example.test")).resolves.toBeNull();
  });
});

describe("workflow backward compat", () => {
  const agentBody = `---\nname: tdd\ndescription: >\n  Full TDD feature cycle: test, implement, review, PR.\nmetadata:\n  keywords: tdd, test-driven, red-green-refactor\n---\n# TDD Agent\n`;

  function fetcher(url: string) {
    if (url.endsWith("/agents.json")) {
      return Promise.resolve(new Response(JSON.stringify(agentManifest)));
    }

    if (url.endsWith("/agents/tdd/SKILL.md")) {
      return Promise.resolve(new Response(agentBody));
    }

    return Promise.resolve(new Response("not found", { status: 404 }));
  }

  it("listWorkflows delegates to listAgents", async () => {
    const workflows = await listWorkflows(fetcher as typeof fetch, "https://example.test");
    expect(workflows).toHaveLength(1);
    expect(workflows[0].name).toBe("tdd");
  });

  it("loadWorkflow delegates to loadAgent", async () => {
    const result = await loadWorkflow("tdd", fetcher as typeof fetch, "https://example.test");
    expect(result).not.toBeNull();
    expect(result!.name).toBe("tdd");
  });
});
