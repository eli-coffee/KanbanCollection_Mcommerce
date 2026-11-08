import 'package:flutter/material.dart';
import '../services/settings_service.dart';


class LangScope extends InheritedNotifier<SettingsService> {
  const LangScope({
    super.key,
    required SettingsService notifier,
    required super.child,
  }) : super(notifier: notifier);

  static void watch(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<LangScope>();
}

extension Tr on BuildContext {
  
  String tr(String key, [Map<String, Object?>? args]) {
    LangScope.watch(this);
    return S.t(key, args);
  }
}

class S {
  static const _fil = {
    
    'Notification': 'Abiso',
    'Settings': 'Mga Setting',
    'My Data': 'Aking Datos',
    'Location': 'Lokasyon',
    'Language': 'Wika',
    'Theme': 'Tema',
    'Support': 'Suporta',
    'Light': 'Maliwanag',
    'Dark': 'Madilim',
    'System': 'Sistema',
    'Choose language': 'Piliin ang wika',
    'Choose theme': 'Piliin ang tema',
    'Text-to-speech is on': 'Naka-on na ang text-to-speech',
    'Delivery address': 'Address ng paghahatid',
    'Full address': 'Buong address',
    'House no., street, barangay, city, province, postal code':
        'Blg. ng bahay, kalye, barangay, lungsod, probinsya, postal code',
    'Save address': 'I-save ang address',
    'Address saved': 'Nai-save ang address',

    
    'Sign in': 'Mag-sign in',
    'Sign up': 'Mag-sign up',
    'Email or Contact Number': 'Email o Contact Number',
    'Login': 'Mag-login',
    "Don't have an account?": 'Wala ka pang account?',
    'Sign up here': 'Mag-sign up dito',
    'Confirm Password': 'Kumpirmahin ang Password',
    'Get Started': 'Magsimula',
    'Already have an account?': 'May account ka na?',
    'Please fill in all fields.': 'Punan ang lahat ng field.',
    'Passwords do not match.': 'Hindi magkatugma ang mga password.',

    
    'Username cannot be empty': 'Hindi maaaring walang laman ang username',
    'Password cannot be empty': 'Hindi maaaring walang laman ang password',
    'Email or contact number cannot be empty':
        'Hindi maaaring walang laman ang email o contact number',
    'Incorrect username or password': 'Maling username o password',
    'Username is already taken': 'Gamit na ang username na iyon',
    'Password is incorrect': 'Mali ang password',
    'Current password is incorrect': 'Mali ang kasalukuyang password',
    'You are not logged in': 'Hindi ka naka-login',
    'Username must be at least 3 characters':
        'Dapat hindi bababa sa 3 karakter ang username',
    'Username must be at most 20 characters':
        'Dapat hindi hihigit sa 20 karakter ang username',
    'Username can only use letters, numbers, and underscores':
        'Titik, numero, at underscore lang ang puwede sa username',
    'Password must be at least 8 characters':
        'Dapat hindi bababa sa 8 karakter ang password',
    'Password must be at most 32 characters':
        'Dapat hindi hihigit sa 32 karakter ang password',
    'Password cannot contain spaces': 'Hindi puwede ang espasyo sa password',
    'Password must include at least one letter and one number':
        'Dapat may kahit isang titik at isang numero ang password',

    
    'Enter keywords to search': 'Maghanap gamit ang keyword',
    'Categories': 'Mga Kategorya',
    'All': 'Lahat',
    'Sort': 'Ayusin',
    'Name A-Z': 'Pangalan A-Z',
    'Price: low to high': 'Presyo: mababa hanggang mataas',
    'Price: high to low': 'Presyo: mataas hanggang mababa',
    'Pre-order only': 'Pre-order lang',
    'No products yet': 'Wala pang produkto',
    'No products match your search or filters':
        'Walang produktong tugma sa iyong paghahanap o filter',
    'Clear filters': 'I-clear ang mga filter',
    'SOLD OUT': 'UBOS NA',
    'Only {n} left': '{n} na lang ang natitira',
    'Pre-Order\nNow Open': 'Pre-Order\nBukas Na',

    
    'Price: ': 'Presyo: ',
    'Sold by {name}': 'Ibinebenta ni {name}',
    'Preorders open now': 'Bukas na ang pre-order',
    'Preorders Open Now\nPreorder Period:\n{period}':
        'Bukas na ang Pre-order\nPanahon ng Pre-order:\n{period}',
    'Sold out': 'Ubos na',
    '{n} in stock': '{n} ang stock',
    'Quantity': 'Dami',
    '{n} Reviews': '{n} Review',
    'No reviews yet': 'Wala pang review',
    'Product description': 'Paglalarawan ng produkto',
    'Product Details:': 'Mga Detalye ng Produkto:',
    'You may also like': 'Maaaring magustuhan mo rin',
    'Sold Out': 'Ubos Na',
    'Pre-Order Now': 'Mag-Pre-Order Na',
    'Buy Now': 'Bilhin Na',
    'Read aloud': 'Basahin nang malakas',
    'Copied to clipboard': 'Nakopya sa clipboard',
    'You already have all available stock in your cart':
        'Nasa cart mo na ang lahat ng available na stock',
    'Only {n} added, that is all the stock available':
        '{n} lang ang naidagdag, iyon na ang lahat ng available na stock',
    '{n} × {name} added to cart': 'Naidagdag sa cart ang {n} × {name}',

    
    'My Cart': 'Aking Cart',
    'Your cart is empty': 'Walang laman ang iyong cart',
    'Total ({n} items)': 'Kabuuan ({n} aytem)',
    'Order summary': 'Buod ng order',
    'Place Order': 'Ilagay ang Order',
    'Place Pre-order': 'Ilagay ang Pre-order',
    'Order placed!': 'Nailagay na ang order!',
    'Your pre-order has been received.': 'Natanggap na ang iyong pre-order.',
    'Your order is now being processed.': 'Pinoproseso na ang iyong order.',
    'Only {n} available': '{n} lang ang available',

    
    'My Orders': 'Aking mga Order',
    'Processing': 'Pinoproseso',
    'Shipping': 'Ipinapadala',
    'Received': 'Natanggap',
    'Cancelled': 'Kinansela',
    'Order #{id}': 'Order #{id}',
    'Total: {total}': 'Kabuuan: {total}',
    'Cancel Order': 'Kanselahin ang Order',
    'Are you sure you want to cancel this order?':
        'Sigurado ka bang gusto mong kanselahin ang order na ito?',
    'No': 'Hindi',
    'Yes': 'Oo',
    'No orders found.': 'Walang nahanap na order.',

    
    'Notifications': 'Mga Abiso',
    'Mark all as read': 'Markahan lahat bilang nabasa',
    'No notifications yet': 'Wala pang abiso',
    'Pre-order placed': 'Nailagay ang pre-order',
    'Order processing': 'Pinoproseso ang order',
    'Order shipped': 'Naipadala na ang order',
    'Order received': 'Natanggap na ang order',
    'Order cancelled': 'Kinansela ang order',
    'Order update': 'Update sa order',
    'Your pre-order #{id} has been received.':
        'Natanggap na ang iyong pre-order #{id}.',
    'Your order #{id} is being processed.': 'Pinoproseso ang iyong order #{id}.',
    'Your order #{id} is on its way.': 'Papunta na ang iyong order #{id}.',
    'Your order #{id} was received. Enjoy!':
        'Natanggap na ang iyong order #{id}. Sulitin!',
    'Your order #{id} was cancelled.': 'Kinansela ang iyong order #{id}.',
    'Order #{id} is now {status}.': 'Ang order #{id} ay {status} na.',

    
    'View all': 'Tingnan lahat',
    'Edit Profile': 'I-edit ang Profile',
    'Vouchers': 'Mga Voucher',
    'Customer Support': 'Suporta sa Customer',
    'Messages': 'Mga Mensahe',
    'My Store': 'Aking Tindahan',
    'Log out': 'Mag-log out',
    'Log out?': 'Mag-log out?',
    'Cancel': 'Kanselahin',
    '{name} is coming soon': 'Malapit nang dumating ang {name}',
    'Account details': 'Detalye ng account',
    'Full name': 'Buong pangalan',
    'Save changes': 'I-save ang mga pagbabago',
    'Change password': 'Palitan ang password',
    'Current password': 'Kasalukuyang password',
    'New password': 'Bagong password',
    'Confirm new password': 'Kumpirmahin ang bagong password',
    'Password (required to change username)':
        'Password (kailangan para palitan ang username)',
    'Update username': 'I-update ang username',
    'Profile updated': 'Na-update ang profile',
    'Password changed': 'Napalitan ang password',
    'Please fill in all password fields': 'Punan ang lahat ng password field',
    'New passwords do not match': 'Hindi magkatugma ang mga bagong password',
    'Enter your password to change your username':
        'Ilagay ang iyong password para mapalitan ang username',
    'That is already your username': 'Iyan na ang iyong username',
    'Username changed to {name}': 'Napalitan ang username sa {name}',
    'Choose from gallery': 'Pumili mula sa gallery',
    'Remove photo': 'Alisin ang larawan',
    'Profile picture updated': 'Na-update ang larawan sa profile',
    'Profile picture removed': 'Inalis ang larawan sa profile',

    
    'Add product': 'Magdagdag ng produkto',
    'Search products': 'Maghanap ng produkto',
    'You have no listings yet. Tap Add product to sell something.':
        'Wala ka pang produktong ibinebenta. I-tap ang Magdagdag ng produkto para magsimula.',
    'No products match your search.': 'Walang produktong tugma sa iyong paghahanap.',
    'Delete product?': 'Burahin ang produkto?',
    '"{name}" will be removed from the shop. This cannot be undone.':
        'Aalisin ang "{name}" sa tindahan. Hindi na ito maibabalik.',
    'Delete': 'Burahin',
    'Edit': 'I-edit',
    'Product deleted': 'Nabura ang produkto',
    'Product added': 'Naidagdag ang produkto',
    'Product updated': 'Na-update ang produkto',
    'Add Product': 'Magdagdag ng Produkto',
    'Edit Product': 'I-edit ang Produkto',
    'Choose photo': 'Pumili ng larawan',
    'Change photo': 'Palitan ang larawan',
    'Remove': 'Alisin',
    'Extra photos (shown as thumbnails)':
        'Dagdag na larawan (ipinapakita bilang thumbnail)',
    'Product name': 'Pangalan ng produkto',
    'Enter at least 2 characters': 'Maglagay ng hindi bababa sa 2 karakter',
    'Price (₱)': 'Presyo (₱)',
    'Enter a price above 0': 'Maglagay ng presyong higit sa 0',
    'Old price (₱), optional': 'Lumang presyo (₱), opsyonal',
    'Shown crossed out next to the price':
        'Ipinapakitang may guhit sa tabi ng presyo',
    'Enter a valid price': 'Maglagay ng wastong presyo',
    'Old price must be higher than the price':
        'Dapat mas mataas ang lumang presyo kaysa sa presyo',
    'Category': 'Kategorya',
    'Pre-orders have no stock limit': 'Walang limitasyon sa stock ang pre-order',
    'Pre-order period': 'Panahon ng pre-order',
    'How many units you have. 0 = sold out':
        'Ilan ang mayroon ka. 0 = ubos na',
    'Enter the number in stock': 'Ilagay ang bilang ng stock',
    'That seems too high': 'Mukhang masyadong mataas',
    'Description': 'Paglalarawan',
    'Product details': 'Mga detalye ng produkto',
    'One detail per line, e.g. Material: PVC, ABS':
        'Isang detalye kada linya, hal. Material: PVC, ABS',

            
    'Product': 'Produkto',
    'Pre-Order Now Open': 'Bukas Na ang Pre-Order',
    'Pre-order item': 'Pre-order na aytem',
    'Out of stock': 'Ubos na ang stock',
    'Out of Stock': 'Ubos Na ang Stock',
    'Quantity ({n} available)': 'Dami ({n} ang available)',
    'Product Details': 'Mga Detalye ng Produkto',
    'Add to Cart': 'Idagdag sa Cart',
    '{rating}  ·  {n} Reviews': '{rating}  ·  {n} Review',

        
    'Available': 'Available',
    'My Vouchers': 'Aking mga Voucher',
    'Claim': 'Kunin',
    'Claimed': 'Nakuha na',
    'Used': 'Nagamit na',
    'Expired': 'Nag-expire na',
    'No expiry': 'Walang expiry',
    '{n}% OFF': '{n}% DISKUWENTO',
    '{amount} OFF': '{amount} DISKUWENTO',
    'Min. spend {amount}': 'Minimum na gastos {amount}',
    'Valid until {date}': 'Valid hanggang {date}',
    'Voucher claimed': 'Nakuha ang voucher',
    'You already claimed this voucher': 'Nakuha mo na ang voucher na ito',
    'No vouchers available right now.': 'Walang available na voucher ngayon.',
    'You have no vouchers yet. Claim some from the Available tab.':
        'Wala ka pang voucher. Kumuha mula sa tab na Available.',

            'You have vouchers waiting!': 'May naghihintay na voucher para sa iyo!',
    'Close': 'Isara',
    'Maybe later': 'Mamaya na lang',
    'Enter a valid email address': 'Maglagay ng wastong email address',
'Enter a valid contact number': 'Maglagay ng wastong contact number',
'Enter a valid email address or contact number':
    'Maglagay ng wastong email address o contact number',

    'Claim them now and use them at checkout': 'Kunin na at gamitin sa checkout',
    'Claimed +1': 'Nakuha +1',
'You can claim one voucher per login': 'Isang voucher lang ang makukuha bawat login',

    'Please add a delivery address': 'Magdagdag ng address ng paghahatid',
    'Address is too short. Include street, barangay, city, and province':
        'Masyadong maikli ang address. Isama ang kalye, barangay, lungsod, at probinsya',
    'Address is too long': 'Masyadong mahaba ang address',
    'Add': 'Idagdag',
    'Change': 'Palitan',
  };

  static String t(String key, [Map<String, Object?>? args]) {
    var s = SettingsService().language == AppLanguage.fil
        ? (_fil[key] ?? key)
        : key;
    args?.forEach((k, v) => s = s.replaceAll('{$k}', '$v'));
    return s;
  }
}