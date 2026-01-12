#!/bin/bash

# Script to update all imports in the project after restructuring

cd "/home/lucifer/development/flutter projects/1. messaging_app/andreopoulos_messasing/lib"

# Find all Dart files and update imports
find . -name "*.dart" -type f -exec sed -i \
  -e "s|'/themes/theme_provider.dart'|'package:andreopoulos_messasing/core/theme/theme_provider.dart'|g" \
  -e "s|'/themes/theme.dart'|'package:andreopoulos_messasing/core/theme/app_theme.dart'|g" \
  -e "s|'/components/my_button.dart'|'package:andreopoulos_messasing/shared/widgets/buttons/primary_button.dart'|g" \
  -e "s|'/components/text_field.dart'|'package:andreopoulos_messasing/shared/widgets/inputs/app_text_field.dart'|g" \
  -e "s|'/components/drawer.dart'|'package:andreopoulos_messasing/shared/widgets/navigation/app_drawer.dart'|g" \
  -e "s|'/components/them_toggle_button.dart'|'package:andreopoulos_messasing/shared/widgets/theme/theme_toggle_button.dart'|g" \
  -e "s|'/components/user_tile.dart'|'package:andreopoulos_messasing/features/chat/presentation/widgets/user_tile.dart'|g" \
  -e "s|'/services/auth/auth_service.dart'|'package:andreopoulos_messasing/features/auth/services/auth_service.dart'|g" \
  -e "s|'/services/auth/auth_gate.dart'|'package:andreopoulos_messasing/features/auth/services/auth_gate.dart'|g" \
  -e "s|'/services/auth/login_or_register.dart'|'package:andreopoulos_messasing/features/auth/services/login_or_register.dart'|g" \
  -e "s|'/services/chat/chat_services.dart'|'package:andreopoulos_messasing/features/chat/services/chat_service.dart'|g" \
  -e "s|'/services/message_listener_service.dart'|'package:andreopoulos_messasing/features/chat/services/message_listener_service.dart'|g" \
  -e "s|'/services/notification_service.dart'|'package:andreopoulos_messasing/features/notifications/services/notification_service.dart'|g" \
  -e "s|'/services/profile_service.dart'|'package:andreopoulos_messasing/features/profile/services/profile_service.dart'|g" \
  -e "s|'/services/race_service.dart'|'package:andreopoulos_messasing/features/race/services/race_service.dart'|g" \
  -e "s|'/models/message.dart'|'package:andreopoulos_messasing/features/chat/data/models/message_model.dart'|g" \
  -e "s|'/models/athlete_profile_model.dart'|'package:andreopoulos_messasing/features/profile/data/models/athlete_profile_model.dart'|g" \
  -e "s|'/models/race_model.dart'|'package:andreopoulos_messasing/features/race/data/models/race_model.dart'|g" \
  -e "s|'/pages/login_page.dart'|'package:andreopoulos_messasing/features/auth/presentation/pages/login_page.dart'|g" \
  -e "s|'/pages/register.dart'|'package:andreopoulos_messasing/features/auth/presentation/pages/register_page.dart'|g" \
  -e "s|'/guidelines/pass_guide.dart'|'package:andreopoulos_messasing/features/auth/presentation/pages/password_guidelines_page.dart'|g" \
  -e "s|'/pages/chat_page.dart'|'package:andreopoulos_messasing/features/chat/presentation/pages/chat_page.dart'|g" \
  -e "s|'/pages/athlete_messages_page.dart'|'package:andreopoulos_messasing/features/chat/presentation/pages/athlete_messages_page.dart'|g" \
  -e "s|'/pages/coach_messages_page.dart'|'package:andreopoulos_messasing/features/chat/presentation/pages/coach_messages_page.dart'|g" \
  -e "s|'/pages/profile_page.dart'|'package:andreopoulos_messasing/features/profile/presentation/pages/profile_page.dart'|g" \
  -e "s|'/pages/profile_edit_page.dart'|'package:andreopoulos_messasing/features/profile/presentation/pages/profile_edit_page.dart'|g" \
  -e "s|'/pages/profile_check_page.dart'|'package:andreopoulos_messasing/features/profile/presentation/pages/profile_check_page.dart'|g" \
  -e "s|'/pages/races_page.dart'|'package:andreopoulos_messasing/features/race/presentation/pages/races_page.dart'|g" \
  -e "s|'/pages/athlete_races_page.dart'|'package:andreopoulos_messasing/features/race/presentation/pages/athlete_races_page.dart'|g" \
  -e "s|'/pages/coach_races_page.dart'|'package:andreopoulos_messasing/features/race/presentation/pages/coach_races_page.dart'|g" \
  -e "s|'/pages/race_edit_page.dart'|'package:andreopoulos_messasing/features/race/presentation/pages/race_edit_page.dart'|g" \
  -e "s|'/pages/coach_dashboard_page.dart'|'package:andreopoulos_messasing/features/coach/presentation/pages/coach_dashboard_page.dart'|g" \
  -e "s|'/pages/coach_athlete_list_page.dart'|'package:andreopoulos_messasing/features/coach/presentation/pages/coach_athlete_list_page.dart'|g" \
  -e "s|'/pages/coach_athlete_detail_page.dart'|'package:andreopoulos_messasing/features/coach/presentation/pages/coach_athlete_detail_page.dart'|g" \
  -e "s|'/pages/home_page.dart'|'package:andreopoulos_messasing/features/home/presentation/pages/home_page.dart'|g" \
  -e "s|'/pages/settings_page.dart'|'package:andreopoulos_messasing/features/home/presentation/pages/settings_page.dart'|g" \
  {} \;

