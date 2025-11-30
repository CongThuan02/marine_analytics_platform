# Enable Notification Trigger with English Messages

## Quick Start

Run this SQL script in your Supabase SQL Editor:

```bash
# Copy the content of enable_trigger_with_english.sql
# and run it in Supabase SQL Editor
```

Or use the Supabase CLI:

```bash
supabase db execute -f enable_trigger_with_english.sql
```

## What This Does

1. **Updates the trigger function** with English messages instead of Vietnamese
2. **Re-enables both triggers**:
   - `trigger_check_waste_limit` - for INSERT operations
   - `trigger_check_waste_limit_on_update` - for UPDATE operations
3. **Verifies** the setup is working

## English Message Format

### Warning (80-99%)
```
⚠️ WARNING: [Waste Type] at [Area] has reached XX% of limit (X.XX/X.XX kg)
```

### Exceeded (100%+)
```
🔴 LIMIT EXCEEDED: [Waste Type] at [Area] has exceeded XXX% (X.XX/X.XX kg)
```

## Notification Titles

- **Warning**: `⚠️ Limit Warning`
- **Exceeded**: `🔴 Limit Exceeded`

## How It Works

When you create or update a waste entry:

1. **Database trigger** checks if limit is exceeded
2. **Creates alert** in the `alerts` table
3. **Sends FCM notification** to all active users (via Edge Function)
4. **App receives notification** and can navigate to alerts page using `push()`

## Testing

After enabling, test by:

1. Creating a waste entry that exceeds 80% of a limit
2. Check the `alerts` table for new entries
3. Check if FCM notification is sent
4. Tap notification to verify navigation works

## Disable Again (if needed)

If you need to disable the trigger again:

```sql
DROP TRIGGER IF EXISTS trigger_check_waste_limit ON waste_entries;
DROP TRIGGER IF EXISTS trigger_check_waste_limit_on_update ON waste_entries;
```

## Notes

- Notifications are sent to all users with active FCM tokens (updated in last 30 days)
- Local notifications still work independently in the app
- The trigger now uses `push()` instead of `go()` for navigation, so users can go back
