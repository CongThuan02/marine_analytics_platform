import 'package:flutter/material.dart';
import 'package:marine_analytics_platform/core/constants/app_strings_vi.dart';

/// App localization class
/// Currently supports Vietnamese (default)
/// Can be extended to support English and other languages
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // All strings - currently using Vietnamese
  // Common
  String get appName => AppStringsVi.appName;
  String get ok => AppStringsVi.ok;
  String get cancel => AppStringsVi.cancel;
  String get save => AppStringsVi.save;
  String get update => AppStringsVi.update;
  String get delete => AppStringsVi.delete;
  String get edit => AppStringsVi.edit;
  String get add => AppStringsVi.add;
  String get search => AppStringsVi.search;
  String get filter => AppStringsVi.filter;
  String get select => AppStringsVi.select;
  String get loading => AppStringsVi.loading;
  String get error => AppStringsVi.error;
  String get success => AppStringsVi.success;
  String get warning => AppStringsVi.warning;
  String get confirm => AppStringsVi.confirm;
  String get close => AppStringsVi.close;

  // Auth
  String get login => AppStringsVi.login;
  String get logout => AppStringsVi.logout;
  String get register => AppStringsVi.register;
  String get email => AppStringsVi.email;
  String get password => AppStringsVi.password;
  String get confirmPassword => AppStringsVi.confirmPassword;
  String get forgotPassword => AppStringsVi.forgotPassword;
  String get loginSuccess => AppStringsVi.loginSuccess;
  String get logoutSuccess => AppStringsVi.logoutSuccess;
  String get logoutConfirm => AppStringsVi.logoutConfirm;

  // Navigation
  String get home => AppStringsVi.home;
  String get ships => AppStringsVi.ships;
  String get history => AppStringsVi.history;
  String get settings => AppStringsVi.settings;
  String get alerts => AppStringsVi.alerts;
  String get reminders => AppStringsVi.reminders;
  String get limits => AppStringsVi.limits;
  String get statistics => AppStringsVi.statistics;

  // Waste Management
  String get wasteEntry => AppStringsVi.wasteEntry;
  String get wasteHistory => AppStringsVi.wasteHistory;
  String get wasteType => AppStringsVi.wasteType;
  String get wasteLimit => AppStringsVi.wasteLimit;
  String get recordWaste => AppStringsVi.recordWaste;
  String get editWasteEntry => AppStringsVi.editWasteEntry;
  String get deleteWasteEntry => AppStringsVi.deleteWasteEntry;
  String get area => AppStringsVi.area;
  String get department => AppStringsVi.department;
  String get quantity => AppStringsVi.quantity;
  String get date => AppStringsVi.date;
  String get entryDate => AppStringsVi.entryDate;
  String get qrCode => AppStringsVi.qrCode;
  String get qrCodeOptional => AppStringsVi.qrCodeOptional;

  // Validation
  String get pleaseSelectArea => AppStringsVi.pleaseSelectArea;
  String get pleaseSelectDepartment => AppStringsVi.pleaseSelectDepartment;
  String get pleaseSelectWasteType => AppStringsVi.pleaseSelectWasteType;
  String get pleaseEnterQuantity => AppStringsVi.pleaseEnterQuantity;
  String get pleaseSelectDate => AppStringsVi.pleaseSelectDate;
  String get quantityMustBeNumber => AppStringsVi.quantityMustBeNumber;
  String get invalidQuantity => AppStringsVi.invalidQuantity;

  // Messages
  String get wasteEntryCreated => AppStringsVi.wasteEntryCreated;
  String get wasteEntryUpdated => AppStringsVi.wasteEntryUpdated;
  String get wasteEntryDeleted => AppStringsVi.wasteEntryDeleted;
  String get deleteConfirm => AppStringsVi.deleteConfirm;
  String get noDataFound => AppStringsVi.noDataFound;
  String get noDataForPeriod => AppStringsVi.noDataForPeriod;

  // Alerts & Notifications
  String get limitExceeded => AppStringsVi.limitExceeded;
  String get limitWarning => AppStringsVi.limitWarning;
  String get limitExceededMessage => AppStringsVi.limitExceededMessage;
  String get limitWarningMessage => AppStringsVi.limitWarningMessage;
  String get ofLimit => AppStringsVi.ofLimit;

  // Export
  String get exportToExcel => AppStringsVi.exportToExcel;
  String get selectExportPeriod => AppStringsVi.selectExportPeriod;
  String get today => AppStringsVi.today;
  String get thisWeek => AppStringsVi.thisWeek;
  String get thisMonth => AppStringsVi.thisMonth;
  String get thisYear => AppStringsVi.thisYear;
  String get customRange => AppStringsVi.customRange;
  String get excelExportSuccess => AppStringsVi.excelExportSuccess;
  String get excelExportError => AppStringsVi.excelExportError;

  // Stats
  String get totalWaste => AppStringsVi.totalWaste;
  String get totalEntries => AppStringsVi.totalEntries;
  String get period => AppStringsVi.period;
  String get summary => AppStringsVi.summary;
  String get overview => AppStringsVi.overview;
  String get trends => AppStringsVi.trends;
  String get comparison => AppStringsVi.comparison;

  // Time
  String get daily => AppStringsVi.daily;
  String get weekly => AppStringsVi.weekly;
  String get monthly => AppStringsVi.monthly;
  String get yearly => AppStringsVi.yearly;

  // Units
  String get kg => AppStringsVi.kg;
  String get ton => AppStringsVi.ton;
  String get unit => AppStringsVi.unit;

  // QR Code
  String get qrCodePage => AppStringsVi.qrCodePage;
  String get scanToOpen => AppStringsVi.scanToOpen;
  String get scanInstruction => AppStringsVi.scanInstruction;

  // Multiple entries
  String get addMultipleEntries => AppStringsVi.addMultipleEntries;
  String get addEntry => AppStringsVi.addEntry;
  String get removeEntry => AppStringsVi.removeEntry;

  // Limits & Reminders
  String get createLimit => AppStringsVi.createLimit;
  String get editLimit => AppStringsVi.editLimit;
  String get deleteLimit => AppStringsVi.deleteLimit;
  String get dailyLimit => AppStringsVi.dailyLimit;
  String get createReminder => AppStringsVi.createReminder;
  String get editReminder => AppStringsVi.editReminder;
  String get deleteReminder => AppStringsVi.deleteReminder;
  String get reminderTime => AppStringsVi.reminderTime;
  String get reminderMessage => AppStringsVi.reminderMessage;

  // Form fields
  String get name => AppStringsVi.name;
  String get type => AppStringsVi.type;
  String get limit => AppStringsVi.limit;
  String get hintQuantity => AppStringsVi.hintQuantity;
  String get addType => AppStringsVi.addType;

  // Buttons & Actions
  String get refresh => AppStringsVi.refresh;
  String get apply => AppStringsVi.apply;
  String get reset => AppStringsVi.reset;
  String get clear => AppStringsVi.clear;
  String get back => AppStringsVi.back;
  String get next => AppStringsVi.next;
  String get previous => AppStringsVi.previous;
  String get submit => AppStringsVi.submit;

  // Messages & Notifications
  String get loggedIn => AppStringsVi.loggedIn;
  String get confirmLogout => AppStringsVi.confirmLogout;
  String get signOutFromAccount => AppStringsVi.signOutFromAccount;

  // Settings
  String get systemManagement => AppStringsVi.systemManagement;
  String get monitoringAlerts => AppStringsVi.monitoringAlerts;
  String get testingDebug => AppStringsVi.testingDebug;
  String get account => AppStringsVi.account;
  String get manageAreas => AppStringsVi.manageAreas;
  String get manageDepartments => AppStringsVi.manageDepartments;
  String get manageWasteTypes => AppStringsVi.manageWasteTypes;
  String get manageLimits => AppStringsVi.manageLimits;
  String get manageReminders => AppStringsVi.manageReminders;
  String get limitAlerts => AppStringsVi.limitAlerts;

  // Time periods
  String get day => AppStringsVi.day;
  String get week => AppStringsVi.week;
  String get month => AppStringsVi.month;
  String get year => AppStringsVi.year;
  String get trend => AppStringsVi.trend;

  // Empty states
  String get noWasteDataYet => AppStringsVi.noWasteDataYet;
  String get noEntriesInDateRange => AppStringsVi.noEntriesInDateRange;
  String get noAlerts => AppStringsVi.noAlerts;

  // Dialogs
  String get confirmDelete => AppStringsVi.confirmDelete;
  String get areYouSureDelete => AppStringsVi.areYouSureDelete;
  String get editDepartment => AppStringsVi.editDepartment;
  String get deleteAlert => AppStringsVi.deleteAlert;

  // Stats
  String get detailedStatistics => AppStringsVi.detailedStatistics;
  String get wasteDistribution => AppStringsVi.wasteDistribution;
  String get detailsByWasteType => AppStringsVi.detailsByWasteType;
  String get totalQuantity => AppStringsVi.totalQuantity;
  String get entryCount => AppStringsVi.entryCount;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // Currently only Vietnamese is supported
    // Can add 'en' for English support later
    return ['vi'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
