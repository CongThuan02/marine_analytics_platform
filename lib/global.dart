import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final SupabaseClient supabase = Supabase.instance.client;

// Global navigator key for navigation from services (FCM, etc.)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
