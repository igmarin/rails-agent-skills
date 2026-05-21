import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { McpAgent } from "agents/mcp";
import { z } from "zod";
import { DEFAULT_RAW_BASE, listSkills, loadSkill, listAgents, loadAgent } from "./skill-content";

export interface Env {
  RailsAgentSkillsMCP: DurableObjectNamespace<RailsAgentSkillsMCP>;
  RAW_BASE?: string;
}

function rawBase(env: Env): string {
  return env.RAW_BASE ?? DEFAULT_RAW_BASE;
}

function json(data: unknown, init: ResponseInit = {}): Response {
  return new Response(JSON.stringify(data, null, 2), {
    ...init,
    headers: {
      "content-type": "application/json; charset=utf-8",
      ...init.headers,
    },
  });
}

function serverCard() {
  const tools = toolDefinitions();

  return {
    serverInfo: {
      name: "rails-agent-skills",
      version: "5.1.5",
    },
    authentication: {
      required: false,
    },
    tools,
    resources: [],
    prompts: [],
  };
}

const skillMetadataSchema = z.object({
  name: z.string().describe("Stable skill name, for example code-review."),
  path: z.string().describe("Repository path to the skill's SKILL.md file."),
  category: z.string().describe("Top-level skill category such as testing, api, or engines."),
  description: z.string().describe("Short routing description from the skill frontmatter."),
});

const listSkillsOutputSchema = {
  count: z.number().int().nonnegative().describe("Number of public skills returned."),
  skills: z.array(skillMetadataSchema).describe("Public Rails Agent Skills available through use_skill."),
};

const useSkillOutputSchema = {
  found: z.boolean().describe("Whether the requested skill was found."),
  name: z.string().nullable().describe("Normalized skill name, or null when not found."),
  path: z.string().nullable().describe("Repository path to the skill's SKILL.md file, or null when not found."),
  category: z.string().nullable().describe("Skill category, or null when not found."),
  description: z.string().nullable().describe("Short routing description, or null when not found."),
  content: z.string().nullable().describe("Full SKILL.md instructions, or null when not found."),
  error: z.string().nullable().describe("Error message when the skill cannot be loaded."),
};

const agentMetadataSchema = z.object({
  name: z.string().describe("Agent directory name, for example tdd or bug-fix."),
  path: z.string().describe("Repository path to the agent's SKILL.md file."),
  description: z.string().describe("Short routing description from the agent frontmatter."),
  keywords: z.string().describe("Comma-separated discovery keywords."),
});

const listAgentsOutputSchema = {
  count: z.number().int().nonnegative().describe("Number of agents returned."),
  agents: z.array(agentMetadataSchema).describe("Rails Agents available through use_agent."),
};

const useAgentOutputSchema = {
  found: z.boolean().describe("Whether the requested agent was found."),
  name: z.string().nullable().describe("Normalized agent name, or null when not found."),
  path: z.string().nullable().describe("Repository path to SKILL.md, or null when not found."),
  description: z.string().nullable().describe("Short routing description, or null when not found."),
  content: z.string().nullable().describe("Full SKILL.md instructions, or null when not found."),
  error: z.string().nullable().describe("Error message when the agent cannot be loaded."),
};

function toolAnnotations(title: string) {
  return {
    title,
    readOnlyHint: true,
    destructiveHint: false,
    idempotentHint: true,
    openWorldHint: false,
  };
}

