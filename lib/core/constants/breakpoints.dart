/// Responsive design breakpoints for the application
class Breakpoints {
  Breakpoints._();

  // Screen width breakpoints
  static const double mobileSmall = 320;
  static const double mobileMedium = 375;
  static const double mobileLarge = 425;
  static const double tablet = 768;
  static const double laptop = 1024;
  static const double laptopLarge = 1440;
  static const double desktop = 1920;
  static const double desktop4K = 2560;

  // Common breakpoint groups
  static const double smallScreen = 600;   // < 600px
  static const double mediumScreen = 1024; // 600px - 1024px
  static const double largeScreen = 1440;  // 1024px - 1440px
  static const double extraLargeScreen = 1920; // > 1440px

  // Grid system breakpoints
  static const double gridXs = 0;
  static const double gridSm = 576;
  static const double gridMd = 768;
  static const double gridLg = 992;
  static const double gridXl = 1200;
  static const double gridXxl = 1400;

  // Responsive helpers
  static bool isMobile(double width) => width < tablet;
  static bool isTablet(double width) => width >= tablet && width < laptop;
  static bool isDesktop(double width) => width >= laptop;
  static bool isLargeDesktop(double width) => width >= laptopLarge;

  // Layout breakpoints
  static bool isSmallScreen(double width) => width < smallScreen;
  static bool isMediumScreen(double width) => width >= smallScreen && width < mediumScreen;
  static bool isLargeScreen(double width) => width >= mediumScreen && width < largeScreen;
  static bool isExtraLargeScreen(double width) => width >= largeScreen;
}