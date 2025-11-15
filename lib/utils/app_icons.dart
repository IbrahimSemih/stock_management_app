import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Uygulama genelinde kullanılan icon'lar için merkezi bir kaynak
class AppIcons {
  // Ana icon'lar
  static const IconData appLogo = Icons.inventory_2_rounded;
  static const IconData dashboard = Icons.dashboard_rounded;
  static const IconData products = Icons.inventory_2_rounded;
  static const IconData categories = Icons.category_rounded;
  static const IconData reports = Icons.analytics_rounded;
  static const IconData settings = Icons.settings_rounded;
  static const IconData logout = Icons.logout_rounded;

  // Ürün icon'ları
  static const IconData addProduct = Icons.add_circle_rounded;
  static const IconData editProduct = Icons.edit_rounded;
  static const IconData deleteProduct = Icons.delete_rounded;
  static const IconData productDetail = Icons.info_rounded;
  static const IconData productImage = Icons.image_rounded;

  // Stok icon'ları
  static const IconData stockIn = Icons.input_rounded;
  static const IconData stockOut = Icons.output_rounded;
  static const IconData stockHistory = Icons.history_rounded;
  static const IconData criticalStock = Icons.warning_rounded;

  // Barkod/QR icon'ları
  static const IconData barcode = Icons.qr_code_scanner_rounded;
  static const IconData qrCode = Icons.qr_code_rounded;
  static const IconData scan = Icons.qr_code_scanner_rounded;

  // Arama ve filtreleme
  static const IconData search = Icons.search_rounded;
  static const IconData filter = Icons.filter_list_rounded;
  static const IconData clear = Icons.clear_rounded;

  // Görünüm
  static const IconData listView = Icons.list_rounded;
  static const IconData gridView = Icons.grid_view_rounded;

  // Genel işlemler
  static const IconData add = Icons.add_rounded;
  static const IconData save = Icons.check_rounded;
  static const IconData cancel = Icons.close_rounded;
  static const IconData back = Icons.arrow_back_rounded;
  static const IconData forward = Icons.arrow_forward_rounded;
  static const IconData more = Icons.more_vert_rounded;
  static const IconData share = Icons.share_rounded;
  static const IconData download = Icons.download_rounded;
  static const IconData upload = Icons.upload_rounded;

  // Raporlama
  static const IconData excel = Icons.table_chart_rounded;
  static const IconData pdf = Icons.picture_as_pdf_rounded;
  static const IconData backup = Icons.backup_rounded;
  static const IconData restore = Icons.restore_rounded;

  // Kullanıcı
  static const IconData user = Icons.person_rounded;
  static const IconData email = Icons.email_rounded;
  static const IconData password = Icons.lock_rounded;
  static const IconData visibility = Icons.visibility_rounded;
  static const IconData visibilityOff = Icons.visibility_off_rounded;

  // Tema
  static const IconData lightMode = Icons.light_mode_rounded;
  static const IconData darkMode = Icons.dark_mode_rounded;

  // Bildirimler
  static const IconData notifications = Icons.notifications_rounded;
  static const IconData notificationsOff = Icons.notifications_off_rounded;

  // Tarih ve saat
  static const IconData calendar = Icons.calendar_today_rounded;
  static const IconData time = Icons.access_time_rounded;
  static const IconData dateRange = Icons.date_range_rounded;

  // Para birimi
  static const IconData money = Icons.attach_money_rounded;
  static const IconData price = Icons.sell_rounded;
  static const IconData purchase = Icons.shopping_bag_rounded;

  // Durum icon'ları
  static const IconData success = Icons.check_circle_rounded;
  static const IconData error = Icons.error_rounded;
  static const IconData warning = Icons.warning_rounded;
  static const IconData info = Icons.info_rounded;

  // Kamera ve medya
  static const IconData camera = Icons.camera_alt_rounded;
  static const IconData gallery = Icons.photo_library_rounded;
  static const IconData image = Icons.image_rounded;

  // Navigasyon
  static const IconData home = Icons.home_rounded;
  static const IconData menu = Icons.menu_rounded;
  static const IconData arrowRight = Icons.arrow_forward_ios_rounded;
  static const IconData arrowLeft = Icons.arrow_back_ios_rounded;

  // Font Awesome icon'ları (özel durumlar için)
  static const IconData faBox = FontAwesomeIcons.box;
  static const IconData faWarehouse = FontAwesomeIcons.warehouse;
  static const IconData faChartLine = FontAwesomeIcons.chartLine;
  static const IconData faFileExcel = FontAwesomeIcons.fileExcel;
  static const IconData faFilePdf = FontAwesomeIcons.filePdf;
  static const IconData faBarcode = FontAwesomeIcons.barcode;
  static const IconData faQrcode = FontAwesomeIcons.qrcode;
  static const IconData faShoppingCart = FontAwesomeIcons.cartShopping;
  static const IconData faStore = FontAwesomeIcons.store;
}