# Also update relative imports (../)
find . -name "*.dart" -type f -exec sed -i \
  -e "s|'../themes/theme_provider.dart'|'package:andreopoulos_messasing/core/theme/theme_provider.dart'|g" \
  -e "s|'../themes/theme.dart'|'package:andreopoulos_messasing/core/theme/app_theme.dart'|g" \
  -e "s|'../components/my_button.dart'|'package:andreopoulos_messasing/shared/widgets/buttons/primary_button.dart'|g" \
  -e "s|'../components/text_field.dart'|'package:andreopoulos_messasing/shared/widgets/inputs/app_text_field.dart'|g" \
  -e "s|'../components/drawer.dart'|'package:andreopoulos_messasing/shared/widgets/navigation/app_drawer.dart'|g" \
  -e "s|'../components/them_toggle_button.dart'|'package:andreopoulos_messasing/shared/widgets/theme/theme_toggle_button.dart'|g" \
  -e "s|'../components/user_tile.dart'|'package:andreopoulos_messasing/features/chat/presentation/widgets/user_tile.dart'|g" \
  -e "s|'../models/athlete_profile_model.dart'|'package:andreopoulos_messasing/features/profile/data/models/athlete_profile_model.dart'|g" \
  -e "s|'../models/race_model.dart'|'package:andreopoulos_messasing/features/race/data/models/race_model.dart'|g" \
  -e "s|'../models/message.dart'|'package:andreopoulos_messasing/features/chat/data/models/message_model.dart'|g" \
  -e "s|'../services/profile_service.dart'|'package:andreopoulos_messasing/features/profile/services/profile_service.dart'|g" \
  -e "s|'../services/race_service.dart'|'package:andreopoulos_messasing/features/race/services/race_service.dart'|g" \
  -e "s|'../services/auth/auth_service.dart'|'package:andreopoulos_messasing/features/auth/services/auth_service.dart'|g" \
  -e "s|'../../services/auth/auth_service.dart'|'package:andreopoulos_messasing/features/auth/services/auth_service.dart'|g" \
  -e "s|'profile_edit_page.dart'|'package:andreopoulos_messasing/features/profile/presentation/pages/profile_edit_page.dart'|g" \
  {} \;

echo "Import updates completed!"
