import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Content-Type": "application/json",
};
const reply = (data: unknown, status = 200) =>
  new Response(JSON.stringify(data), { status, headers: cors });

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") return reply({ error: "Method not allowed" }, 405);
  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!supabaseUrl || !serviceKey) return reply({ error: "Admin service configuration is missing" }, 500);
  const db = createClient(supabaseUrl, serviceKey, { auth: { persistSession: false, autoRefreshToken: false } });
  try {
    const body = await req.json();
    const action = String(body.action ?? "");
    let result: any;
    switch (action) {
      case "create_prompt":
        result = await db.from("prompts").insert({ title: body.title, image_url: body.image_url, prompt_text: body.prompt_text, category_id: body.category_id || null, is_featured: body.is_featured === true });
        break;
      case "update_prompt":
        result = await db.from("prompts").update({ title: body.title, image_url: body.image_url, prompt_text: body.prompt_text, category_id: body.category_id || null, is_featured: body.is_featured === true, updated_at: new Date().toISOString() }).eq("id", body.id);
        break;
      case "delete_prompt":
        result = await db.from("prompts").delete().eq("id", body.id);
        break;
      case "create_category":
        result = await db.from("categories").insert({ name: body.name, slug: body.slug });
        break;
      case "update_category":
        result = await db.from("categories").update({ name: body.name, slug: body.slug }).eq("id", body.id);
        break;
      case "delete_category":
        result = await db.from("categories").delete().eq("id", body.id);
        break;
      default:
        return reply({ error: "Unknown admin action" }, 400);
    }
    if (result.error) throw result.error;
    return reply({ ok: true, data: result.data ?? null });
  } catch (error) {
    const message = error instanceof Error ? error.message : "Admin operation failed";
    return reply({ error: message }, 400);
  }
});