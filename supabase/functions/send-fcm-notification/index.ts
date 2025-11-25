// Supabase Edge Function để gửi FCM notification
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

serve(async (req) => {
  try {
    const { tokens, title, body, data } = await req.json();

    if (!tokens || tokens.length === 0) {
      return new Response(
        JSON.stringify({ error: "No tokens provided" }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

    // FCM Server Key từ Firebase Console
    const fcmServerKey = Deno.env.get("FCM_SERVER_KEY");
    if (!fcmServerKey) {
      throw new Error("FCM_SERVER_KEY not configured");
    }

    // Gửi notification đến tất cả tokens
    const results = await Promise.allSettled(
      tokens.map((token: string) =>
        fetch("https://fcm.googleapis.com/fcm/send", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            Authorization: `key=${fcmServerKey}`,
          },
          body: JSON.stringify({
            to: token,
            notification: {
              title: title,
              body: body,
              sound: "default",
              badge: "1",
            },
            data: data,
            priority: "high",
          }),
        })
      )
    );

    const successCount = results.filter((r) => r.status === "fulfilled").length;
    const failCount = results.filter((r) => r.status === "rejected").length;

    return new Response(
      JSON.stringify({
        success: true,
        sent: successCount,
        failed: failCount,
        total: tokens.length,
      }),
      { headers: { "Content-Type": "application/json" } }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }
});