const TOOL_REGISTRY = {
  use_skill: {
    title: "Use Rails Skill",
    description:
      "Read one public Rails Agent Skill by name after selecting it from list_skills. Returns the full SKILL.md instructions plus structured metadata. This tool is read-only and has no repository side effects.",
    inputSchema: {
      type: "object",
      properties: {
        skill_name: {
          type: "string",
          description: "The directory name of the skill, such as code-review or write-tests.",
        },
      },
      required: ["skill_name"],
      additionalProperties: false,
    },
    runtimeInputSchema: {
      skill_name: z.string().describe("Skill name, for example code-review or write-tests."),
    },
    outputSchema: {
      type: "object",
      properties: {
        found: { type: "boolean", description: "Whether the requested skill was found." },
        name: { type: ["string", "null"], description: "Normalized skill name, or null when not found." },
        path: { type: ["string", "null"], description: "Repository path to SKILL.md, or null when not found." },
        category: { type: ["string", "null"], description: "Skill category, or null when not found." },
        description: { type: ["string", "null"], description: "Short routing description, or null when not found." },
        content: { type: ["string", "null"], description: "Full SKILL.md instructions, or null when not found." },
        error: { type: ["string", "null"], description: "Error message when the skill cannot be loaded." },
      },
      required: ["found", "name", "path", "category", "description", "content", "error"],
      additionalProperties: false,
    },
    runtimeOutputSchema: useSkillOutputSchema,
  },
  list_skills: {
    title: "List Rails Skills",
    description:
      "Discover public Rails Agent Skills before loading one with use_skill. Returns names, categories, paths, and routing descriptions only; it does not return full skill bodies. This tool is read-only and has no repository side effects.",
    inputSchema: {
      type: "object",
      properties: {},
      additionalProperties: false,
    },
    runtimeInputSchema: {},
    outputSchema: {
      type: "object",
      properties: {
        count: { type: "integer", minimum: 0, description: "Number of public skills returned." },
        skills: {
          type: "array",
          description: "Public Rails Agent Skills available through use_skill.",
          items: {
            type: "object",
            properties: {
              name: { type: "string", description: "Stable skill name." },
              path: { type: "string", description: "Repository path to SKILL.md." },
              category: { type: "string", description: "Top-level skill category." },
              description: { type: "string", description: "Short routing description." },
            },
            required: ["name", "path", "category", "description"],
            additionalProperties: false,
          },
        },
      },
      required: ["count", "skills"],
      additionalProperties: false,
    },
    runtimeOutputSchema: listSkillsOutputSchema,
  },
  use_agent: {
    title: "Use Rails Agent",
    description:
      "Read one Rails Agent by name after selecting it from list_agents. Returns the full SKILL.md instructions plus structured metadata. This tool is read-only and has no repository side effects.",
    inputSchema: {
      type: "object",
      properties: {
        agent_name: {
          type: "string",
          description: 'The directory name of the agent (e.g. "tdd", "review", "bug-fix", "graphql").',
        },
      },
      required: ["agent_name"],
      additionalProperties: false,
    },
    runtimeInputSchema: {
      agent_name: z.string().describe('Agent name, for example tdd, review, or bug-fix.'),
    },
    outputSchema: {
      type: "object",
      properties: {
        found: { type: "boolean", description: "Whether the requested agent was found." },
        name: { type: ["string", "null"], description: "Normalized agent name, or null when not found." },
        path: { type: ["string", "null"], description: "Repository path to SKILL.md, or null when not found." },
        description: { type: ["string", "null"], description: "Short routing description, or null when not found." },
        content: { type: ["string", "null"], description: "Full SKILL.md instructions, or null when not found." },
        error: { type: ["string", "null"], description: "Error message when the agent cannot be loaded." },
      },
      required: ["found", "name", "path", "description", "content", "error"],
      additionalProperties: false,
    },
    runtimeOutputSchema: useAgentOutputSchema,
  },
  list_agents: {
    title: "List Rails Agents",
    description:
      "Discover available Rails Agents before loading one with use_agent. Returns names, paths, descriptions, and keywords only; it does not return full agent bodies. This tool is read-only and has no repository side effects.",
    inputSchema: {
      type: "object",
      properties: {},
      additionalProperties: false,
    },
    runtimeInputSchema: {},
    outputSchema: {
      type: "object",
      properties: {
        count: { type: "integer", minimum: 0, description: "Number of agents returned." },
        agents: {
          type: "array",
          description: "Rails Agents available through use_agent.",
          items: {
            type: "object",
            properties: {
              name: { type: "string", description: "Agent directory name." },
              path: { type: "string", description: "Repository path to SKILL.md." },
              description: { type: "string", description: "Short routing description." },
              keywords: { type: "string", description: "Comma-separated discovery keywords." },
            },
            required: ["name", "path", "description", "keywords"],
            additionalProperties: false,
          },
        },
      },
      required: ["count", "agents"],
      additionalProperties: false,
    },
    runtimeOutputSchema: listAgentsOutputSchema,
  },
} as const;

function toolDefinitions() {
  return Object.entries(TOOL_REGISTRY).map(([name, tool]) => ({
    name,
    title: tool.title,
    description: tool.description,
    inputSchema: tool.inputSchema,
    outputSchema: tool.outputSchema,
    annotations: toolAnnotations(tool.title),
  }));
}

