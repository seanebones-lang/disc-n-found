/// Copyright and Legal Information
/// 
/// Disc 'n' Found
/// Copyright © 2026 Corby Bibb. All Rights Reserved.
/// 
/// This software and all intellectual property contained herein are the 
/// sole and exclusive property of Corby Bibb.
/// 
/// "Disc 'n' Found" is a trademark of Corby Bibb.
/// 
/// Unauthorized use, reproduction, or distribution is strictly prohibited.
/// 
/// Code developed by NextEleven S. McDonnell, CTO

class CopyrightInfo {
  static const String owner = 'Corby Bibb';
  static const String copyrightYear = '2026';
  static const String appName = 'Disc \'n\' Found';
  static const String trademark = 'Disc \'n\' Found';
  static const String developer = 'NextEleven S. McDonnell, CTO';
  
  static String get copyrightNotice => 
      'Copyright © $copyrightYear $owner. All Rights Reserved.';
  
  static String get trademarkNotice => 
      '"$trademark" is a trademark of $owner.';
  
  static String get developerNotice => 
      'Code developed by $developer.';
  
  static String get fullNotice => 
      '$copyrightNotice\n$trademarkNotice\n$developerNotice';
}