export class RailsAgentSkillsMCP extends McpAgent<Env> {
  server = new McpServer({
    name: "rails-agent-skills",
    version: "5.1.5",
  });

  async init() {
    this.server.registerTool(
      "use_skill",
      {
        title: TOOL_REGISTRY.use_skill.title,
        description: TOOL_REGISTRY.use_skill.description,
        inputSchema: TOOL_REGISTRY.use_skill.runtimeInputSchema,
        outputSchema: TOOL_REGISTRY.use_skill.runtimeOutputSchema,
        annotations: toolAnnotations(TOOL_REGISTRY.use_skill.title),
      },
      async ({ skill_name }) => {
        const skill = await loadSkill(skill_name, fetch, rawBase(this.env));

        if (!skill) {
          const structuredContent = {
            found: false,
            name: null,
            path: null,
            category: null,
            description: null,
            content: null,
            error: `Skill '${skill_name}' not found.`,
          };

          return {
            isError: true,
            content: [{ type: "text", text: structuredContent.error }],
            structuredContent,
          };
        }

        const structuredContent = {
          found: true,
          name: skill.name,
          path: skill.path,
          category: skill.category,
          description: skill.description,
          content: skill.content,
          error: null,
        };

        return {
          content: [{ type: "text", text: skill.content }],
          structuredContent,
        };
      },
    );

    this.server.registerTool("list_skills", {
      title: TOOL_REGISTRY.list_skills.title,
      description: TOOL_REGISTRY.list_skills.description,
      inputSchema: TOOL_REGISTRY.list_skills.runtimeInputSchema,
      outputSchema: TOOL_REGISTRY.list_skills.runtimeOutputSchema,
      annotations: toolAnnotations(TOOL_REGISTRY.list_skills.title),
    }, async () => {
      const skills = await listSkills(fetch, rawBase(this.env));
      const structuredContent = { count: skills.length, skills };

      return {
        content: [{ type: "text", text: skills.map((skill) => `${skill.name}\t${skill.category}\t${skill.description}`).join("\n") }],
        structuredContent,
      };
    });

    this.server.registerTool(
      "use_agent",
      {
        title: TOOL_REGISTRY.use_agent.title,
        description: TOOL_REGISTRY.use_agent.description,
        inputSchema: TOOL_REGISTRY.use_agent.runtimeInputSchema,
        outputSchema: TOOL_REGISTRY.use_agent.runtimeOutputSchema,
        annotations: toolAnnotations(TOOL_REGISTRY.use_agent.title),
      },
      async ({ agent_name }) => {
        const agent = await loadAgent(agent_name, fetch, rawBase(this.env));

        if (!agent) {
          const structuredContent = {
            found: false,
            name: null,
            path: null,
            description: null,
            content: null,
            error: `Agent '${agent_name}' not found.`,
          };

          return {
            isError: true,
            content: [{ type: "text", text: structuredContent.error }],
            structuredContent,
          };
        }

        const structuredContent = {
          found: true,
          name: agent.name,
          path: agent.path,
          description: agent.description,
          content: agent.content,
          error: null,
        };

        return {
          content: [{ type: "text", text: agent.content }],
          structuredContent,
        };
      },
    );

    this.server.registerTool("list_agents", {
      title: TOOL_REGISTRY.list_agents.title,
      description: TOOL_REGISTRY.list_agents.description,
      inputSchema: TOOL_REGISTRY.list_agents.runtimeInputSchema,
      outputSchema: TOOL_REGISTRY.list_agents.runtimeOutputSchema,
      annotations: toolAnnotations(TOOL_REGISTRY.list_agents.title),
    }, async () => {
      const agents = await listAgents(fetch, rawBase(this.env));
      const structuredContent = { count: agents.length, agents };

      return {
        content: [{ type: "text", text: agents.map((a) => `${a.name}\t${a.description}`).join("\n") }],
        structuredContent,
      };
    });
  }
}

const mcpHandler = RailsAgentSkillsMCP.serve("/mcp", { binding: "RailsAgentSkillsMCP" });

export default {
  async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
    const url = new URL(request.url);

    if (url.pathname === "/" || url.pathname === "/health") {
      return json({
        name: "rails-agent-skills",
        transport: "streamable-http",
        endpoint: "/mcp",
        status: "ok",
      });
    }

    if (url.pathname === "/.well-known/mcp/server-card.json") {
      return json(serverCard());
    }

    return mcpHandler.fetch(request, env, ctx);
  },
};
